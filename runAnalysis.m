function runAnalysis(settings,basePath,moleculeName,VACTanalysisName,conformers_number)
%RUNANALYSIS Run the analysis workflow with autochar
%
%   runAnalysis(settings)
%
%   Takes the settings struct and calls the appropriate autochar steps.

    fprintf(">> Running analysis for %s\n", moleculeName);
    % Example options (can be parametrized)
    opt_dipole   = 1;   % analyse dipole alignment
    opt_vout     = 1;   % analyse output potential
    opt_dipole_z = 0;   % ignore dipole z-component
    opt_dipole_y = 1;   % include dipole y-component

    % Initialise error collectors (optional, can be passed in/out)
    errors_x = []; errors_y = []; errors_z = [];

        % Standard characteristics analysis
        % [assoctable, errors_x, errors_y, errors_z] = ...
        %     S3_AnalyseCharacteristics(settings, errors_x, errors_y, errors_z);

        % Extended analysis with options
        [assoctable, errors_x, errors_y, errors_z] = ...
            S3_AnalyseCharacteristicsPerturbative(settings, opt_dipole, opt_vout, ...
                                          opt_dipole_z, opt_dipole_y, ...
                                          errors_x, errors_y, errors_z,VACTanalysisName,moleculeName,conformers_number);

        % Save results table
        fileName    = sprintf('%s_Cf%d.txt', VACTanalysisName,conformers_number);
        filePath    = fullfile(basePath,moleculeName, fileName);
        
        writetable(assoctable, filePath);
        fprintf("   Results saved to %s\n", filePath);
        disp("Analyse the modelling results and then press ENTER")
        pause;
        close all
        
end
