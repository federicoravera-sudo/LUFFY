function calculatePearsonCorrelation(group_data, selected_groups)
    for i = 1:length(selected_groups)
        group_name = selected_groups{i};
        group_struct = group_data.(group_name);
        
        % Estrai le variabili numeriche
        data_matrix = [group_struct.DipoleX, abs(group_struct.DipoleY), abs(group_struct.TotDipole), group_struct.DipoleZ, ...
                       group_struct.PolarizabilityIsotropic, group_struct.SinglePointEnergy, ...
                       group_struct.HOMO, group_struct.LUMO, group_struct.w, group_struct.SpecY, group_struct.F];
        
        % Calcola la matrice di correlazione di Pearson
        corr_matrix = abs(corr(data_matrix));
        
        % Applica maschera per visualizzare solo la semimatrice superiore
        mask = triu(true(size(corr_matrix)), 1);
        corr_matrix(~mask) = NaN;

        % Etichette
        labels = {'DipoleX', '|DipoleY|', '|TotDipole|', 'DipoleZ', ...
                  'PolarizabilityIsotropic', 'SinglePointEnergy', ...
                  'HOMO', 'LUMO', 'w', 'S_y', 'F'};

        % Crea heatmap
        figure;
        h = heatmap(labels, labels, corr_matrix, ...
            'Colormap', jet, ...
            'ColorbarVisible', 'on', ...
            'MissingDataLabel', '', ...
            'MissingDataColor', [1 1 1], ...
             'GridVisible', 'off'); % bianco per i NaN
        
        % Titolo con font Arial 12
%         title(['Pearson Correlation Matrix – ' group_name], 'FontName', 'Arial', 'FontSize', 12);
        
        % Imposta font delle etichette
        h.FontName = 'Arial';
        h.FontSize = 12;

        % Forza l'aggiornamento dei testi nelle celle
        drawnow; % assicura che gli oggetti siano creati prima di cercarli

        % Trova tutti gli oggetti Text nella heatmap
        texts = findall(gcf, 'Type', 'Text');
        for t = texts'
            t.FontName = 'Arial';
            t.FontSize = 12;
        end
    end
end
