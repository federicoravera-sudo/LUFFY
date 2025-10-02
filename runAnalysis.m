function runAnalysis(settings)
%RUNANALYSIS Run the analysis workflow with autochar
%
%   runAnalysis(settings)
%
%   Takes the settings struct and calls the appropriate autochar steps.

    fprintf(">> Running analysis for %s\n", settings.MOLECULE_NAME);

    % Make sure autochar is in the path
    addpath('\autochar');
    cd('\autochar');

    % Example options (can be parametrized)
    opt_dipole   = 1;   % analyse dipole alignment
    opt_vout     = 1;   % analyse output potential
    opt_dipole_z = 0;   % ignore dipole z-component
    opt_dipole_y = 1;   % include dipole y-component

    % Initialise error collectors (optional, can be passed in/out)
    errors_x = []; errors_y = []; errors_z = [];

    % ---- Choose analysis routine ----
    try
        % Standard characteristics analysis
        % [assoctable, errors_x, errors_y, errors_z] = ...
        %     S3_AnalyseCharacteristics(settings, errors_x, errors_y, errors_z);

        % Extended analysis with options
        [assoctable, errors_x, errors_y, errors_z] = ...
            S3_AnalyseCharacteristicsFEDE(settings, opt_dipole, opt_vout, ...
                                          opt_dipole_z, opt_dipole_y, ...
                                          errors_x, errors_y, errors_z);

        % Save results table
        baseDirOut  = sprintf('C:\\Users\\55fed\\OneDrive - Politecnico di Torino\\Dottorato\\Molecules_DB\\DFTB\\the-molecular-suite-developer2\\autochar\\%s', settings.WORKSPACE);
        fileName    = sprintf('%s_SemiStatic_ck-1.txt', settings.MOLECULE_NAME);
        filePath    = fullfile(baseDirOut, fileName);

        writetable(assoctable, filePath);
        fprintf("   Results saved to %s\n", filePath);

    catch ME
        warning("Analysis failed for %s: %s", settings.MOLECULE_NAME, ME.message);
    end
end
