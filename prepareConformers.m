function prepareConformers(comboNumber, conformers_number, nature, new, SP, analysis, opt, ck, basePath)
    % Reads xyz conformers, writes txt, creates job folders and OrcaJob.sh
    for X = 1:conformers_number
        % build paths
        xyzFile = fullfile(basePath, "Transport", "W15", "NanoribbonNoMol", ...
                           "NewTrials_0508", sprintf("Combo%d\\Crest\\Conformers\\Conformer%d.xyz", comboNumber, X));
        txtFile = sprintf("Conformer%d.txt", X);

        if exist(xyzFile, 'file')
            copyfile(xyzFile, txtFile);
        end

        % create ORCA job script
        writeOrcaJob(comboNumber, X, nature, SP, analysis, opt, ck);
    end
end