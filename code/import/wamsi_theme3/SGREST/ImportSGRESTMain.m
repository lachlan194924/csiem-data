clear 
addpath('Functions')
directory = "../../../../../data-swamp/WWMSP3.1 - Seagrass CutDown/WAMS23-6 WCP3.1  PSD/";
searchReq = '*.xlsx' ;
Seagrass = Extractor(directory,searchReq);
Seagrass = SeagrassLatFixer(Seagrass);


VarkeyAddress = "../../../../../git/data-governance/variable_key.xlsx";
            opts = spreadsheetImportOptions("NumVariables", 2);
            opts.Sheet = "MASTER KEY";
            opts.VariableTypes = ["string", "string"];
            opts.DataRange = "A345:B357";
VarKey = readtable(VarkeyAddress,opts);

FFName = "../../../../../data-lake/WAMSI/wwmsp3.1_SGREST/FlatFile.csv";
FFHeadings = ["Date","X","Y","Site","SampleID","Variable","Units","ReadingValue","VariableName","VariableType","Origin","Filename"];
writematrix(FFHeadings,FFName)
FillFlatFile(FFName,Seagrass,"Seagrass");


HeaderCSV(FFName,VarKey);


clear directory searchReq
