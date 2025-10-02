function [distances_Ox, distances_Neutral, sym_coeff_Ox_method1, sym_coeff_Neutral_method1, spec_coeffs_Ox_x,spec_coeffs_Ox_y,spec_coeffs_Ox_z,  spec_coeffs_Neutral_x,spec_coeffs_Neutral_y,spec_coeffs_Neutral_z, global_symmetry_Ox, global_symmetry_Neutral,symmetry_y_Ox, symmetry_y_Neutral, parallelism_coeff_Ox ,parallelism_coeff_Neutral, F_Ox, F_Neutral, rmsd_values] = process_conformers(charAtomsMatrix, A, B, targetA, targetB, nature)
    % Inizializza variabili
    cc = 1;
    cc_N = 1;
    distances_Ox = [];
    distances_Neutral = [];
    sym_coeff_Ox = []; 
    sym_coeff_Neutral = []; 

    % Itera su tutti gli indici in B
    for c = 1:length(B)
        i = B(c);
        combo_name_t = sprintf('Combo%d', i); % Nome della combo
        charValues{i} = charAtomsMatrix(c, 1:2); % I primi due valori (indici degli atomi)
        fprintf('Combo: %s, Char Atoms: [%f, %f]\n', combo_name_t, charValues{i}(1), charValues{i}(2));

        for ii = 1:A(c)
            % Percorso del file XYZ per il conformero Ox
            xyz_file_path = sprintf("C:\\Users\\55fed\\OneDrive - Politecnico di Torino\\Dottorato\\Molecules_DB\\DFTB\\the-molecular-suite-developer2\\autochar\\ConformersOxWs\\SPwithPolRight\\%s_Cf%d\\%s_Cf%d_EQ.inp", combo_name_t, ii, combo_name_t, ii);
            atom_coords = load_xyz_coordinates(xyz_file_path);
            xyz_Ox{ii} = atom_coords;
            % Calcola il coefficiente di simmetria per Ox
            sym_coeff_Ox_method1(:, cc) = compute_symmetry(atom_coords);
            F_Ox(:,cc) = flatness_coefficient(atom_coords);
            if ii == targetA && i == targetB 
                [spec_coeffs_Ox, global_symmetry_Ox(:,cc)] = compute_specularity_y(atom_coords, 1);
                symmetry_y_Ox(:,cc) = compute_y_symmetry(atom_coords, 1); %misura quanto le coordinate y>0 somigliano a y<0
                parallelism_coeff_Ox(:,cc) = compute_parallelism(atom_coords, 1);
            else
                [spec_coeffs_Ox, global_symmetry_Ox(:,cc)] = compute_specularity_y(atom_coords, 0);
                symmetry_y_Ox(:,cc) = compute_y_symmetry(atom_coords, 0); %misura quanto le coordinate y>0 somigliano a y<0
                parallelism_coeff_Ox(:,cc) = compute_parallelism(atom_coords, 0);
            end
            
            spec_coeffs_Ox_x(:,cc) =spec_coeffs_Ox(1);
            spec_coeffs_Ox_y(:,cc) =spec_coeffs_Ox(2);
            spec_coeffs_Ox_z(:,cc) =spec_coeffs_Ox(3);

            % Estrai gli indici degli atomi da charValues
            atom_idx_1 = round(charValues{i}(1)); 
            atom_idx_2 = round(charValues{i}(2));

            % Calcola la distanza Euclidea tra i due atomi
            if atom_idx_1 <= size(atom_coords, 1) && atom_idx_2 <= size(atom_coords, 1)
                x1 = atom_coords(atom_idx_1, 1);
                y1 = atom_coords(atom_idx_1, 2);
                z1 = atom_coords(atom_idx_1, 3);
                x2 = atom_coords(atom_idx_2, 1);
                y2 = atom_coords(atom_idx_2, 2);
                z2 = atom_coords(atom_idx_2, 3);

                distance = sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2);
                distances_Ox(cc) = distance;
                cc = cc + 1;
                fprintf('Distanza Euclidea tra atomi %d e %d: %f per Ox %s, Cf %d\n', atom_idx_1, atom_idx_2, distance, combo_name_t, ii);
            else
                fprintf('Errore: Indici di atomo non validi per Combo %s, Cf %d\n', combo_name_t, ii);
            end
            % Ripeti per la configurazione Neutral
            xyz_file_path_Neutral = sprintf("C:\\Users\\55fed\\OneDrive - Politecnico di Torino\\Dottorato\\Molecules_DB\\DFTB\\the-molecular-suite-developer2\\autochar\\ConformersNeutralWs\\SPwithPolRight\\%s_Cf%d\\%s_Cf%d_EQ.inp", combo_name_t, ii, combo_name_t, ii);
            atom_coords = load_xyz_coordinates(xyz_file_path_Neutral);
            xyz_Neutral{ii} = atom_coords;
            % Calcola il coefficiente di simmetria per Neutral
            sym_coeff_Neutral_method1(:, cc_N) = compute_symmetry(atom_coords);
            [spec_coeffs_Neutral, global_symmetry_Neutral(:,cc_N)] = compute_specularity_y(atom_coords, 0);
            symmetry_y_Neutral(:,cc_N) = compute_y_symmetry(atom_coords, 0); %misura quanto le coordinate y>0 somigliano a y<0
            spec_coeffs_Neutral_x(:,cc_N) =spec_coeffs_Neutral(1);
            spec_coeffs_Neutral_y(:,cc_N) =spec_coeffs_Neutral(2);
            spec_coeffs_Neutral_z(:,cc_N) =spec_coeffs_Neutral(3);
            parallelism_coeff_Neutral(:,cc_N) = compute_parallelism(atom_coords, 0);
            F_Neutral(:,cc_N) = flatness_coefficient(atom_coords);
            diff = xyz_Ox{ii} - xyz_Neutral{ii}; % Differenza tra le coordinate
            squared_diff = diff.^2;            % Elevamento al quadrato
            mean_squared_diff = mean(squared_diff, 'all'); % Media totale
            rmsd_values(cc_N) = sqrt(mean_squared_diff); % Radice quadrata
            % Estrai gli indici degli atomi
            atom_idx_1 = round(charValues{i}(1)); 
            atom_idx_2 = round(charValues{i}(2));

            % Calcola la distanza Euclidea tra i due atomi
            if atom_idx_1 <= size(atom_coords, 1) && atom_idx_2 <= size(atom_coords, 1)
                x1 = atom_coords(atom_idx_1, 1);
                y1 = atom_coords(atom_idx_1, 2);
                z1 = atom_coords(atom_idx_1, 3);
                x2 = atom_coords(atom_idx_2, 1);
                y2 = atom_coords(atom_idx_2, 2);
                z2 = atom_coords(atom_idx_2, 3);

                distance = sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2);
                distances_Neutral(cc_N) = distance;
                cc_N = cc_N + 1;
%                 fprintf('Distanza Euclidea tra atomi %d e %d: %f per Neutral %s, Cf %d\n', atom_idx_1, atom_idx_2, distance, combo_name_t, ii);
            else
                fprintf('Errore: Indici di atomo non validi per Combo %s, Cf %d\n', combo_name_t, ii);
            end

        end

    end

end