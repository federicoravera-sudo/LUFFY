function analyzeSingleMolecule(moleculeName, min_index, max_index)
    % ====================================================================
    % Reads dipole moment, polarizability, and energy values from
    % ORCA SP output files in each Cf* folder of the given molecule.
    % Plots results for all conformers.
    %
    % INPUTS:
    %   moleculeName - e.g. "DatabaseMol\\Diferrocenylcarborane"
    %   min_index, max_index - range of conformers to analyze
    %
    % The function expects each file:
    %   <shortName>_Cf%d_EQ.out
    % to exist under:
    %   <basePath>\LUFFY\<moleculeName>\Cf%d\sp_folder
    % ====================================================================

    % === Base path ===
    basePath = "C:\Users\55fed\OneDrive - Politecnico di Torino\Dottorato\" + ...
               "Molecules_DB\DFTB\the-molecular-suite-developer2\autochar\LUFFY";

    % === Extract short molecule name ===
    shortName = regexp(moleculeName, '[^\\\/]+$', 'match', 'once');

    % === Initialize arrays ===
    dipoleX = [];
    dipoleY = [];
    dipoleZ = [];
    polariz = [];
    energy  = [];

    % === Loop over conformers ===
    for cf = min_index:max_index
        spFolder = fullfile(basePath, moleculeName, sprintf('Cf%d', cf), 'sp_folder');
        outFile = fullfile(spFolder, sprintf('%s_Cf%d_EQ.out', shortName, cf));

        if ~isfile(outFile)
            fprintf('⚠️ File not found: %s\n', outFile);
            continue;
        end

        % --- Read file lines
        fid = fopen(outFile, 'r');
        txt = textscan(fid, '%s', 'Delimiter', '\n');
        fclose(fid);
        lines = txt{1};

        % --- Parse Total Dipole Moment line
        dipLineIdx = find(contains(lines, 'Total Dipole Moment'), 1);
        if ~isempty(dipLineIdx)
            vals = sscanf(lines{dipLineIdx}, 'Total Dipole Moment    : %f %f %f');
            % Convert to Debye (1 a.u. = 2.541746 D)
            dipoleX(end+1) = vals(1) * 2.541746;
            dipoleY(end+1) = vals(2) * 2.541746;
            dipoleZ(end+1) = vals(3) * 2.541746;
        else
            dipoleX(end+1) = NaN;
            dipoleY(end+1) = NaN;
            dipoleZ(end+1) = NaN;
        end

        % --- Parse Isotropic Polarizability
        polIdx = find(contains(lines, 'Isotropic polarizability'), 1);
        if ~isempty(polIdx)
            val = sscanf(lines{polIdx}, 'Isotropic polarizability : %f');
            polariz(end+1) = val;
        else
            polariz(end+1) = NaN;
        end

        % --- Parse FINAL SINGLE POINT ENERGY
        enIdx = find(contains(lines, 'FINAL SINGLE POINT ENERGY'), 1);
        if ~isempty(enIdx)
            val = sscanf(lines{enIdx}, 'FINAL SINGLE POINT ENERGY %f');
            energy(end+1) = val;
        else
            energy(end+1) = NaN;
        end
    end

    % === Create plots ===
    figure('Name', ['Analysis - ' shortName], 'Position', [200 100 800 600]);

    subplot(3,1,1);
    bar(dipoleX);
    title(['Dipole X (' shortName ')']);
    ylabel('Debye');
    xlabel('Conformer index');

    subplot(3,1,2);
    bar(dipoleY);
    title(['Dipole Y (' shortName ')']);
    ylabel('Debye');
    xlabel('Conformer index');

    subplot(3,1,3);
    bar(polariz);
    title(['Isotropic Polarizability (' shortName ')']);
    ylabel('a.u.');
    xlabel('Conformer index');

    sgtitle(['Single-Point Analysis for ' shortName]);

    % === Optional: print summary table ===
    T = table((min_index:max_index)', dipoleX', dipoleY', polariz', energy', ...
        'VariableNames', {'Conformer','DipoleX_D','DipoleY_D','Polariz_A3','Energy_eV'});
    disp(T);
end
