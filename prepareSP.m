function prepareSP(moleculeName, conformers_number, basePath,VACTanalysisName)
    % Prepares Single Point files, copies OrcaJob.sh, EQ.inp etc.,
    % and creates a new .inp file from a template
    sourceFolder = fullfile(basePath, moleculeName, sprintf('Cf%d', conformers_number), VACTanalysisName);
    destinationFolder = fullfile(basePath, moleculeName, sprintf('Cf%d', conformers_number), 'sp_folder');
    if ~exist(destinationFolder, 'dir')
        mkdir(destinationFolder);
    end
    molShort = regexp(moleculeName, '[^\\\/]+$', 'match', 'once');
    templateFile = fullfile(sourceFolder, sprintf('%s_Cf%dTEMPLATE.inp', molShort, conformers_number));
    newFile = fullfile(destinationFolder, sprintf('%s_Cf%d_EQ.inp', molShort, conformers_number));
    copyfile(fullfile(sourceFolder, 'OrcaJob.sh'), destinationFolder);
    if ~isfile(newFile)
        fid_new = fopen(newFile, 'w');
        if fid_new == -1
            error('Impossibile creare il file: %s', newFile);
        end
        fclose(fid_new);
        fprintf('Creato nuovo file: %s\n', newFile);
    else
        fprintf('File già esistente: %s\n', newFile);
    end
    if isfile(templateFile)
        fid_in = fopen(templateFile, 'r');
        lines = textscan(fid_in, '%s', 'Delimiter', '\n', 'Whitespace', '');
        fclose(fid_in);
        lines = lines{1};

        % --- Remove "OPT" from the first line (case-insensitive)
        if ~isempty(lines)
            lines{2} = regexprep(lines{2}, '\<OPT\>', '', 'ignorecase');
            lines{2} = strtrim(lines{2}); % clean up extra spaces
        end

        % --- Write the modified content to the new file
        fid_out = fopen(newFile, 'w');
        fprintf(fid_out, '%s\n', lines{:});
        fclose(fid_out);

        fprintf('Creato file: %s\n', newFile);
    else
        warning('Template file non trovato: %s', templateFile);
    end

end
