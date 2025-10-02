function [spec_coeffs, global_symmetry] = compute_specularity_y(atom_coords, plot_flag)
    % Riflettiamo le coordinate lungo ciascun asse

    % Calcola il centro di massa
    com = mean(atom_coords, 1);
    
    % Calcola il raggio di girazione (Rg)
    Rg = mean(sqrt(sum((atom_coords - com).^2, 2)));


    reflected_x = atom_coords; 
    reflected_x(:,1) = -atom_coords(:,1);  % Riflesso rispetto all'asse X

    reflected_y = atom_coords; 
    reflected_y(:,2) = -atom_coords(:,2);  % Riflesso rispetto all'asse Y

    reflected_z = atom_coords; 
    reflected_z(:,3) = -atom_coords(:,3);  % Riflesso rispetto all'asse Z

    % Calcoliamo le differenze tra le coordinate originali e riflesse
    diff_x = atom_coords - reflected_x;
    diff_y = atom_coords - reflected_y;
    diff_z = atom_coords - reflected_z;

    % Distanze euclidee tra coordinate originali e riflesse
    dist_x = sqrt(sum(diff_x.^2, 2));  
    dist_y = sqrt(sum(diff_y.^2, 2));  
    dist_z = sqrt(sum(diff_z.^2, 2));  

    % Coefficienti di simmetria per ogni asse
    Sx = mean(dist_x); 
    Sy = mean(dist_y); 
    Sz = mean(dist_z); 
    % Calcola la distanza massima tra atomi
    Dmax = max(pdist(atom_coords));  % Distanza massima tra coppie di atomi

    % Normalizza i coefficienti di simmetria
    Sx_norm = Sx / Rg;
    Sy_norm = Sy / Rg;
    Sz_norm = Sz / Rg;

    % Coefficiente di simmetria globale normalizzato
    global_symmetry = mean([Sx_norm, Sy_norm, Sz_norm]);

    % Restituisce i coefficienti normalizzati
    spec_coeffs = [Sx_norm; Sy_norm; Sz_norm];

    % Se richiesto, plottiamo il grafico
    if plot_flag
        figure;
        hold on;
        grid on;
        xlabel('X'); ylabel('Y'); zlabel('Z');
        title('Coordinate Originali e Riflesse');
        axis equal;
        
        % Plot delle coordinate originali
        scatter3(atom_coords(:,1), atom_coords(:,2), atom_coords(:,3), 80, 'b', 'filled', 'DisplayName', 'Originale');

        % Plot delle coordinate riflesse
%         scatter3(reflected_x(:,1), reflected_x(:,2), reflected_x(:,3), 50, 'r', 'o', 'DisplayName', 'Riflesso X');
        scatter3(reflected_y(:,1), reflected_y(:,2), reflected_y(:,3), 50, 'g', 'o', 'DisplayName', 'Riflesso Y');
%         scatter3(reflected_z(:,1), reflected_z(:,2), reflected_z(:,3), 50, 'm', 'o', 'DisplayName', 'Riflesso Z');
        
        legend;
        hold off;
    end
end