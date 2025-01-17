clear all; close all;
addpath(genpath('../functions'));
csiem_data_paths 
tic

% import_var_key_info;
% import_site_key;
csiem_file_cleaner


import_dwer = 0;
import_dwer_swanest_phy = 0;
import_dot = 0;
import_bom = 0;
import_mafrl = 0;
import_imos = 0;
import_imos_srs = 0;

import_dpird = 0;
import_moorings = 0;
import_theme2 = 0;

import_theme3 = 0;
import_theme5 = 0;
import_wc = 0;
import_fpa = 0;
import_bmt_wp_swan = 0;
import_wamsitheme1 = 0;
import_UKMO = 0;
import_NASA = 0;
import_aims = 0;
import_CSPHY = 0;
import_IMOSPlanktonvar = 0;
import_WCWA1Phyto = 0;
import_WCWA2Phyto = 0;
import_WCWA3_9Phyto = 0;
import_UWA_AED_Phyto = 0;

import_wamsiwaves = 0;


create_smd = 0;

create_matfiles = 0;
create_parquet = 0;

create_dataplots = 0;
plotnew_dataplots = 0;

create_shapefiles = 0;


run_marvl = 1;


%___________________________________________________________________________

% Import Scripts.....

%___________________________________________________________________________



if import_fpa
    cd ../import/FPA;
    import_fpa_mqmp;
    cd ../../actions;
end


if import_dwer
    % DWER Export
    cd ../import/DWER;
    
    %run_WIR_import_v2;
    export_wir_v2_stage1;
    import_and_reformat_flatfile;
    
    % export_wir;clear all; close all;
    cd ../../actions
end

if import_dwer_swanest_phy
    cd ../import/DWER/SWANESTPHY/
        DWER_SWANEST_PHY_Groups_Staging
        DWER_SWANEST_PHY_Groups_Staged
        DWER_SWANEST_PHY_Species
    cd ../../../actions/
end

% DOT Export

if import_dot
    cd ../import/DOT;
    
    
    import_bar_tidal_data;
    %
    import_freo_tidal_data;
    %
    import_hil_tidal_data;
    %
    import_mgb_tidal_data;
    
    cd ../../actions
end

if import_bom
    %BOM Export
    cd ../import/BOM;
    run_BOM_IDY;
    import_BOM_BARRA_TFV;

    cd ../../actions
end
%MAFRL
if import_mafrl
    cd ../import/MAFRL/
    
    import_mafrl_2_csv;
    merge_files;
    
    
    cd ../../actions
end


%IMOS
if import_imos
    cd ../import/IMOS
    
    import_imos_bgc_2_csv;
    %
    import_imos_profile_2_csv;
    %
    import_imos_profile_2_2010_csv;
    
    merge_files;

    import_imos_amnm_adcp;
    
    % Needs updating
    % import_imos_profile_2_csv_BURST;
    %
    % import_imos_profile_2_csv_BURST2;
    
    
    cd ../../actions
end

if import_imos_srs
    cd ../import/IMOS_SRS/
    import_IMOS_SRS_L3S_netcdf_data;
    import_IMOS_SRS_MODIS_netcdf_data;
    import_IMOS_SRS_MODIS_OC3_netcdf_data;
    cd ../../actions/
end

if import_dpird
    % DPIRD
    cd ../import/DPIRD
    
    import_dpird_crp_data;
    
    cd ../../actions/
end

if import_moorings
    % DWER Mooring
    cd ../import/DWER_Mooring
    
    import_csmooring;
    
    cd ../../actions/
end

if import_theme2
    % wamsi_theme2
    cd ../import/wamsi_theme2
    
    import_theme2_light;
    import_theme2_seagrass;
    cd ../../actions/
end

