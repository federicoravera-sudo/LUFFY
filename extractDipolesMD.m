function dipole_vecs = extractDipolesMD( ...
    xyz_filename, out_filename, ACListAtoms, frame_idx_max)

    %#ok<INUSD>
    % ACListAtoms è mantenuto per compatibilità con la GUI,
    % ma non viene utilizzato in questa versione della funzione.

    % ==============================================================
    % Costanti fisiche
    % ==============================================================
    elementary_charge = 1.60217662e-19;   % [C]
    angstrom_to_m = 1.0e-10;              % [m/Angstrom]
    debye_to_Cm = 3.33564e-30;            % [C*m/Debye]
    timestep_fs = 0.3;                     % intervallo temporale tra frame [fs]

    % ==============================================================
    % Masse atomiche
    % ==============================================================
    masses_table = containers.Map( ...
        {'H', 'C', 'N', 'O', 'S', 'P', 'Cl', 'F', 'Br', 'I'}, ...
        [1.0079, 12.0107, 14.0067, 15.999, 32.065, ...
         30.9738, 35.453, 18.998, 79.904, 126.904]);

    % ==============================================================
    % Controllo file di input
    % ==============================================================
    if ~isfile(xyz_filename)
        error('File XYZ non trovato: %s', xyz_filename);
    end

    if ~isfile(out_filename)
        error('File OUT non trovato: %s', out_filename);
    end

    if nargin < 4 || isempty(frame_idx_max)
        frame_idx_max = inf;
    end

    if ~isscalar(frame_idx_max) || frame_idx_max <= 0
        error('frame_idx_max deve essere uno scalare positivo.');
    end

    % ==============================================================
    % Lettura traiettoria XYZ
    % ==============================================================
    fid_xyz = fopen(xyz_filename, 'r');

    if fid_xyz == -1
        error('Impossibile aprire il file XYZ: %s', xyz_filename);
    end

    cleanup_xyz = onCleanup(@() fclose(fid_xyz));

    xyz_data = {};
    xyz_frame_idx = 0;

    while true
        atom_count_line = fgetl(fid_xyz);

        if ~ischar(atom_count_line)
            break;
        end

        atom_count_line = strtrim(atom_count_line);

        % Ignora eventuali righe vuote tra i frame
        if isempty(atom_count_line)
            continue;
        end

        n_atoms = str2double(atom_count_line);

        if isnan(n_atoms) || n_atoms <= 0 || mod(n_atoms, 1) ~= 0
            error( ...
                'Formato XYZ non valido: numero di atomi non valido al frame %d.', ...
                xyz_frame_idx + 1);
        end

        % Riga di commento
        comment_line = fgetl(fid_xyz);

        if ~ischar(comment_line)
            error( ...
                'File XYZ incompleto: manca la riga di commento al frame %d.', ...
                xyz_frame_idx + 1);
        end

        coords = zeros(n_atoms, 3);
        elements = strings(n_atoms, 1);
        masses = zeros(n_atoms, 1);

        for atom_idx = 1:n_atoms
            atom_line = fgetl(fid_xyz);

            if ~ischar(atom_line)
                error( ...
                    'File XYZ incompleto al frame %d, atomo %d.', ...
                    xyz_frame_idx + 1, atom_idx);
            end

            data = strsplit(strtrim(atom_line));

            if numel(data) < 4
                error( ...
                    'Riga XYZ non valida al frame %d, atomo %d.', ...
                    xyz_frame_idx + 1, atom_idx);
            end

            element = string(data{1});
            atom_coords = str2double(data(2:4));

            if any(isnan(atom_coords))
                error( ...
                    'Coordinate non valide al frame %d, atomo %d.', ...
                    xyz_frame_idx + 1, atom_idx);
            end

            if ~isKey(masses_table, char(element))
                error( ...
                    'Elemento non definito nella tabella delle masse: %s', ...
                    element);
            end

            elements(atom_idx) = element;
            coords(atom_idx, :) = atom_coords;
            masses(atom_idx) = masses_table(char(element));
        end

        xyz_frame_idx = xyz_frame_idx + 1;

        xyz_data{xyz_frame_idx} = struct( ...
            'coords', coords, ...
            'elements', elements, ...
            'masses', masses); %#ok<AGROW>
    end

    n_xyz_frames = numel(xyz_data);

    if n_xyz_frames == 0
        error('Nessun frame valido trovato nel file XYZ.');
    end

    % Limita il numero massimo richiesto ai frame realmente disponibili
    n_frames_requested = min(floor(frame_idx_max), n_xyz_frames);

    if frame_idx_max > n_xyz_frames
        warning( ...
            ['frame_idx_max = %d, ma il file XYZ contiene solo %d frame. ', ...
             'L''analisi verrà limitata a %d frame.'], ...
            frame_idx_max, n_xyz_frames, n_frames_requested);
    end

    % ==============================================================
    % Lettura file OUT e calcolo del dipolo
    % ==============================================================
    lines = readlines(out_filename);

    % Preallocazione: al massimo un dipolo per frame XYZ richiesto
    dipole_vecs = nan(n_frames_requested, 3);

    line_idx = 1;
    extracted_frames = 0;
    chelpg_blocks_found = 0;

    while line_idx <= numel(lines)

        if contains(lines(line_idx), 'CHELPG Charges')

            chelpg_blocks_found = chelpg_blocks_found + 1;

            % Salta intestazione e separatore del blocco CHELPG
            line_idx = line_idx + 2;

            charges = [];

            while line_idx <= numel(lines)
                current_line = strtrim(lines(line_idx));

                if current_line == "" || ~contains(current_line, ':')
                    break;
                end

                tokens = regexp( ...
                    current_line, ...
                    '^\s*\d+\s+\w+\s*:\s*([-+]?\d*\.?\d+(?:[Ee][-+]?\d+)?)', ...
                    'tokens', ...
                    'once');

                if ~isempty(tokens)
                    charges(end + 1, 1) = str2double(tokens{1}); %#ok<AGROW>
                end

                line_idx = line_idx + 1;
            end

            % Se abbiamo già elaborato tutti i frame disponibili, interrompi
            if extracted_frames >= n_frames_requested
                break;
            end

            frame_idx = extracted_frames + 1;

            coords = xyz_data{frame_idx}.coords;
            masses = xyz_data{frame_idx}.masses;
            n_atoms_xyz = size(coords, 1);
            n_charges = numel(charges);

            if n_charges ~= n_atoms_xyz
                warning( ...
                    ['Frame %d ignorato: trovate %d cariche CHELPG, ', ...
                     'ma la geometria XYZ contiene %d atomi.'], ...
                    frame_idx, n_charges, n_atoms_xyz);

                continue;
            end

            % ----------------------------------------------------------
            % Centro di massa
            % ----------------------------------------------------------
            total_mass = sum(masses);
            r_cm = sum(coords .* masses, 1) / total_mass;

            % ----------------------------------------------------------
            % Momento di dipolo rispetto al centro di massa
            % ----------------------------------------------------------
            relative_coords = coords - r_cm;

            % charges è in unità di carica elementare;
            % coords è in Angstrom.
            mu_Cm = sum( ...
                charges .* relative_coords, ...
                1) ...
                * elementary_charge ...
                * angstrom_to_m;

            % Conversione C*m -> Debye
            dipole_vecs(frame_idx, :) = mu_Cm / debye_to_Cm;

            extracted_frames = extracted_frames + 1;

        else
            line_idx = line_idx + 1;
        end
    end

    % Rimuove eventuali righe preallocate non utilizzate
    dipole_vecs = dipole_vecs(1:extracted_frames, :);

    if extracted_frames == 0
        error( ...
            'Nessun blocco CHELPG valido è stato associato ai frame XYZ.');
    end

    if chelpg_blocks_found > n_xyz_frames
        warning( ...
            ['Il file OUT contiene %d blocchi CHELPG, mentre il file XYZ ', ...
             'contiene %d frame. I blocchi CHELPG in eccesso sono stati ignorati.'], ...
            chelpg_blocks_found, n_xyz_frames);
    elseif chelpg_blocks_found < n_xyz_frames
        warning( ...
            ['Il file OUT contiene %d blocchi CHELPG, mentre il file XYZ ', ...
             'contiene %d frame. Sono stati estratti solo %d dipoli.'], ...
            chelpg_blocks_found, n_xyz_frames, extracted_frames);
    end

    % ==============================================================
    % Asse temporale
    % ==============================================================
    time_fs = (0:extracted_frames - 1)' * timestep_fs;

    % ==============================================================
    % Plot componenti del dipolo
    % ==============================================================
    figure;

    % MATLAB non supporta sempre colori RGBA nelle linee.
    % Uso quindi colori RGB compatibili.
    darkRed = [0.5, 0.0, 0.0];
    darkGreen = [0.0, 0.4, 0.0];
    darkBlue = [0.0, 0.0, 0.5];

    plot( ...
        time_fs, ...
        dipole_vecs(:, 1), ...
        'LineWidth', 3, ...
        'Color', darkRed, ...
        'DisplayName', '\mu_x');

    hold on;

    plot( ...
        time_fs, ...
        dipole_vecs(:, 2), ...
        'LineWidth', 3, ...
        'Color', darkGreen, ...
        'DisplayName', '\mu_y');

    plot( ...
        time_fs, ...
        dipole_vecs(:, 3), ...
        'LineWidth', 3, ...
        'Color', darkBlue, ...
        'DisplayName', '\mu_z');

    hold off;

    xlabel('Time (fs)');
    ylabel('Dipole moment (D)');
    legend('Location', 'best');
    grid on;
    box on;

    if extracted_frames > 1
        xlim([time_fs(1), time_fs(end)]);
    end

    fprintf( ...
        ['Dipoli estratti: %d\n', ...
         'Frame XYZ disponibili: %d\n', ...
         'Blocchi CHELPG trovati: %d\n', ...
         'Intervallo temporale: %.1f - %.1f fs\n'], ...
        extracted_frames, ...
        n_xyz_frames, ...
        chelpg_blocks_found, ...
        time_fs(1), ...
        time_fs(end));

end