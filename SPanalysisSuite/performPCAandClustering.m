function [idx, centroids, resultTable, coeff, score, explained] = performPCAandClustering(data)
  % Estrai le variabili numeriche
    numericalData = table2array(data(:, {'DipoleX', 'DipoleY', 'DipoleZ', 'PolarizabilityIsotropic', 'SinglePointEnergy', 'HOMO', 'LUMO', 'w'}));
    
    % Standardizzazione dei dati
    standardizedData = normalize(numericalData);
    
    % PCA
    [coeff, score, ~, ~, explained] = pca(standardizedData);
    
    % Determinazione del numero ottimale di cluster con il metodo del gomito
    maxClusters = 10;
    distortions = zeros(1, maxClusters);
    for k = 1:maxClusters
        [~, ~, sumd] = kmeans(score(:, 1:2), k, 'Replicates', 5, 'Display', 'final', 'MaxIter', 500);
        distortions(k) = sum(sumd);
    end
    
    % Trova il punto di gomito
    kOptimal = findElbow(distortions);
    
    % Clustering con il numero ottimale di cluster
    [idx, centroids] = kmeans(score(:, 1:2), kOptimal, 'Replicates', 5, 'Display', 'final', 'MaxIter', 500);
    
    % Plot dei risultati
    figure;
    gscatter(score(:,1), score(:,2), idx);
    hold on;
    plot(centroids(:,1), centroids(:,2), 'kx', 'MarkerSize', 12, 'LineWidth', 3);
    title('Cluster basati sulla PCA');
    xlabel('PC1');
    ylabel('PC2');
    legend('Cluster 1', 'Cluster 2', 'Cluster 3', 'Centroids');
    hold off;
    
    % Stampa i cluster trovati
    disp('Cluster assegnati:');
resultTable = table(data.NomeCombo, data.NumeroConformer, idx, ...
    'VariableNames', {'NomeCombo', 'NumeroConformer', 'Cluster'});

% Stampa personalizzata in formato NomeCombo_NumeroConformer: Cluster
disp('Risultati Clustering:');
for i = 1:height(resultTable)
    fprintf('%s_%d: %d\n', resultTable.NomeCombo{i}, resultTable.NumeroConformer(i), resultTable.Cluster(i));
end
    
    % Spiegazione dei dati
    fprintf('\n--- Spiegazione del processo ---\n');
    fprintf('1. I dati sono stati standardizzati per avere media zero e deviazione standard uno.\n');
    fprintf('2. È stata eseguita l analisi delle componenti principali (PCA) per ridurre la dimensionalità dei dati.\n');
    fprintf('3. Il numero ottimale di cluster è stato determinato utilizzando il metodo del gomito (valore di distorsione).\n');
    fprintf('4. I dati sono stati poi suddivisi in %d cluster utilizzando k-means.\n', kOptimal);
    
    % Dettagli della PCA
    fprintf('\n--- Risultati della PCA ---\n');
    fprintf('Numero di componenti principali selezionate: 2\n');
    fprintf('Varianza spiegata dalle prime 2 componenti principali:\n');
    fprintf('PC1: %.2f%%\n', explained(1));
    fprintf('PC2: %.2f%%\n', explained(2));
    
    % Creazione della tabella per PC1 e PC2
    pcTable = table(coeff(:, 1), coeff(:, 2), 'VariableNames', {'PC1', 'PC2'}, ...
        'RowNames', {'DipoleX', 'DipoleY', 'DipoleZ', 'PolarizabilityIsotropic', 'SinglePointEnergy', 'HOMO', 'LUMO', 'w'});
    
    % Stampa la tabella
    fprintf('\n--- Componenti delle prime due componenti principali (PC1 e PC2) ---\n');
    disp(pcTable);
    
    % Aggiungi eventuali altre spiegazioni utili
    fprintf('\nLe componenti principali sono usate per ridurre la dimensionalità dei dati e identificare pattern nascosti.\n');
end