clearvars; close all; clc;
cd 'C:\Users\55fed\OneDrive - Politecnico di Torino\Dottorato\Molecules_DB\DFTB\the-molecular-suite-developer2\autochar\LUFFY'

% Load parameters from GUI
params = LUFFY_GUI();

% Unpack into your variables
max_indexCf       = params.max_indexCf;
min_indexCf       = params.min_indexCf;
LUFFYsimulation   = params.LUFFYsimulation;
LUFFYload         = params.LUFFYload;
LUFFYanalysis     = params.LUFFYanalysis;
SP                = params.SP;
analysis          = params.analysis;
ck                = params.ck;
opt               = params.opt;
set_VACT_analysis = params.set_VACT_analysis;
numberofAtoms     = params.numberofAtoms;
ckValue           = params.ckValue;
charge            = params.charge;
mult              = params.mult;
nprocs            = params.nprocs;
singleSPanalysis  = params.singleSPanalysis;
extract_conf = params.extract_conf;
moleculeName = sprintf('DatabaseMol\\%s', params.moleculeShortName);
VACTanalysisName = params.VACTanalysisName;
disp('✅ Parameters successfully loaded from GUI.');

basePath = 'C:\Users\55fed\OneDrive - Politecnico di Torino\Dottorato\Molecules_DB\DFTB\the-molecular-suite-developer2\autochar\LUFFY';
charAtomsMatrix = readmatrix("C:\Users\55fed\OneDrive - Politecnico di Torino\Dottorato\Molecules_DB\DFTB\the-molecular-suite-developer2\autochar\LUFFY\CharAtomsForSingle.txt");
if extract_conf 
    inputFile =fullfile(basePath,moleculeName, "conformers","crest_conformers.xyz"); 
    outPath = fullfile(basePath,moleculeName, "conformers");
    ExtractConformers(inputFile,outPath,numberofAtoms);
else
for kk = min_indexCf:max_indexCf
    conformers_number = kk;
    if LUFFYsimulation
        runLUFFYsimulation(moleculeName, conformers_number, SP, analysis, opt, ck, ...
            ckValue, basePath, VACTanalysisName, charAtomsMatrix, ...
            charge, mult, nprocs, set_VACT_analysis);
    elseif LUFFYload
        loadData(basePath, moleculeName, opt, SP, set_VACT_analysis, VACTanalysisName);
    elseif LUFFYanalysis
        if analysis
            settings = initSettings(moleculeName, conformers_number, charAtomsMatrix, opt, charge, mult, nprocs);
            runAnalysis(settings,basePath,moleculeName,VACTanalysisName,conformers_number); %run VACT characterisation
        end        
    end  
end
if singleSPanalysis
    analyzeSingleMolecule(moleculeName, min_indexCf, max_indexCf) %run standalone SP analysis
end
end