if import_theme3
    % wamsi_theme3
    cd ../import/wamsi_theme3/CTD
    reformat_ctd;
    import_theme3ctd_data;
    
    cd ../../../actions/

    %Sediment
    cd ../import/wamsi_theme3/SEDPSD
    run ImportSEDPSDMain
    cd ../../../actions

    cd ../import/wamsi_theme3/SGREST
    run ImportSGRESTMain
    cd ../../../actions

    cd ../import/wamsi_theme3/SEDDEPO
    run IMPORTSEDDEPO
    cd ../../../actions

    
end

if import_wc
    % WC_Digitised
    cd ../import/WCWA
    import_wc_digitised_dataset;
    import_wc_digitised_dataset_b;

    import_PhyWQ_1334_09;
    
    cd ../../actions/
end

%WAMSI
if import_theme5
    cd ../import/wamsi_theme5
    
    import_wwmsp5_wq;
    import_wwmsp5_awac;
    import_wwmsp5_met;

    cd Waves/
    import_Waves
    cd ../

    cd WWM/
    importWWM
    cd ../

    cd ../../actions/
end

if import_wamsiwaves
    cd ../import/wamsi_theme5/Waves
    import_Waves
    cd ../

    cd ../../actions/
end


if import_bmt_wp_swan
    cd ../import/BMT/WP/
    import_BMT_WP_SWAN
    cd ../../../actions/
end

if import_UKMO
    cd ../import/UKMO
    system('python3 ImportUKMO_OSTIA.py') 
    cd ../../actions/
end

if import_NASA
    cd ../import/NASA

        cd GHRSST
        ImportNASASST
        cd ..
        
    cd ../../actions/
end


%if  import_met_models
%    cd ../import/BARRA
%    import_export_barra;
%    cd ../../actions/
%end

if import_wamsitheme1
    cd ../import/wamsi_theme1/
    ImportWRF
    cd ../../actions/
end

if import_aims
    cd ../import/AIMS/TEMP/
    import_AIMS_TEMP
    cd ../../../actions
end

if import_CSPHY
    cd ../import/DWER/CSPHY/
    import_CSPHY_SPECIES

    import_CSPHY_GROUP_STAGING
    import_CSPHY_GROUP
    cd ../../../actions/
end

if import_IMOSPlanktonvar
    cd ../import/IMOS/IMOSPHYTO/
    import_IMOSPlankton

    Holding_IMOSPlanktonGroup 
    import_IMOSPlanktonGroup

    cd ../../../actions/
end

if import_WCWA1Phyto
    cd ../import/WCWA/Phytoplankton/WCWA1
    import_phytoplankton1_Species
    import_phytoplankton1_Group
    cd ../../../../actions/
end

if import_WCWA2Phyto
    cd ../import/WCWA/Phytoplankton/WCWA2
    import_phytoplankton2_Species
    import_phytoplankton2_Group
    cd ../../../../actions/
end

if import_WCWA3_9Phyto
    cd ../import/WCWA/Phytoplankton/WCWA3-9
    RunALL
    cd ../../../../actions/
end

if import_UWA_AED_Phyto
    cd ../import/UWA/AED/swan-phytoplankton/
        cd subset1/
        PhytoGroup
        %PhytoSpeciesNOTDONE 
        cd ../

        cd subset2/
        PhytoGroup
        PhytoSpecies 
        cd ../
    cd ../../../../actions/
end





if create_smd
    calculate_SMD_for_headers
end

if create_matfiles
    csv_2_matfile_tfv_by_agency;
end
if create_parquet
    csv_2_parquet_by_agency;
    %csv_2_parquet_by_category;
end

if create_dataplots
    plot_datawarehouse_csv_all(plotnew_dataplots);
end

if run_marvl
    addpath(genpath(marvldatapath));
    create_marvl_config_information;
    run_AEDmarvl marvl_pipeline_images;
    rmpath(genpath(marvldatapath));
end

if create_shapefiles
    header_to_shapefile;
end

B = toc;

disp(['Total Runtime: ',num2str(B/(60*60)),' Hours']);





