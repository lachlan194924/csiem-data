clear all; close all;

addpath(genpath('../../functions/'));


filepath = 'Y:\csiem\Model\TFV\csiem_model_tfvaed_1.1\bc_repo\2_weather\WRF\';

filelist = dir(fullfile(filepath, '**\*.nc'));  %get list of files and folders in any subfolder
filelist = filelist(~[filelist.isdir]);  %remove folders from list

metshp = shaperead('..\..\..\data-mapping\By Theme\Met\data locations_met.shp');

outdir = 'D:\csiem\data-warehouse\csv_holding\wrf\wrf_tfv\';mkdir(outdir)

for i = 1:length(filelist)

    filename = [filelist(i).folder,'\',filelist(i).name];
        
    lat = ncread(filename,'latitude');
    lon = ncread(filename,'longitude');
    ltime = double(ncread(filename,'local_time'));
    mtime = datenum(1990,01,01) + (ltime/24);
    
    dv = datevec(mtime(end-100));
    theyear = num2str(dv(1));
    
    thedata = tfv_readnetcdf(filename);
    
    vars = fieldnames(thedata);
    
    mlat = metshp(17).Latitude;
    mlon = metshp(17).Longitude;
    
    [~,ind_lat] = min(abs(lat - mlat));
    [~,ind_lon] = min(abs(lon - mlon));
    
    fid = fopen([outdir,'WRF_',theyear,'_',metshp(17).AED_ID,'.csv'],'wt');
    
    fprintf(fid,'Time,');
    for j = 5:length(vars)
        if j == length(vars)
            fprintf(fid,'%s\n',vars{j});
        else
            fprintf(fid,'%s,',vars{j});
        end
    end
    for k = 1:length(mtime)
        fprintf(fid,'%s,',datestr(mtime(k),'yyyy-mm-dd HH:MM:SS'));
        for j = 5:length(vars)
            if j == length(vars)
                fprintf(fid,'%6.6f\n',thedata.(vars{j})(ind_lon,ind_lat,k));
            else
                fprintf(fid,'%6.6f,',thedata.(vars{j})(ind_lon,ind_lat,k));
            end
        end
    end 
    
    fclose(fid); 
       
end