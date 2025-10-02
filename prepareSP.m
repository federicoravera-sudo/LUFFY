function prepareSP(comboNumber, cfIndex, nature, basePath)
    % Prepares Single Point files, copies OrcaJob.sh, EQ.inp etc.
    sourceFolder = sprintf('Conformers%sWs\\Combo%d_Cf%d\\02_characterisation_folder', nature, comboNumber, cfIndex);
    destinationFolder = sprintf('Conformers%sWs\\SPwithPolRight\\Combo%d_Cf%d', nature, comboNumber, cfIndex);
    if ~exist(destinationFolder, 'dir'); mkdir(destinationFolder); end
    copyfile(fullfile(sourceFolder, 'OrcaJob.sh'), destinationFolder);
    copyfile(fullfile(sourceFolder, sprintf('Combo%d_Cf%d_EQ.inp', comboNumber, cfIndex)), destinationFolder);
end