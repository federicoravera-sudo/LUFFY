function parallelism_coeff = compute_parallelism(atom_coords, plot_flag)
    % Selezioniamo i punti con y > 0 e y < 0
    pos_group = atom_coords(atom_coords(:,2) > 0, :);
    neg_group = atom_coords(atom_coords(:,2) < 0, :);

    % Se uno dei due gruppi è vuoto, non possiamo calcolare il parallelismo
    if isempty(pos_group) || isempty(neg_group)
        parallelism_coeff = NaN;
        warning('Uno dei due gruppi è vuoto. Parallelismo non definito.');
        return;
    end

    % Analisi delle Componenti Principali (PCA) per trovare la direzione dominante
    [~, ~, V_pos] = pca(pos_group);
    [~, ~, V_neg] = pca(neg_group);

    % Direzioni principali dei due gruppi (vettori principali della PCA)
    dir_pos = V_pos(:,1);
    dir_neg = V_neg(:,1);

    % Calcoliamo l'angolo tra le due direzioni
    cos_theta = dot(dir_pos, dir_neg) / (norm(dir_pos) * norm(dir_neg));
    theta = acosd(cos_theta); % Convertiamo in gradi

    % Coefficiente di parallelismo (coseno dell'angolo)
    parallelism_coeff = abs(cos_theta);

    % Se richiesto, plottiamo il grafico
    if plot_flag
        figure;
        hold on;
        grid on;
        xlabel('X'); ylabel('Y'); zlabel('Z');
        title('Parallelismo tra Y > 0 e Y < 0');
        axis equal;

        % Plot delle coordinate originali
        scatter3(pos_group(:,1), pos_group(:,2), pos_group(:,3), 80, 'b', 'filled', 'DisplayName', 'Y > 0');
        scatter3(neg_group(:,1), neg_group(:,2), neg_group(:,3), 80, 'r', 'filled', 'DisplayName', 'Y < 0');

        % Plot delle direzioni principali
        quiver3(0, 0, 0, dir_pos(1), dir_pos(2), dir_pos(3), 3, 'b', 'LineWidth', 2, 'DisplayName', 'Direzione Y > 0');
        quiver3(0, 0, 0, dir_neg(1), dir_neg(2), dir_neg(3), 3, 'r', 'LineWidth', 2, 'DisplayName', 'Direzione Y < 0');

        legend;
        hold off;
    end
end