function clusterAndPlotDipole(group_data, selected_groups, dipoleType, numClusters, colorByVar)
    allData = [];
    allNames = {};
    allColorVar = {};
    allComboVar = {};
    
    % Collect data and color variables
    for i = 1:length(selected_groups)
        groupName = selected_groups{i};
        dataGroup = group_data.(groupName);
        
        if strcmp(dipoleType, 'DipoleX')
            dipoleValues = dataGroup.DipoleX;
            allData = [allData; dipoleValues .* 2.54];  % Converting to units of cm
            allNames = [allNames; dataGroup.NomeCombo];
        elseif strcmp(dipoleType, 'DipoleY')
            dipoleValues = dataGroup.DipoleY;
            allData = [allData; dipoleValues .* 2.54];  % Converting to units of cm
            allNames = [allNames; dataGroup.NomeCombo];
        elseif strcmp(dipoleType, 'F')
            dipoleValues = dataGroup.F;
            allData = [allData; dipoleValues];  % Converting to units of cm
            allNames = [allNames; dataGroup.NomeCombo];
        elseif strcmp(dipoleType, 'rmsd')
            dipoleValues = dataGroup.rmsd;
            allData = [allData; dipoleValues];  % Converting to units of cm
            allNames = [allNames; dataGroup.NomeCombo];
        end
        
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
        
        % Store combination of Termination and YSpacer for grouping in boxplot
        allComboVar = [allComboVar; strcat(dataGroup.Termination, '_', dataGroup.YSpacer)];
    end
    
    % Perform clustering (for coloring)
    dataToCluster = allData;
    [idx, ~] = kmeans(dataToCluster, numClusters);
    
    % Color by Termination+YSpacer
    if strcmp(colorByVar, 'Termination+YSpacer')
        uniqueCombos = unique(allColorVar);  % Get unique combinations of Termination+YSpacer
        numCombos = length(uniqueCombos);
        allYSpacers = {};

        for i = 1:length(selected_groups)
            groupName = selected_groups{i};
            allYSpacers = [allYSpacers; group_data.(groupName).YSpacer];
        end
        
        ySpacers = unique(allYSpacers);
        ySpacerColors = lines(length(ySpacers));  % Using 'lines' colormap
        
        comboColorMap = containers.Map(uniqueCombos, num2cell(zeros(numCombos, 3), 2));
        
        assignedColors = zeros(length(allColorVar), 3);
        for i = 1:length(allColorVar)
            combo = allColorVar{i};
            parts = strsplit(combo, '_');
            ySpacer = parts{2};
            termination = parts{1};
            
            ySpacerIndex = find(strcmp(ySpacers, ySpacer));
            baseColor = ySpacerColors(ySpacerIndex, :);
            
            terminationShadingMap = containers.Map({'thiol', 'CAU', 'Dis'}, [0.8, 1, 3]);
            shadingFactor = terminationShadingMap(termination);
            
            shadedColor = baseColor * shadingFactor;  
            shadedColor = max(0, min(1, shadedColor));  
            assignedColors(i, :) = shadedColor;
            comboColorMap(combo) = shadedColor;
        end
    elseif strcmp(colorByVar, 'Termination')
        uniqueTerminations = unique(allColorVar);
        numTerminations = length(uniqueTerminations);
        
        colors = lines(numTerminations);
        terminationColorMap = containers.Map(uniqueTerminations, num2cell(colors, 2));
        
        assignedColors = zeros(length(allColorVar), 3);
        for i = 1:length(allColorVar)
            termination = allColorVar{i};
            assignedColors(i, :) = terminationColorMap(termination);
        end
    elseif strcmp(colorByVar, 'YSpacer')
        uniqueYSpacers = unique(allColorVar);
        numYSpacers = length(uniqueYSpacers);
        
        colors = lines(numYSpacers);
        ySpacerColorMap = containers.Map(uniqueYSpacers, num2cell(colors, 2));
        
        assignedColors = zeros(length(allColorVar), 3);
        for i = 1:length(allColorVar)
            ySpacer = allColorVar{i};
            assignedColors(i, :) = ySpacerColorMap(ySpacer);
        end
    end
    
    % Plot the data with the clustered colors
    figure;
    scatter(1:length(allData), allData, 50, assignedColors, 'filled');  % Color by selected variable
    xlabel('Molecule Index');
    ylabel(dipoleType);
    title(['Clustered Data based on ' dipoleType ', colored by ' colorByVar]);
    
    % Boxplot for the data grouped by Termination+YSpacer, Termination, or YSpacer
