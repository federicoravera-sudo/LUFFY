function writeOrcaJob(comboNumber, X, nature, SP, analysis, opt, ck)
    % open OrcaJob.sh in the right folder
    newFolder = sprintf("Conformers%sWs\\Combo%d_Cf%d\\02_characterisation_folder_OPT_ck0", nature, comboNumber, X);
    if ~exist(newFolder, 'dir'); mkdir(newFolder); end
    jobFile = fullfile(newFolder, "OrcaJob.sh");
    fid = fopen(jobFile, 'w');

    % select template depending on SP/analysis/opt
    if SP==0 && analysis==0 && opt==1
        % write optimization job
    elseif SP==0 && analysis==0 && opt==0
        % write characteristics job
    else
        % write SP job
    end

    fclose(fid);
end