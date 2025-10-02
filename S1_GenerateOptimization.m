function S1_GenerateOptimization(userSettings)

% import optimization template
ORCA_optFileContent = fileread("TEMPLATE_FILES/optimization_script");
molCoordinates = fileread(userSettings.GEOMETRY_FILE);

%adjust input file
ORCA_optFileContent = keyWordReplace(ORCA_optFileContent,userSettings);
ORCA_optFileContent = strrep(ORCA_optFileContent,"BASH_COORDINATES",molCoordinates);

%create optimization file
ORCA_optFileFolder = fullfile(userSettings.working_path,userSettings.WORKSPACE,'01_optimization_folder');
ORCA_optFileName = sprintf('%sOpt.inp',userSettings.MOLECULE_NAME);
ORCA_optFilePath = fullfile(userSettings.working_path,userSettings.WORKSPACE,'01_optimization_folder',ORCA_optFileName);
generateFile(ORCA_optFileFolder,ORCA_optFilePath,ORCA_optFileContent)

%create sbatch launch file
% if strcmp(userSettings.HPC_ENABLED,"YES")
%     ORCA_launchFileContent = fileread("TEMPLATE_FILES/optimization_hpc");
%     ORCA_launchFileContent = strrep(ORCA_launchFileContent,"JOB_NAME",userSettings.JOB_NAME);
%     ORCA_launchFileContent = strrep(ORCA_launchFileContent,"USER_MAIL",userSettings.USER_MAIL);
%     ORCA_launchFileContent = strrep(ORCA_launchFileContent,"WORKDIR",userSettings.WORKDIR);
%     ORCA_launchFileContent = strrep(ORCA_launchFileContent,"OUT_FILENAME",userSettings.OUT_FILENAME);
%     ORCA_launchFileContent = strrep(ORCA_launchFileContent,"NTASKS",num2str(userSettings.ABINITIO_NPROC));
%     ORCA_launchFileContent = strrep(ORCA_launchFileContent,"USER_NAME",userSettings.USER_NAME);
%     ORCA_launchFileContent = strrep(ORCA_launchFileContent,"INFILE_PATH",userSettings.INFILE_PATH);
%     ORCA_launchFileContent = strrep(ORCA_launchFileContent,"ORCA_PATH",userSettings.ORCA_PATH);
% 
%     ORCA_optFilePath = fullfile(userSettings.working_path,userSettings.WORKSPACE,'01_optimization_folder','launchORCAopt.sbatch');
%     generateFile(ORCA_optFileFolder,ORCA_optFilePath,ORCA_launchFileContent)
% end

%create DB folders
DB_MolFolderName=sprintf("%s_%s",userSettings.MOLECULE_NAME,userSettings.MOLECULE_FORMULA);
DB_GeomFolderName=sprintf("Geom%d_%s_%s",userSettings.DB_GEOMNUMBER,userSettings.ABINITIO_FUNCTIONAL,userSettings.ABINITIO_BASISSET);
DB_optFolderName = fullfile(userSettings.working_path,userSettings.WORKSPACE,'DB',DB_MolFolderName,'isolated_characterization',DB_GeomFolderName); %not compatible with HF method

%create DB/data.txt content
DB_DataFileContent = fullfile('TEMPLATE_FILES','data.txt');
DB_DataFileContent=keyWordReplace(DB_DataFileContent,userSettings);

%create DB data file
DB_DataFileName = fullfile(userSettings.working_path,userSettings.WORKSPACE','DB',DB_MolFolderName,'isolated_characterization',DB_GeomFolderName,'data.txt');
generateFile(DB_optFolderName,DB_DataFileName,DB_DataFileContent);

end
