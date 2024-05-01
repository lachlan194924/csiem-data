function getEBNRmetdata(filename)

fid = fopen('filename','rt');
cHeader = { ...
        'Date_Raw';...
        'Time_Raw';...
        'Wind_Direction_Min';...
        'Wind_Direction_Avg';...
        'Wind_Direction_Max';...
        'Wind_Speed_Min';...
        'Wind_Speed_Avg';...
        'Wind_Speed_Max';...
        'AirTemperature';...
        'RelativeHumidity';...
        'AirPressure_Stn';...
        'Rainfall';...
        'Vaisala_Power';...
        'Solar_Rad';...
        'Water_Temp';...
        'Internal_Bat';...
        'External_Sup';...
        'NA';...
        }; 
x  = length(cHeader);
    textformat = [repmat('%s ',1,x)];
    datacell = textscan(fid,textformat,...
        'Headerlines',1,...
        'Delimiter',',');
    fclose(fid);
    
   for iHeader = 1:length(cHeader)
    if strcmp(cHeader{iHeader},'Date_Raw') == 1
          met.(cHeader{iHeader}) = datacell{iHeader};
    elseif strcmp(cHeader{iHeader},'Time_Raw') == 1
          met.(cHeader{iHeader}) = datacell{iHeader};
    else
          met.(cHeader{iHeader}) = str2double(datacell{iHeader});
    end
    
   end
   
       met.date_str = strcat(met.Date_Raw,met.Time_Raw);  
       met.Date = datenum(met.date_str,'dd/mm/yyyyHH:MM:SS');
   
   solardata.ellenbrook = met;
   
   save solardata.mat solardata -mat -v7