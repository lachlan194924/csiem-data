def import_nasa_ghrsst(CODE_DIR,ACTIONS_DIR,base_path,matlab_data_conversion_data,matlab_data_variable_names,matlab_data_site_coordinates):
    import pandas as pd
    import numpy as np
    import os
    import sys
    sys.path.append(str(CODE_DIR))
    from import_py.utils.matlab_utils import get_datapath_from_matlab, get_conversion_data, get_variable_names, get_site_coordinates
    
    # specify constants
    AGENCY_NAME = "The National Aeronautics and Space Administration"
    AGENCY_CODE = "NASA"
    PROGRAM = "GHRSST"
    PROJECT = "ghrsst"
    TAG = "NASA-GHRSST"
    STATION_STATUS = "Active"
    TIME_ZONE = "GMT +8"
    VERT_DATUM = "mAHD"
    DEPLOYMENT = "Satelite"
    DEPLOYMENT_POSITION = "0m below surface"
    VERT_REF = "Water Surface"
    SITE_MEAN_DEPTH = "0.0000"
    BAD_VALUE = 'NaN'
    EMAIL = "Yvette <00114814@uwa.edu.au> 7/11/2024"
    SAMPLING_RATE = "-1.0000"
    DATE = "yyyy-mm-dd HH:MM:SS"
    DEPTH = "Decimal"
    QC = "String"

    datapath,datapath_raw = get_datapath_from_matlab(ACTIONS_DIR,base_path)
    print(f"Current datapath: {datapath}")
    dir_lst = [
        datapath + "/data-lake/NASA/GHRSST/ghrsst/py_Points",
        datapath + "/data-lake/NASA/GHRSST/ghrsst/py_Polygon_offshore"
    ]
    dir_header = datapath + "/data-warehouse/csv/nasa/ghrsst"
    dir_header_raw = datapath_raw + "/data-warehouse/csv/nasa/ghrsst"
    dataset = "NASA"
    nasa_data = get_conversion_data(dataset,matlab_data_conversion_data)
    site_dataset = "VirtualSensors"
    site_coordinates_data = get_site_coordinates(site_dataset,matlab_data_site_coordinates)

    def process_data(dir):
        # Initialize the DataFrame to store all variable information
        all_var_info = pd.DataFrame(columns=['Id', 'Name'])
        
        for file in os.listdir(dir):
            if file.endswith(".csv") and "Store" not in file:
                # print(file)
                # Read data file
                df = pd.read_csv(os.path.join(dir, file), header=0, encoding='utf-8')
                df['Date'] = pd.to_datetime(df['time'])
                df['Date'] = df['Date'].dt.strftime('%Y-%m-%d %H:%M:%S')
                # print(df)

                # Extract site id from file
                if "GHRSST" in dir and "py_Points" in dir:
                    site = "py_Point_" + file.replace(".csv","").split("_p")[1]
                elif "GHRSST" in dir and "py_Polygon_offshore" in dir:
                    site = "py_OffShorePolygon_" + file.replace(".csv","").split("_p")[1]
                print(site)

                variables_name = list(df)
                variables = [var for var in variables_name if var not in ['time','latitude','longitude','Date','depth']]
                # print(variables)

            for variable in variables:
                df_filtered = pd.DataFrame()  # Initialize an empty DataFrame

                df_filtered['Date'] = df['Date']
                df_filtered['Data'] = df[variable]
                df_filtered['Variable'] = variable

                if 'depth' in df.columns:
                    df_filtered['Depth'] = df['depth']
                else:
                    df_filtered['Depth'] = 0

                df_filtered["QC"] = 'N'

                df_filtered = df_filtered.sort_values(by='Date')

                # Replace empty cells with NaN
                df_filtered.replace("", np.nan, inplace=True)

                df_filtered = df_filtered.loc[:, ["Date", "Depth", "Data", "QC"]]

                # Find matching variable in MATLAB data and get conversion factor
                conv_factor = 1  # default value
                for field in nasa_data.dtype.names:
                    old_name = nasa_data[field][0, 0]['Old'][0, 0][0]
                    if old_name == variable:
                        conv_factor = float(nasa_data[field][0, 0]['Conv'][0, 0][0])
                        Id = nasa_data[field][0, 0]['ID'][0, 0][0]
                        break

                # Convert value of different units
                if conv_factor != 1:
                    df_filtered['Data'] = pd.to_numeric(df_filtered['Data'], errors='coerce')  # Convert non-numeric values to NaN
                    df_filtered['Data'] *= conv_factor

                # Drop rows where Data is NaN
                df_filtered = df_filtered.dropna(subset=['Data'])
                # Handle duplicate rows with same date but different data
                df_filtered['Data'] = pd.to_numeric(df_filtered['Data'], errors='coerce')
                df_filtered = df_filtered.groupby(['Date', 'Depth', 'QC']).agg({
                    'Data': 'mean'
                }).reset_index()

                name_conv = get_variable_names(Id,matlab_data_variable_names)['Name'][0, 0][0]
                # Append to the all_var_info DataFrame
                var_info = pd.DataFrame({
                    'Id': [Id],
                    'Name': [name_conv]
                })
                all_var_info = pd.concat([all_var_info, var_info], ignore_index=True)

                output_filename = f'{file.split(".")[0]}_{name_conv.replace(" ","_")}_DATA.csv'
                if "combined" in output_filename:
                    if "Point" in dir:
                        output_filename = f'{site}_{name_conv.replace(" ","_")}_DATA.csv'
                    elif "Polygon" in dir:
                        output_filename = f'{site}_{name_conv.replace(" ","_")}_DATA.csv'
                print(output_filename)
                print(df_filtered)
                # Write the filtered DataFrame to a CSV file in the specified directory only if it's not empty
                output_dir = dir.replace("data-lake","data-warehouse/csv")
                output_dir = "/".join(output_dir.split("/")[:-2]).lower()
                os.makedirs(output_dir, exist_ok=True)
                if not df_filtered.empty:
                    df_filtered.to_csv(os.path.join(output_dir, output_filename), index=False)

        return all_var_info  # Return the DataFrame containing variable IDs and names

    def process_header(dir_header,var_id_name_df,dir_header_raw):
        for file in os.listdir(dir_header):
            if file.endswith('.csv') and file.startswith("py"):
                if "DATA" in file:
                    print(file)
                    NATIONAL_STATION_ID = "_".join(file.split("_")[1:3])
                    print(NATIONAL_STATION_ID)
                    site_coordinates = site_coordinates_data[NATIONAL_STATION_ID][0,0]
                    
                    LAT = site_coordinates["Lat"][0,0][0][0]
                    LONG = site_coordinates["Lon"][0,0][0][0]

                    SITE_DESCRIPTION = NATIONAL_STATION_ID.split("_")[1]

                    VARIABLE = " ".join(file.split("_")[3:-1])
                    VARIABLE_ID = var_id_name_df.loc[var_id_name_df["Name"] == VARIABLE, "Id"].iloc[0]

                    header_dict = {
                        "Agency Name": AGENCY_NAME,
                        "Agency Code": AGENCY_CODE,
                        "Program": PROGRAM,
                        "Project": PROJECT,
                        "Tag": TAG,
                        "Data File Name": file,
                        "Location": dir_header_raw,
                        "Station Status": STATION_STATUS,
                        "Lat": LAT,
                        "Long": LONG,
                        "Time Zone": TIME_ZONE,
                        "Vertical Datum": VERT_DATUM,
                        "National Station ID": NATIONAL_STATION_ID,
                        "Site Description": SITE_DESCRIPTION,
                        "Deployment": DEPLOYMENT,
                        "Deployment Position": DEPLOYMENT_POSITION,
                        "Vertical Reference": VERT_REF,
                        "Site Mean Depth": SITE_MEAN_DEPTH,
                        "Bad or Unavailable Data Value": BAD_VALUE,
                        "Contact Email": EMAIL,
                        "Variable ID": VARIABLE_ID,
                        "Data Category": get_variable_names(VARIABLE_ID,matlab_data_variable_names)['Category'][0,0][0],
                        "Sampling Rate (min)": SAMPLING_RATE,
                        "Date": DATE,
                        "Depth": DEPTH,
                        "Variable": VARIABLE,
                        "QC": QC
                    }
                    
                    output_filename = file.replace("DATA","HEADER")

                    print(output_filename)
                    file_path = os.path.join(dir_header, output_filename)

                    header_df = pd.DataFrame({"Header": header_dict.keys(), "Value": header_dict.values()})
                    # print(header_df)
                    header_df.to_csv(file_path, index=False, header=False)

    for dir in dir_lst:
        var_id_name_df = process_data(dir)

    process_header(dir_header,var_id_name_df,dir_header_raw)