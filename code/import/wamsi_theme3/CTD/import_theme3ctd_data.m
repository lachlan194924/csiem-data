function import_theme3ctd_data
addpath(genpath('../../functions/'));


load ../../../../code/actions/sitekey.mat;
load ../../../../code/actions/varkey.mat;
load ../../../../code/actions/agency.mat;

run('../../../actions/csiem_data_paths.m')

outdir = [datapath,'data-warehouse/csv_holding/wamsi/wwmsp3/ctd/'];mkdir(outdir);
outdir_main = [datapath,'data-warehouse/csv/wamsi/wwmsp3/ctd/'];mkdir(outdir_main);


data = readtable([outdir,'wwmsp_theme3.1_CTD_reformat_bbusch_working.csv']);

sites = data.Site;
sites = regexprep(sites,'site','');
sites = regexprep(sites,'OA1_DEP','OA1-DEP');
sites = regexprep(sites,'OA1_Dep','OA1-DEP');
sites = regexprep(sites,'1310','s1310');

thevars = fieldnames(agency.wwmsp3);
thesites = fieldnames(sitekey.wwmsp3);

tag = 'WWMSP-3.1-CTD';

for i = 1:length(thevars)
    for j = 1:length(thesites)
        
        theind = find(strcmpi(data.Variable,agency.wwmsp3.(thevars{i}).Old) == 1 & ...
            strcmpi(sites,sitekey.wwmsp3.(thesites{j}).ID) == 1);
        
        mdate = datenum(data.Date(theind),'dd-mm-yyyy HH:MM:SS');
        mdata = data.ReadingValue(theind) * agency.wwmsp3.(thevars{i}).Conv;
        mdepth = data.Depth_m_(theind);
        
        [mdate,sortind] = unique(mdate);
        mdata = mdata(sortind);
        mdepth = mdepth(sortind);
        
        varname = varkey.(agency.wwmsp3.(thevars{i}).ID).Name;
        fullvar = [varname,' (',varkey.(agency.wwmsp3.(thevars{i}).ID).Unit,')'];
        
        filename = [outdir_main,thesites{j},'_',regexprep(varname,' ','_'),'_DATA.csv'];
        
            
            
            fid = fopen(filename,'wt');
            fprintf(fid,'Date,Depth,Data,QC\n');
            for kk = 1:length(mdate)
                fprintf(fid,'%s,%4.4f,%4.4f,N\n',datestr(mdate(kk),'yyyy-mm-dd HH:MM:SS'),mdepth(kk),mdata(kk));
            end
            fclose(fid);
            headerfile = regexprep(filename,'_DATA.csv','_HEADER.csv')
            
            fid = fopen(headerfile,'wt');
            fprintf(fid,'Agency Name,Western Australian Marine Science Institution\n');
            
            fprintf(fid,'Agency Code,WAMSI\n');
            fprintf(fid,'Program,WWMSP3\n');
            fprintf(fid,'Project,WWMSP3.1_CTD\n');
            fprintf(fid,'Tag,WAMSI-WWMSP3-CTD\n');
            fprintf(fid,'Data File Name,%s\n',filename);
            fprintf(fid,'Location,%s\n',outdir_main);
            
            
            fprintf(fid,'Station Status,Static\n');
            fprintf(fid,'Lat,%6.9f\n',sitekey.wwmsp3.(thesites{j}).Lat);
            fprintf(fid,'Long,%6.9f\n',sitekey.wwmsp3.(thesites{j}).Lon);
            fprintf(fid,'Time Zone,GMT +8\n');
            fprintf(fid,'Vertical Datum,mAHD\n');
            fprintf(fid,'National Station ID,%s\n',sitekey.wwmsp3.(thesites{j}).ID);
            fprintf(fid,'Site Description,%s\n',sitekey.wwmsp3.(thesites{j}).Description);
            fprintf(fid,'Deployment,%s\n','Profile');
            fprintf(fid,'Deployment Position,%s\n','m from Surface');
            fprintf(fid,'Vertical Reference,%s\n','Water Surface');
            fprintf(fid,'Site Mean Depth,%s\n','');
            fprintf(fid,'Bad or Unavailable Data Value,NaN\n');
            fprintf(fid,'Contact Email,%s\n','');
            fprintf(fid,'Variable ID,%s\n',agency.wwmsp3.(thevars{i}).ID);
            
            fprintf(fid,'Data Category,%s\n',varkey.(agency.wwmsp3.(thevars{i}).ID).Category);
            
            
            SD = mean(diff(mdate));
            
            fprintf(fid,'Sampling Rate (min),%4.4f\n',SD * (60*24));
            
            fprintf(fid,'Date,yyyy-mm-dd HH:MM:SS\n');
            fprintf(fid,'Depth,Decimal\n');
            
            
            fprintf(fid,'Variable,%s\n',fullvar);
            fprintf(fid,'QC,String\n');
            
            fclose(fid);
            %plot_datafile(filename);
        
        
        
    end
end
        
        
