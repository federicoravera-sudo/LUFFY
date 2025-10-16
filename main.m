clearvars; close all;
cd 'C:\Users\55fed\OneDrive - Politecnico di Torino\Dottorato\Molecules_DB\DFTB\the-molecular-suite-developer2\autochar\LUFFY'
% ==== Parameters ====
max_indexCf = 5; min_indexCf = 1;
new = 0; SP = 0; analysis = 0; ck = 0; opt = 1;
moleculeName = "Diferrocenylcarborane";

% ==== Paths ====
basePath = 'C:\Users\55fed\OneDrive - Politecnico di Torino\Dottorato\Molecules_DB\DFTB\the-molecular-suite-developer2\autochar\LUFFY';

% ==== Initialization ====
charAtomsMatrix = readmatrix("C:\Users\55fed\OneDrive - Politecnico di Torino\Dottorato\Molecules_DB\DFTB\the-molecular-suite-developer2\autochar\LUFFY\CharAtomsForSingle.txt");

for kk = 1:max_indexCf
    conformers_number = kk;

    prepareConformers(moleculeName, conformers_number, SP, analysis, opt, ck, basePath);

    settings = initSettings(moleculeName, kk, charAtomsMatrix, opt);
    
    if opt
        S1_GenerateOptimization(settings);
    end
    % 3. Run analysis if required
    if analysis
        runAnalysis(settings);
    end

    % 4. SP workflow
    if SP
        prepareSP(comboNumber, ii, nature, basePath);
    end
end