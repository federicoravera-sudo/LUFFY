function runLUFFYsimulation(moleculeName, conformers_number, SP, analysis, opt, ck, ...
                            ckValue, basePath, VACTanalysisName, charAtomsMatrix, ...
                            charge, mult, nprocs,set_VACT_analysis)
    % ====================================================================
    % Executes the full LUFFY simulation workflow for a given conformer.
    % Includes preparation, optimization, VACT/SP generation, and analysis.
    %
    % INPUTS:
    %   moleculeName        - string with molecule folder name
    %   conformers_number   - conformer index (integer)
    %   SP                  - flag for single point step
    %   analysis            - flag for final analysis
    %   opt                 - flag for optimization
    %   ck, ckValue         - clock control parameters
    %   basePath            - working base directory
    %   VACTanalysisName    - folder name for VACT analysis
    %   charAtomsMatrix     - matrix of characteristic atoms
    %   charge, mult        - molecular charge and multiplicity
    %   nprocs              - number of processors for parallel tasks
    % ====================================================================

    % === Step 1. Prepare conformer folders and setup ===
    prepareConformers(moleculeName, conformers_number, SP, analysis, opt, ck, ckValue, basePath, VACTanalysisName);

    % === Step 2. Initialize simulation settings ===
    settings = initSettings(moleculeName, conformers_number, charAtomsMatrix, opt, charge, mult, nprocs);

    % === Step 3. Optimization stage ===
    if opt
        S1_GenerateOptimization(settings);
    end

    % === Step 4. Characterization stage (VACT or SP) ===
    if SP || set_VACT_analysis
        settings.VACTanalysisName = VACTanalysisName;
        S2_GenerateCharacteristics(settings,conformers_number);

        % Prepare SP folder and copy required files
        if SP
            prepareSP(moleculeName, conformers_number, basePath, VACTanalysisName);
        end
    end
    fprintf('✅ Finished LUFFY simulation preparation for conformer #%d\n', conformers_number);
end
