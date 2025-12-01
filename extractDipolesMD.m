function dipole_vecs = extractDipolesMD(xyz_filename, out_filename, ACListAtoms, frame_idx_max)

    % Costanti fisiche
    e = 1.60217662e-19;         % carica dell'elettrone [C]
    ang_to_m = 1e-10;           % conversione Angstrom -> m
    Debye_conv = 3.33564e-30;   % 1 Debye = 3.33564e-30 C·m

    % Tabella masse atomiche (può essere espansa)
    masses_table = containers.Map( ...
        {'H','C','N','O','S','P','Cl','F','Br','I'}, ...
        [1.0079, 12.0107, 14.0067, 15.999, 32.065, 30.9738, 35.453, 18.998, 79.904, 126.904]);

    % === Lettura file .xyz ===
    fid_xyz = fopen(xyz_filename, 'r');
    xyz_data = {};
    while ~feof(fid_xyz)
        n_atoms = str2double(fgetl(fid_xyz));
        fgetl(fid_xyz); % comment line
        coords = zeros(n_atoms, 3);
        elements = strings(n_atoms,1);
        masses = zeros(n_atoms,1);
        for i = 1:n_atoms
            line = fgetl(fid_xyz);
            data = strsplit(strtrim(line));
            elements(i) = data{1};
            coords(i,:) = str2double(data(2:4));
            if isKey(masses_table, elements(i))
                masses(i) = masses_table(elements(i));
            else
                error(['Elemento non definito nelle masse: ', elements(i)]);
            end
        end
        xyz_data{end+1} = struct('coords', coords, 'elements', elements, 'masses', masses);
    end
    fclose(fid_xyz);

    % === Lettura .out e calcolo dipolo ===
    lines = readlines(out_filename);
    dipole_vecs = [];
    idx = 1;

    while idx <= numel(lines)
        if contains(lines(idx), 'CHELPG Charges')
            idx = idx + 2;
            charges = [];
            while idx <= numel(lines) && ~isempty(strtrim(lines(idx))) && contains(lines(idx), ':')
                tokens = regexp(lines(idx), '\d+\s+\w+\s+:\s+(-?\d+\.\d+)', 'tokens');
                if ~isempty(tokens)
                    charges(end+1) = str2double(tokens{1});
                end
                idx = idx + 1;
            end

            frame_idx = size(dipole_vecs,1) + 1;
            if frame_idx > frame_idx_max
                break;
            end

            coords = xyz_data{frame_idx}.coords;
            masses = xyz_data{frame_idx}.masses;

            % Centro di massa
            total_mass = sum(masses);
            r_cm = sum(coords .* masses, 1) / total_mass;

            % Calcolo momento di dipolo
            mu = [0 0 0];
            for i = 1:length(charges)
                r = coords(i,:) - r_cm;
                mu = mu + charges(i) * e * r * ang_to_m;
            end
            dipole_vecs(end+1,:) = mu / Debye_conv;
        else
            idx = idx + 1;
        end
    end
time_fs = linspace(1,frame_idx_max,frame_idx_max);
%     === Plot componenti del dipolo ===
figure;
% Definizione dei colori scuri con trasparenza (alpha = 0.4)
darkRed = [0.5, 0, 0, 0.4];
darkGreen = [0, 0.4, 0, 0.4];
darkBlue = [0, 0, 0.5, 0.4];
% Plot con colori RGBA
plot(time_fs .* 0.3, dipole_vecs(:,1), 'LineWidth', 3, ...
     'Color', darkRed, 'DisplayName', '\mu_x'); hold on;
plot(time_fs .* 0.3, dipole_vecs(:,2), 'LineWidth', 3, ...
     'Color', darkGreen, 'DisplayName', '\mu_y');
plot(time_fs .* 0.3, dipole_vecs(:,3), 'LineWidth', 3, ...
     'Color', darkBlue, 'DisplayName', '\mu_z');
xlim([min(time_fs)*0.3 max(time_fs)*0.3]);

end
