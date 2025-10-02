function symmetry_coeffs = compute_symmetry(atom_coords)
    % Media delle coordinate lungo x, y, z
    mean_x = mean(atom_coords(:,1));
    mean_y = mean(atom_coords(:,2));
    mean_z = mean(atom_coords(:,3));

    % Calcola il coefficiente di simmetria per ciascun asse
    Sx = sum(abs(atom_coords(:,1) - mean_x)) / size(atom_coords,1);
    Sy = sum(abs(atom_coords(:,2) - mean_y)) / size(atom_coords,1);
    Sz = sum(abs(atom_coords(:,3) - mean_z)) / size(atom_coords,1);

    symmetry_coeffs = [Sx; Sy; Sz];
end