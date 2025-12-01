function extract_LUFFY_toDatabase(moleculeName, B, moleculeType)
% ============================================================
% extract_LUFFY_toDatabase
%
% Extracts data from ORCA output files in LUFFY database
% and appends results to a global Excel file.
%
% INPUTS:
%   moleculeName  = molecule folder name (e.g. 'Combo17')
%   B             = number of conformers (e.g. 12)
%   moleculeType  = 'Ox' or 'Neutral'
%
% OUTPUT:
%   Appends extracted data to DatabaseOx.xlsx or DatabaseNeutral.xlsx
% ============================================================

    % === Check inputs ===
    if nargin < 3
        error('Usage: extract_LUFFY_toDatabase(moleculeName, B, moleculeType)');
    end
    if ~ismember(moleculeType, {'Oxidized', 'Neutral'})
        error('moleculeType must be ''Oxidized'' or ''Neutral''.');
    end

    % === Base path ===
    base_dir = 'C:\Users\55fed\OneDrive - Politecnico di Torino\Dottorato\Molecules_DB\DFTB\the-molecular-suite-developer2\autochar\LUFFY\DatabaseMol\';

    % === Output file depends on molecule type ===
    switch moleculeType
        case 'Oxidized'
            excel_file = fullfile(base_dir, 'DatabaseOx.xlsx');
        case 'Neutral'
            excel_file = fullfile(base_dir, 'DatabaseNeutral.xlsx');
    end

    % === Regex definitions ===
    regexEnergy = 'FINAL SINGLE POINT ENERGY\s+([-+]?\d*\.\d+)';
    regexDipole = 'Total Dipole Moment\s*:\s*([-+]?\d*\.\d+)\s+([-+]?\d*\.\d+)\s+([-+]?\d*\.\d+)';
    regexHOMO = '\d+\s+1\.0000\s+[-+]?\d*\.\d+\s+([-+]?\d*\.\d+)';
    regexLUMO = '\d+\s+0\.0000\s+[-+]?\d*\.\d+\s+([-+]?\d*\.\d+)';
    regexPolarizabilityIsotropic = 'Isotropic polarizability\s*:\s*([-+]?\d*\.\d+)';
    regexTensor = 'diagonalized tensor:([\s\S]+?)Isotropic polarizability';
    regexCartesianTensor = 'raw cartesian tensor \(atomic units\):([\s\S]+?)diagonalized tensor';

    % === Create Excel file if not existing ===
    if ~isfile(excel_file)
        header = {'Molecule', 'Conformer', 'Single Point Energy (eV)', ...
                  'Dipole X', 'Dipole Y', 'Dipole Z', ...
                  'HOMO', 'LUMO', 'HOMO-LUMO gap', ...
                  'Polarizability Isotropic', ...
                  'Polarizability Tensor Diagonalized', ...
                  'Cartesian Tensor'};
        writecell(header, excel_file, 'Sheet', 1, 'Range', 'A1');
        nextRow = 2;
    else
        [~,~,raw] = xlsread(excel_file);
        nextRow = size(raw,1) + 1;
    end

    % === Loop over conformers ===
    for jj = 1:B
        src_dir = sprintf('%s\\%s\\Cf%d\\sp_folder\\', base_dir, moleculeName, jj);
        src_file = sprintf('%s%s_Cf%d_EQ.out', src_dir, moleculeName, jj);

        if exist(src_file, 'file')
            try
                % Read file
                file_text = fileread(src_file);

                % Extract fields
                energy = regexp(file_text, regexEnergy, 'tokens', 'once');
                dipole = regexp(file_text, regexDipole, 'tokens', 'once');
                lumo_tokens = regexp(file_text, regexLUMO, 'tokens', 'once');

                % HOMO from previous line
                homo_val = NaN; lumo_val = NaN;
                if ~isempty(lumo_tokens)
                    lumo_val = str2double(lumo_tokens{1});
                    lines = strsplit(file_text, '\n');
                    lumo_line = find(~cellfun('isempty', regexp(lines, regexLUMO)), 1);
                    if lumo_line > 1
                        prev_line = lines{lumo_line - 1};
                        homo_tokens = regexp(prev_line, regexHOMO, 'tokens', 'once');
                        if ~isempty(homo_tokens)
                            homo_val = str2double(homo_tokens{1});
                        end
                    end
                end

                gap_homo_lumo = homo_val - lumo_val;
                polarizability_isotropic = regexp(file_text, regexPolarizabilityIsotropic, 'tokens', 'once');
                tensor_diagonalized = regexp(file_text, regexTensor, 'tokens', 'once');
                cartesian_tensor = regexp(file_text, regexCartesianTensor, 'tokens', 'once');

                % --- Prepare data row ---
                data_row = {moleculeName, jj, str2double(energy{1}), ...
                            str2double(dipole{1}), str2double(dipole{2}), str2double(dipole{3}), ...
                            homo_val, lumo_val, gap_homo_lumo, ...
                            str2double(polarizability_isotropic{1}), ...
                            tensor_diagonalized{1}, cartesian_tensor{1}};

                % --- Append to Excel ---
                writecell(data_row, excel_file, 'Sheet', 1, ...
                          'Range', sprintf('A%d', nextRow));
                nextRow = nextRow + 1;

            catch ME
                warning('⚠️ Error reading %s_Cf%d: %s', moleculeName, jj, ME.message);
            end
        else
            fprintf('File not found: %s\n', src_file);
        end
    end

    fprintf('✅ Extraction completed for %s (%d conformers) → %s\n', ...
            moleculeName, B, excel_file);
end