%     figure;
%     boxplot(allData, allColorVar, 'Colors', 'k');
%     xlabel(colorByVar);
%     ylabel(dipoleType);
%     title(['Boxplot of ' dipoleType ' grouped by ' colorByVar]);
%     
%     % Boxplot for the data grouped by all combinations of Termination and YSpacer (allComboVar)
%     figure;
%     boxplot(allData, allComboVar, 'Colors', 'k');
%     xlabel('Termination + YSpacer Combos');
%     ylabel(dipoleType);
%     title(['Boxplot of ' dipoleType ' grouped by Termination + YSpacer Combos']);
    
    % Optionally, add a legend for Termination+YSpacer if selected
    if strcmp(colorByVar, 'Termination+YSpacer')
        hold on;
        hLegends = zeros(1, length(uniqueCombos));
        for i = 1:length(uniqueCombos)
            combo = uniqueCombos{i};
            color = comboColorMap(combo);  
            hLegends(i) = plot(NaN, NaN, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', color, 'MarkerSize', 8, 'DisplayName', combo);
        end
        legend(hLegends, 'Location', 'best');
        hold off;
    elseif strcmp(colorByVar, 'Termination')
        hold on;
        for i = 1:length(uniqueTerminations)
            termination = uniqueTerminations{i};
            scatter(nan, nan, 50, terminationColorMap(termination), 'filled', 'DisplayName', termination);
        end
        legend;
        hold off;
    elseif strcmp(colorByVar, 'YSpacer')
        hold on;
        for i = 1:length(uniqueYSpacers)
            ySpacer = uniqueYSpacers{i};
            scatter(nan, nan, 50, ySpacerColorMap(ySpacer), 'filled', 'DisplayName', ySpacer);
        end
        legend;
        hold off;
    end

    figure;
    boxplot(allData, allNames, 'Colors', 'k', 'Widths', 0.5);
    xlabel('Molecule Group');
    ylabel(dipoleType);
    title(['Boxplot of ' dipoleType ' for each Group']);

    % Ottieni i nomi unici dei gruppi
    % Ottieni i nomi unici dei gruppi mantenendo l'ordine originale
    [uniqueGroups, ~, groupIndices] = unique(allNames, 'stable');

    % Inizializza array per risultati
    meanVals = zeros(size(uniqueGroups));
    stdVals = zeros(size(uniqueGroups));
    percentStd = zeros(size(uniqueGroups));

    % Calcolo media, std e percentuale per ogni gruppo
    for i = 1:length(uniqueGroups)
        disp(uniqueGroups{i});
        idx = strcmp(allNames, uniqueGroups{i});
        groupedData = allData(idx);
        
        meanVals(i) = mean(groupedData);
        stdVals(i) = std(groupedData);

        % Percentuale di deviazione standard rispetto alla media
        percentStd(i) = (stdVals(i) / meanVals(i)) * 100;
        relativeRange(i) = (max(groupedData) - min(groupedData)) / max(abs(groupedData));
    end

    % Plot a barre
    figure;
    bar(stdVals, 'FaceColor', [0.2 0.4 0.6]);
    xticks(1:length(uniqueGroups));
    xticklabels(uniqueGroups);
    xtickangle(45); % Ruota le etichette se servisse
    ylabel('Standard Deviation');
    grid on;

    figure;
    bar(relativeRange, 'FaceColor', [0.2 0.4 0.6]);
    xticks(1:length(uniqueGroups));
    xticklabels(uniqueGroups);
    xtickangle(45); % Ruota le etichette se servisse
    ylabel('Relative variation');
    grid on;
end