function prepareConformers(moleculeName, conformers_number, SP, analysis, opt, ck, basePath)
    % Reads xyz conformers, writes txt, creates job folders and OrcaJob.sh
        % build paths
        xyzFile = fullfile(basePath, moleculeName, sprintf("Conformers\\Conformer%d.xyz", conformers_number));
        txtFile = fullfile(basePath, moleculeName, sprintf("Conformers\\Conformer%d.txt", conformers_number));

        if exist(xyzFile, 'file')
            copyfile(xyzFile, txtFile);
        end

        % create ORCA job script
        writeOrcaJob(moleculeName,conformers_number, SP, analysis, opt, ck,basePath);
end