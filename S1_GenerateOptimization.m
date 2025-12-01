function S1_GenerateOptimization(userSettings)

% import optimization template
ORCA_optFileContent = fileread("TEMPLATE_FILES/optimization_script");

rawText = fileread(userSettings.GEOMETRY_FILE);
lines = splitlines(rawText);
lines = lines(3:end);
molCoordinates = strjoin(lines, newline);

%adjust input file
ORCA_optFileContent = keyWordReplace(ORCA_optFileContent,userSettings);
ORCA_optFileContent = strrep(ORCA_optFileContent,"BASH_COORDINATES",molCoordinates);

%create optimization file
ORCA_optFileFolder = fullfile(userSettings.working_path,userSettings.WORKSPACE,'01_optimization_folder');
shortName = regexp(userSettings.MOLECULE_NAME, '[^\\\/]+$', 'match', 'once');
ORCA_optFileName = sprintf('%sOpt.inp', shortName);
ORCA_optFilePath = fullfile(userSettings.working_path,userSettings.WORKSPACE,'01_optimization_folder',ORCA_optFileName);
generateFile(ORCA_optFileFolder,ORCA_optFilePath,ORCA_optFileContent)

%create DB folders
DB_MolFolderName=sprintf("%s_%s",shortName,userSettings.MOLECULE_FORMULA);
DB_GeomFolderName=sprintf("Geom%d_%s_%s",userSettings.DB_GEOMNUMBER,userSettings.ABINITIO_FUNCTIONAL,userSettings.ABINITIO_BASISSET);
DB_optFolderName = fullfile(userSettings.working_path,userSettings.WORKSPACE,'DB',DB_MolFolderName,'isolated_characterization',DB_GeomFolderName); %not compatible with HF method

%create DB/data.txt content
DB_DataFileContent = fullfile('TEMPLATE_FILES','data.txt');
DB_DataFileContent=keyWordReplace(DB_DataFileContent,userSettings);

%create DB data file
DB_DataFileName = fullfile(userSettings.working_path,userSettings.WORKSPACE','DB',DB_MolFolderName,'isolated_characterization',DB_GeomFolderName,'data.txt');
generateFile(DB_optFolderName,DB_DataFileName,DB_DataFileContent);

end
