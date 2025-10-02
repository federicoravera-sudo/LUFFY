function statsTable = computeClusterStats(data, idx)
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
end