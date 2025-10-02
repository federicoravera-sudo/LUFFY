function F = flatness_coefficient(atom_coords)
    % Numero di atomi
    N = size(atom_coords, 1);

    % Calcolo dei raggi di girazione
    Rg_xy = sqrt(sum(atom_coords(:,1).^2 + atom_coords(:,2).^2) / N); % Solo xy
    Rg = sqrt(sum(atom_coords(:,1).^2 + atom_coords(:,2).^2 + atom_coords(:,3).^2) / N); % 3D

    % Coefficiente di piattezza
    F = Rg_xy / Rg;
end