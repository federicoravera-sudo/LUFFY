function symmetry_y = compute_y_symmetry(atom_coords, plot_flag)
    % Selezioniamo i punti con y > 0 e y < 0
    pos_group = atom_coords(atom_coords(:,2) > 0, :);
    neg_group = atom_coords(atom_coords(:,2) < 0, :);

    % Riflettiamo i punti con y > 0 rispetto al piano y = 0
    reflected_pos = pos_group;
    reflected_pos(:,2) = -reflected_pos(:,2);

    % Se ci sono punti in entrambi i gruppi, calcoliamo la simmetria
    if isempty(pos_group) || isempty(neg_group)
        symmetry_y = NaN;
        warning('Uno dei due gruppi è vuoto. Simmetria non definita.');
        return;
    end

    % Per ogni punto riflesso, troviamo il punto più vicino nel gruppo negativo
    distances = zeros(size(reflected_pos, 1), 1);
    for i = 1:length(reflected_pos)
        diffs = neg_group - reflected_pos(i, :);
        dists = sqrt(sum(diffs.^2, 2));
        distances(i) = min(dists);
    end

    % Coefficiente di simmetria: distanza media tra punti riflessi e corrispondenti
    symmetry_y = mean(distances);

    % Se richiesto, plottiamo il grafico
    if plot_flag
        figure;
        hold on;
        grid on;
        xlabel('X'); ylabel('Y'); zlabel('Z');
        title('Simmetria rispetto a Y');
        axis equal;
        
        % Plot delle coordinate originali
        scatter3(pos_group(:,1), pos_group(:,2), pos_group(:,3), 80, 'b', 'filled', 'DisplayName', 'Y > 0');
        scatter3(neg_group(:,1), neg_group(:,2), neg_group(:,3), 80, 'r', 'filled', 'DisplayName', 'Y < 0');

        % Plot delle coordinate riflesse
        scatter3(reflected_pos(:,1), reflected_pos(:,2), reflected_pos(:,3), 50, 'g', 'o', 'DisplayName', 'Y > 0 Riflesso');

        legend;
        hold off;
    end
end