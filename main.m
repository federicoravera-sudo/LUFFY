clearvars; close all;

% ==== Parameters ====
A = [3];       % conformers
B = [30];      % molecule IDs
max_indexCf = 3; min_indexCf = 1;
new = 0; SP = 0; analysis = 1; ck = 0; opt = 0;
nature = "Ox";

% ==== Paths ====
basePath = 'C:\Users\55fed\OneDrive - Politecnico di Torino\Dottorato\Molecules_DB\DFTB';

% ==== Initialization ====
charAtomsMatrix = readmatrix("...\CharAtomsForSingle.txt");

for kk = 1:length(A)
    conformers_number = A(kk);
    comboNumber = B(kk);

    % 1. Prepare conformers and jobs
    prepareConformers(comboNumber, conformers_number, nature, ...
        new, SP, analysis, opt, ck, basePath);

    % 2. Loop over conformers and configure autochar
    for ii = min_indexCf:max_indexCf
        if ii > 0
            settings = initSettings(comboNumber, ii, nature, charAtomsMatrix(kk,:));
            configureAutochar(settings);

            % 3. Run analysis if required
            if analysis
                runAnalysis(settings);
            end

            % 4. SP workflow
            if SP
                prepareSP(comboNumber, ii, nature, basePath);
            end
        end
    end
end