function scatterColored(data, var1, var2, selected_groups, colorByVar, dipoleType)
    allDataX = [];
    allDataY = [];
    allNames = {};
    allColorVar = [];
    
    % Collect data and color variables
    for i = 1:length(selected_groups)
        groupName = selected_groups{i};
        dataGroup = data.(groupName);
        
        % Extract X and Y variables
        x = dataGroup.(var1);
        y = dataGroup.(var2);
        allDataX = [allDataX; x ];
        allDataY = [allDataY; y ];
        % Choose the variable for color based on the selected colorByVar
        if strcmp(colorByVar, 'Termination+YSpacer')
            allColorVar = [allColorVar; strcat(dataGroup.Termination, '_', dataGroup.YSpacer)];
        elseif strcmp(colorByVar, 'Termination')
            allColorVar = [allColorVar; dataGroup.Termination];
        elseif strcmp(colorByVar, 'YSpacer')
            allColorVar = [allColorVar; dataGroup.YSpacer];
        else
            error('colorByVar must be one of "Termination", "YSpacer", or "Termination+YSpacer"');
        end
    end
    
     if strcmp(colorByVar, 'YSpacer')
            uniqueCombos = unique(allColorVar);
        numCombos = length(uniqueCombos);
        allYSpacers = {};
        for i = 1:length(selected_groups)
            groupName = selected_groups{i};
            allYSpacers = [allYSpacers; data.(groupName).YSpacer];
        end
        
        ySpacers = unique(allYSpacers);
        ySpacerColors = lines(length(ySpacers));
        comboColorMap = containers.Map(uniqueCombos, num2cell(zeros(numCombos, 3), 2));
     end

    
    % Handle color mapping
    if strcmp(colorByVar, 'Termination+YSpacer')
        uniqueCombos = unique(allColorVar);
        numCombos = length(uniqueCombos);
        allYSpacers = {};
        
        for i = 1:length(selected_groups)
            groupName = selected_groups{i};
            allYSpacers = [allYSpacers; data.(groupName).YSpacer];
        end
        
        ySpacers = unique(allYSpacers);
        ySpacerColors = lines(length(ySpacers));
        comboColorMap = containers.Map(uniqueCombos, num2cell(zeros(numCombos, 3), 2));
        
        assignedColors = zeros(length(allColorVar), 3);
        for i = 1:length(allColorVar)
            combo = allColorVar{i};
            parts = strsplit(combo, '_');
            ySpacer = parts{2};
            termination = parts{1};
            
            ySpacerIndex = find(strcmp(ySpacers, ySpacer));
            baseColor = ySpacerColors(ySpacerIndex, :);
            if strcmp(colorByVar, 'Termination+YSpacer')
            terminationShadingMap = containers.Map({'thiol', 'CAU', 'Dis'}, [0.6, 1, 3]);
            end
            
            shadingFactor = terminationShadingMap(termination);
            
            shadedColor = baseColor * shadingFactor;
            shadedColor = max(0, min(1, shadedColor));
            assignedColors(i, :) = shadedColor;
            comboColorMap(combo) = shadedColor;
        end
    else
        assignedColors = lines(length(allColorVar));
    end
    
    % Plot scatter
    figure;
    scatter(allDataX.*2.54,allDataY, 50, assignedColors, 'filled');
    xlabel(var1);
    ylabel(var2);
    title(['Scatter plot di ', var1, ' vs ', var2]);
    grid on;
     hold on;

     
    
    % Prepara un array di oggetti per la legenda
    hLegends = zeros(1, length(uniqueCombos));
    
    % Crea la legenda per ogni combinazione unica
    for i = 1:length(uniqueCombos)
        combo = uniqueCombos{i};
        color = comboColorMap(combo);  % Ottieni il colore associato alla combinazione
        
        % Usa un oggetto visibile (linea o scatter invisibile) per la legenda
        hLegends(i) = plot(NaN, NaN, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', color, 'MarkerSize', 8, 'DisplayName', combo);
    end
    
    % Mostra la legenda con i colori associati
    legend(hLegends, 'Location', 'best');
   hold off;
end
