function plotDipoleXBarPlot(group_data, selected_groups1)
    figure; 
    hold on;

    % Colori predefiniti (rosso scuro, blu scuro, verde scuro)
       fixed_colors = {
    [0.6, 0, 0],      % Rosso scuro
    [0, 0, 0.6],      % Blu scuro
    [0, 0.5, 0],      % Verde scuro
    [0, 0, 0],        % Nero
    [0.6, 0.6, 0]     % Giallo scuro
};
    bar_index = 1;  % Indice per posizione delle barre

    % Loop sui gruppi
    for i = 1:length(selected_groups1)
        group_name = selected_groups1{i};
        if isfield(group_data, group_name)
            group_struct = group_data.(group_name);
            dipoleY_values = group_struct.DipoleX .* 2.54;

            current_color = fixed_colors{min(i, length(fixed_colors))}; % Usa colore predefinito

            for j = 1:length(dipoleY_values)
                bar(bar_index, dipoleY_values(j), 'FaceColor', current_color);
                bar_index = bar_index + 1;
            end
        end
    end

    xlabel('Molecules Index');
    ylabel('Dipole Y (Debye)');
    title('Dipole Y values for selected groups');
    grid on;
    hold off;
end