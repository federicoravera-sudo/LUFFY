% function [minMESP, maxMESP] = EvaluateVdWPotential(mol)
% 
% meshPrecision = 51;
% 
% % Define the list of radii
% radii_list = {'C', 1.7; 'H', 1.2; 'N', 1.55; 'F', 1.47; 'O', 1.52; ...
%               'S', 1.8; 'P', 1.8; 'Cl', 1.75; 'Cu', 1.4; 'Fe', 1.4};
% radii = containers.Map({radii_list{:, 1}}, {radii_list{:, 2}});
% 
% % Loop through each atom to generate the spherical surfaces
% atomSurface(mol.n_atoms).x = [];
% atomSurface(mol.n_atoms).y = [];
% atomSurface(mol.n_atoms).z = [];
% 
% % Creazione delle superfici van der Waals
% for aa = 1:mol.n_atoms
%     [atomSurface(aa).x, atomSurface(aa).y, atomSurface(aa).z] = sphere(meshPrecision);
%     radius = radii(mol.element{aa}); 
%     atomSurface(aa).x = atomSurface(aa).x * radius + mol.x(aa);
%     atomSurface(aa).y = atomSurface(aa).y * radius + mol.y(aa);
%     atomSurface(aa).z = atomSurface(aa).z * radius + mol.z(aa);
% end
% 
% % Rimozione dei punti interni alle sfere di altri atomi
% for aa = 1:mol.n_atoms
%     for j = 1:mol.n_atoms
%         if aa ~= j
%             pointToAtomCenterDistance = (atomSurface(aa).x - mol.x(j)).^2 + ...
%                                         (atomSurface(aa).y - mol.y(j)).^2 + ...
%                                         (atomSurface(aa).z - mol.z(j)).^2;
%             radius = radii(mol.element{j});
%             to_be_deleted = find(pointToAtomCenterDistance < radius^2);
%             atomSurface(aa).z(to_be_deleted) = NaN;
%         end
%     end
% end
% 
% % Inizializzazione matrice colori per la superficie di potenziale
% color = zeros(meshPrecision + 1, meshPrecision + 1);
% 
% % Creazione della figura e mantenimento del plot
% figure;
% hold on;
% 
% %  Plot degli atomi come sfere in grigio chiaro
% for aa = 1:mol.n_atoms
%     [sx, sy, sz] = sphere(20);
%     radius = radii(mol.element{aa});
%     surf(radius * sx + mol.x(aa), ...
%          radius * sy + mol.y(aa), ...
%          radius * sz + mol.z(aa), ...
%          'FaceColor', [0.7, 0.7, 0.7], 'EdgeColor', 'none', 'FaceAlpha', 1.0); % Grigio chiaro
% end
% 
% % Plot delle superfici con mappa di colore del potenziale
% for aa = 1:mol.n_atoms
%     for ii = 1:meshPrecision + 1
%         for jj = 1:meshPrecision + 1
%             pos.x = atomSurface(aa).x(ii, jj);
%             pos.y = atomSurface(aa).y(ii, jj);
%             pos.z = atomSurface(aa).z(ii, jj); 
%             color(ii, jj) = EvaluatePotential(mol, pos);
%         end
%     end
%     surf(atomSurface(aa).x, atomSurface(aa).y, atomSurface(aa).z, color, ...
%         'EdgeColor', 'none', 'FaceAlpha', 0.5); % Superfici più luminose
% end
% 
% % Miglioramenti grafici
% colormap('turbo');
% colorbar;
% caxis([min(color, [], 'all'), max(color, [], 'all')]); % Normalizzazione colormap
% lighting gouraud;
% material dull; % Superfici meno scure
% camlight right;
% camlight left;
% 
% % Impostazioni asse
% axis equal;
% xlabel('X-axis');
% ylabel('Y-axis');
% zlabel('Z-axis');
% title('MESP con struttura atomica (migliore visibilità)');
% 
% % Esportazione dei valori min/max del potenziale
% minMESP = min(color, [], 'all');
% maxMESP = max(color, [], 'all');
% 
% hold off;
% end


