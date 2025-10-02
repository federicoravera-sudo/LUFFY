function [allData] = concatenateData(group_data, selected_groups)
allData = table();
allNames = [];

for i = 1:length(selected_groups)
    groupName = selected_groups{i};
    dataGroup = group_data.(groupName);
    
    % Creazione della tabella con tutte le variabili
    groupTable = table(dataGroup.NomeCombo, dataGroup.DipoleX, dataGroup.DipoleY, dataGroup.DipoleZ, ...
                       dataGroup.PolarizabilityIsotropic, dataGroup.SinglePointEnergy, ...
                       dataGroup.HOMO, dataGroup.LUMO, dataGroup.w, ...
                       'VariableNames', {'NomeCombo', 'DipoleX', 'DipoleY', 'DipoleZ', ...
                                         'PolarizabilityIsotropic', 'SinglePointEnergy', ...
                                         'HOMO', 'LUMO', 'w'});

    % Concatenazione delle tabelle
    allData = [allData; groupTable];
end
end