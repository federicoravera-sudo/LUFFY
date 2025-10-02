function statsTable = computeClusterStatsAndBoxplots(data, idx)
    % Estrai le variabili numeriche originali
    numericalVars = {'DipoleX', 'DipoleY', 'DipoleZ', 'PolarizabilityIsotropic', ...
                     'SinglePointEnergy', 'HOMO', 'LUMO', 'w'};
    numericalData = table2array(data(:, numericalVars));

    % Numero di cluster
    k = max(idx);
    
    % Inizializzazione della tabella dei risultati
    clusterStats = array2table(zeros(k, 2 * numel(numericalVars)), ...
        'VariableNames', strcat(repelem(numericalVars, 2), repmat({'_Mean', '_Std'}, 1, numel(numericalVars))));
    
    % Calcolo delle statistiche per ciascun cluster
    for c = 1:k
        clusterData = numericalData(idx == c, :);
        clusterStats(c, 1:numel(numericalVars)) = array2table(mean(clusterData, 1));
        clusterStats(c, numel(numericalVars) + 1:end) = array2table(std(clusterData, 1));
    end
    
    % Aggiunta colonna per identificare il cluster
    clusterStats = addvars(clusterStats, (1:k)', 'Before', 1, 'NewVariableNames', 'Cluster');
    
    % Output della tabella con le statistiche
    statsTable = clusterStats;
    
    % Mostra i risultati
    disp('Statistiche per ciascun cluster:');
    disp(statsTable);

    % Creazione dei boxplot
    for i = 1:numel(numericalVars)
        figure;
        boxplot(numericalData(:, i), idx, 'Widths', 0.5, 'Symbol', 'o', 'Whisker', 1.5);
        title(['Boxplot per ', numericalVars{i}]);
        xlabel('Cluster');
        ylabel(numericalVars{i});
        set(gca, 'XTickLabel', strcat('C', string(1:k))); % Etichette Cluster C1, C2, ...
        grid on;
        
        % Separazione visiva tra i boxplot
        xlim([0.5, k + 0.5]);  
        
        % Imposta i colori per ogni cluster
        h = findobj(gca, 'Tag', 'Box');
        colors = lines(k);
        for j = 1:length(h)
            patch(get(h(j), 'XData'), get(h(j), 'YData'), colors(j, :), 'FaceAlpha', 0.5);
        end
    end
end