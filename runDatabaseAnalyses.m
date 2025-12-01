function runDatabaseAnalyses(dbChoice, data, doScatter, varX, varY, doPearson, doPCA, doBar)
    % Chiudi eventuale finestra principale
    close(findall(0, 'Type', 'figure', 'Name', ['Database Analysis – ' dbChoice]));
    fprintf('\nRunning analyses on %s database...\n', dbChoice);

    % === Rimuovi la colonna "Conformer" se esiste ===
    if ismember('Conformer', data.Properties.VariableNames)
        data.Conformer = []; % elimina la colonna identificativa
    end

    % === 1. Scatter plot con correlazione ===
    if doScatter
        % MATLAB converte gli header Excel in nomi validi con underscore
        varX_clean = matlab.lang.makeValidName(varX);
        varY_clean = matlab.lang.makeValidName(varY);

        if ismember(varX_clean, data.Properties.VariableNames) && ...
           ismember(varY_clean, data.Properties.VariableNames)

            figure('Name', 'Scatter with Correlation');
            scatter(data.(varX_clean), data.(varY_clean), 50, 'filled');
            xlabel(varX, 'Interpreter', 'none');
            ylabel(varY, 'Interpreter', 'none');
            title(sprintf('Scatter %s vs %s', varY, varX), 'Interpreter', 'none');
            grid on;

            r = corr(data.(varX_clean), data.(varY_clean), 'Rows', 'complete');
            text(mean(xlim), mean(ylim), sprintf('r = %.3f', r), ...
                 'FontWeight', 'bold', 'FontSize', 12, ...
                 'HorizontalAlignment', 'center', 'BackgroundColor', 'w');
        else
            uialert(uifigure, 'Selected variables not found in database.', 'Error');
        end
    end

    % === 2. Pearson correlation matrix ===
    if doPearson
        numVars = varfun(@isnumeric, data, 'OutputFormat', 'uniform');
        dataNum = data(:, numVars);

        % escludi eventuali colonne non desiderate per sicurezza
        dataNum = removevars(dataNum, intersect({'Conformer'}, dataNum.Properties.VariableNames));

        corrMatrix = corr(table2array(dataNum), 'Rows', 'complete');
        varNames = dataNum.Properties.VariableNames;

        figure('Name', 'Pearson Correlation Matrix');
        heatmap(varNames, varNames, corrMatrix, 'Colormap', parula);
        title('Pearson Correlation Matrix');
        disp('Pearson correlation matrix:');
        disp(array2table(corrMatrix, 'VariableNames', varNames, 'RowNames', varNames));
    end

    % === 3. PCA & Clustering ===
    if doPCA
        numVars = varfun(@isnumeric, data, 'OutputFormat', 'uniform');
        dataNum = data(:, numVars);
        dataNum = removevars(dataNum, intersect({'Conformer'}, dataNum.Properties.VariableNames));

        [coeff, score, ~, ~, explained] = pca(table2array(dataNum));

        figure('Name', 'PCA Clustering');
        scatter(score(:, 1), score(:, 2), 60, 'filled');
        xlabel(sprintf('PC1 (%.1f%%)', explained(1)));
        ylabel(sprintf('PC2 (%.1f%%)', explained(2)));
        title('PCA Projection');
        grid on;

        disp('Top PCA components (first two PCs):');
        disp(coeff(:, 1:2));
    end

    % === 4. Bar plots for dipole and polarizability ===
    if doBar
        figure('Name', 'Dipole and Polarizability');
        subplot(3,1,1);
        bar(data.DipoleX); title('Dipole X'); ylabel('D');
        subplot(3,1,2);
        bar(data.DipoleY); title('Dipole Y'); ylabel('D');
        subplot(3,1,3);
        bar(data.PolarizabilityIsotropic);
        title('Isotropic Polarizability'); ylabel('a.u.');
    end

    fprintf('Analyses completed successfully.\n');
end