function [minMESP, maxMESP] = EvaluateVdWPotential(mol)

meshPrecision = 51;

% Define the list of radii
radii_list = {'C', 1.7; 'H', 1.2; 'N', 1.55; 'F', 1.47; 'O', 1.52; 'S', 1.8; 'P', 1.8; 'Cl', 1.75; 'Cu', 1.4; 'Fe', 1.4};
radii = containers.Map({radii_list{:, 1}}, {radii_list{:, 2}});

% Loop through each atom to generate the spherical surfaces
atomSurface(mol.n_atoms).x = [];
atomSurface(mol.n_atoms).y = [];
atomSurface(mol.n_atoms).z = [];

for aa = 1:mol.n_atoms
    % Create a grid of points for the sphere
    [atomSurface(aa).x, atomSurface(aa).y, atomSurface(aa).z] = sphere(meshPrecision);
    
    % Determine van der Waals radius
    radius = radii(mol.element{aa}); 

    % Scale the grid by the current radius and translate it to the current point
    atomSurface(aa).x = atomSurface(aa).x * radius + mol.x(aa);
    atomSurface(aa).y = atomSurface(aa).y * radius + mol.y(aa);
    atomSurface(aa).z = atomSurface(aa).z * radius + mol.z(aa);
end

% Loop through spheres to remove internal points
for aa = 1:mol.n_atoms
    for j = 1:mol.n_atoms
        if aa ~= j
            pointToAtomCenterDistance = (atomSurface(aa).x - mol.x(j)).^2 + ...
                                        (atomSurface(aa).y - mol.y(j)).^2 + ...
                                        (atomSurface(aa).z - mol.z(j)).^2;
            radius = radii(mol.element{j});
            to_be_deleted = find(pointToAtomCenterDistance < radius^2); 
            atomSurface(aa).z(to_be_deleted) = NaN;
        end
    end
end

% Initialize color matrix for the potential
color = zeros(meshPrecision + 1, meshPrecision + 1);

% Plot the spherical surface
figure;
hold on;
for aa = 1:mol.n_atoms
    for ii = 1:meshPrecision + 1
        for jj = 1:meshPrecision + 1
            pos.x = atomSurface(aa).x(ii, jj);
            pos.y = atomSurface(aa).y(ii, jj);
            pos.z = atomSurface(aa).z(ii, jj); 
            color(ii, jj) = EvaluatePotential(mol, pos);
        end
    end
    surf(atomSurface(aa).x, atomSurface(aa).y, atomSurface(aa).z, color, 'EdgeColor', 'none');
end

colormap('turbo');
colorbar;
axis equal;
xlabel('X-axis'); ylabel('Y-axis'); zlabel('Z-axis');
title('MESP & Van der Waals Surface');

% Export min/max MESP
minMESP = min(color, [], 'all');
maxMESP = max(color, [], 'all');

% *Plot della molecola con cariche atomiche e dipoli**
figure(2);
hold on;
scatter3(mol.x, mol.y, mol.z, 100, mol.espCharge, 'filled'); % Usa mol.espCharge per il colore
colormap(jet); 
colorbar;
axis equal;
xlabel('X-axis'); ylabel('Y-axis'); zlabel('Z-axis');
title('Atomic ESP Charges & Dipole Moment');

% **Vettori del dipolo molecolare**
quiver3(0, 0, 0, mol.dipole(1), 0, 0, 'r', 'LineWidth', 2, 'MaxHeadSize', 2); % X
quiver3(0, 0, 0, 0, mol.dipole(2), 0, 'g', 'LineWidth', 2, 'MaxHeadSize', 2); % Y
quiver3(0, 0, 0, 0, 0, mol.dipole(3), 'b', 'LineWidth', 2, 'MaxHeadSize', 2); % Z

legend({'Atoms (ESP Charge)', 'Dipole X', 'Dipole Y', 'Dipole Z'});
hold off;

end



