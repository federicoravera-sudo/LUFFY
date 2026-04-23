function loadData(basePath, moleculeName, opt, SP, set_VACT_analysis, VACTanalysisName)
    % ====================================================================
    % Copy results (Optimization / SP / VACT) from each Cf* subfolder
    % into a common upload directory:
    %   - ToUploadGeom   if opt = 1
    %   - ToUploadSP     if SP = 1
    %   - ToUploadVACT   if set_VACT_analysis = 1
    %
    % INPUTS:
    %   basePath            - main working path (e.g., ...\autochar\LUFFY)
    %   moleculeName        - molecule folder name (e.g., "DatabaseMol\\Diferrocenylcarborane")
    %   opt                 - flag for optimization
    %   SP                  - flag for single point
    %   set_VACT_analysis   - flag for VACT analysis
    %   VACTanalysisName    - folder name for VACT analysis
    % ====================================================================

    % Extract short molecule name (remove any preceding path)
    molShort = regexp(moleculeName, '[^\\\/]+$', 'match', 'once');

    % Define the source root
    sourceRoot = fullfile(basePath, moleculeName);

    % Determine which folder to copy and where to save it
    if opt
        folderToCopy = '01_optimization_folder';
        destRoot = fullfile(basePath, 'DatabaseMol', 'ToUploadGeom');
    elseif SP
        folderToCopy = 'sp_folder';
        destRoot = fullfile(basePath, 'DatabaseMol', 'ToUploadSP');
    elseif set_VACT_analysis
        folderToCopy = VACTanalysisName;
        destRoot = fullfile(basePath, 'DatabaseMol', 'ToUploadVACT');
    else
        warning('No active flag (opt / SP / set_VACT_analysis). Nothing to copy.');
        return;
    end

    % Create destination root if it does not exist
    if ~exist(destRoot, 'dir')
        mkdir(destRoot);
    end

    % Find all conformer folders (Cf1, Cf2, ...)
    cfFolders = dir(fullfile(sourceRoot, 'Cf*'));
    cfFolders = cfFolders([cfFolders.isdir]); % keep only directories

    % Loop over each conformer
    for i = 1:length(cfFolders)
        cfName = cfFolders(i).name;  % e.g., "Cf1"
        srcFolder = fullfile(sourceRoot, cfName, folderToCopy);

        if exist(srcFolder, 'dir')
            % Create destination subfolder for this conformer
            destSub = fullfile(destRoot, sprintf('%s_%s', molShort, cfName),VACTanalysisName);
            if ~exist(destSub, 'dir')
                mkdir(destSub);
            end

            % Copy all content
            copyfile(fullfile(srcFolder, '*'), destSub);
            fprintf('Copied: %s  →  %s\n', srcFolder, destSub);
        else
            fprintf('Folder not found: %s\n', srcFolder);
        end
    end

    fprintf('\n✅ Copy operation completed. Files saved in:\n%s\n', destRoot);
end
