function plotScatterTwoVars(group_data, selected_groups, varX, varY)
    % Colori predefiniti (rosso scuro, blu scuro, verde scuro, nero, giallo scuro)
    fixed_colors = {
        [0.6, 0, 0],      % Rosso scuro
        [0, 0, 0.6],      % Blu scuro
        [0, 0.5, 0],      % Verde scuro
        [0, 0, 0],        % Nero
        [0.6, 0.6, 0]     % Giallo scuro
    };

    figure;
    hold on;

    % Loop sui gruppi
    for i = 1:length(selected_groups)
        group_name = selected_groups{i};

        if isfield(group_data, group_name)
            group_struct = group_data.(group_name);

            % Ottieni i valori delle due variabili dinamicamente
            x_vals = group_struct.(varX);
            y_vals = group_struct.(varY);

            % Colore per questo gruppo
            current_color = fixed_colors{min(i, length(fixed_colors))};

            % Scatter plot
            scatter(x_vals, y_vals, 40, 'filled', 'MarkerFaceColor', current_color);
        end
    end

    xlabel(strrep(varX, '_', '\_'), 'FontName', 'Arial', 'FontSize', 12);
    ylabel(strrep(varY, '_', '\_'), 'FontName', 'Arial', 'FontSize', 12);
    set(gca, 'FontName', 'Arial', 'FontSize', 12);

    box on;
    grid on;
    hold off;
end
