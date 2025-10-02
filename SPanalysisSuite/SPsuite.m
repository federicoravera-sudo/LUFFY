close all
clear all
clc

% Caricamento dati
addpath('C:\Users\55fed\OneDrive - Politecnico di Torino\Dottorato\Molecules_DB\DFTB\the-molecular-suite-developer2')

data2 = readtable("C:\\Users\\55fed\\OneDrive - Politecnico di Torino\\Dottorato\\Molecules_DB\\DFTB\\the-molecular-suite-developer2\\autochar\\ConformersNeutralWs\\SPwithPolRight\\dati_estratti_NeutralNEW3.xlsx");
data1 = readtable("C:\\Users\\55fed\\OneDrive - Politecnico di Torino\\Dottorato\\Molecules_DB\\DFTB\\the-molecular-suite-developer2\\autochar\\ConformersOxWs\\SPwithPolRight\\dati_estratti_OxNEW5.xlsx");
% Carica i dati degli atomi da un file esterno
charAtomsMatrix = readmatrix("C:\Users\55fed\OneDrive - Politecnico di Torino\Dottorato\Molecules_DB\DFTB\the-molecular-suite-developer2\autochar\ConformersNeutralWs\CharAtoms.txt");

A = [24 3 7 21 8 4 3 7 1 3 3 2 16 6 3 2 3 1 18 6 6 43 19 9 4 5 2 25 13 33 72 45];
B = [1,2,5,6,7,10,16,17,20,21,22,25,26,27,30,36,37,40,41,42,45,46,47,50,56,57,60,62,63,64,65,66];


% Definizione dei dati
A1 = [24 3 7 21 8 4 3 7 1 3 3 2 16 6 3 2 3 1 18 6 6 43 19 9 4 5 2];
x = linspace(1, length(A1), length(A1));
B2 = [1,2,5,6,7,10,16,17,20,21,22,25,26,27,30,36,37,40,41,42,45,46,47,50,56,57,60];

% Definizione delle nuove etichette raggruppate a tre a tre
etichette_raggruppate = {"Pyr+Thiol", "Carb+Thiol", "Tri+Thiol", ...
                          "Pyr+CAU", "Carb+CAU", "Tri+Cau", ...
                          "Pyr+Dis", "Carb+Dis", "Tri+Dis"};

% Creazione del grafico a barre con colori alternati ogni tre colonne
figure;
hold on;
colors = ['b', 'r']; % Due colori alternati (blu e rosso)
for i = 1:length(A1)
    bar(x(i), A1(i), colors(mod(floor((i-1)/3), 2) + 1)); 
end
hold off;

xlabel('Gruppi di Molecole');
ylabel('Valore A1');
title('Grafico a barre di A1 raggruppato per combinazioni di molecole');
grid on;

% Impostazione delle etichette personalizzate ogni tre valori
xticks(x(2:3:end)); % Posiziona le etichette ogni tre barre
xticklabels(etichette_raggruppate); % Applica le nuove etichette
xtickangle(45); % Ruota le etichette per una migliore leggibilità


% Richiama la funzione di calcolo
[distances_Ox, distances_Neutral, sym_coeff_Ox_method1, sym_coeff_Neutral_method1, spec_coeffs_Ox_x,spec_coeffs_Ox_y,spec_coeffs_Ox_z,  spec_coeffs_Neutral_x,spec_coeffs_Neutral_y,spec_coeffs_Neutral_z, global_symmetry_Ox,global_symmetry_Neutral,symmetry_y_Ox, symmetry_y_Neutral,parallelism_coeff_Ox ,parallelism_coeff_Neutral, F_Ox, F_Neutral, rmsd_values] = process_conformers(charAtomsMatrix, A, B, 100, 16, 'Ox');
YSpacer = {'p','p','p','c','c','c','t','t','t','p','p','p','c','c','c','t','t','t','p','p','p','c','c','c','t','t','t', 't+ph', 't+ph', 't+ph', 'p+ph', 'p+ph'};
Termination = {'thiol','thiol','thiol','thiol','thiol','thiol','thiol','thiol','thiol','CAU','CAU','CAU','CAU','CAU','CAU','CAU','CAU','CAU','Dis','Dis','Dis','Dis','Dis','Dis','Dis','Dis','Dis', 'Dis', 'thiol', 'thiol', 'CAU','CAU'};
Nomi = {'Combo1','Combo2', 'Combo5', 'Combo6', 'Combo7', 'Combo10', 'Combo16', 'Combo17', 'Combo20', 'Combo21', 'Combo22', 'Combo25', 'Combo26', 'Combo27', 'Combo30', 'Combo36', 'Combo37', 'Combo40', 'Combo41', 'Combo42', 'Combo45', 'Combo46', 'Combo47', 'Combo50', 'Combo56', 'Combo57', 'Combo60', 'Combo62', 'Combo63', 'Combo64', 'Combo65', 'Combo66'};
data1.YSpacer = repmat({''}, height(data1), 1);
data2.YSpacer = repmat({''}, height(data2), 1);
data1.Termination = repmat({''}, height(data1), 1);
data2.Termination = repmat({''}, height(data2), 1);

% Assegna i valori corrispondenti di YSpacer in base al NomeCombo
for i = 1:length(Nomi)
    idx = strcmp(data1.NomeCombo, Nomi{i}); % Trova gli indici corrispondenti in data
    data1.YSpacer(idx) = YSpacer(i); % Assegna il valore di YSpacer corrispondente
    data2.YSpacer(idx) = YSpacer(i); % Assegna il valore di YSpacer corrispondente
    data1.Termination(idx) = Termination(i); % Assegna il valore di YSpacer corrispondente
    data2.Termination(idx) = Termination(i); % Assegna il valore di YSpacer corrispondente
end

% Mostra i risultati come grafico
data1.w = distances_Ox';
data2.w = distances_Neutral';
data1.S = sym_coeff_Ox_method1';
data2.S = sym_coeff_Neutral_method1';
data2.SpecX = spec_coeffs_Neutral_x';
data2.SpecY = spec_coeffs_Neutral_y';
data2.SpecZ = spec_coeffs_Neutral_z';
data1.SpecX = spec_coeffs_Ox_x';
data1.SpecY = spec_coeffs_Ox_y';
data1.SpecZ = spec_coeffs_Ox_z';
data1.GlobSymm = global_symmetry_Ox';
data2.GlobSymm = global_symmetry_Neutral';
data1.symmetry_y = symmetry_y_Ox';
data2.symmetry_y = symmetry_y_Neutral';
data1.par = parallelism_coeff_Ox';
data2.par = parallelism_coeff_Neutral';
data1.F = F_Ox';
data2.F = F_Neutral';
data1.rmsd = rmsd_values';
data2.rmsd = rmsd_values';


% Selezione delle variabili necessarie dalle tabelle
vars = {'NomeCombo','NumeroConformer', 'DipoleX', 'DipoleY', 'DipoleZ', 'PolarizabilityIsotropic','CartesianTensor', 'SinglePointEnergy_eV_', 'HOMO', 'LUMO', 'w', 'YSpacer', 'Termination', 'SpecX', 'SpecY', 'SpecZ', 'GlobSymm', 'symmetry_y', 'F', 'rmsd'};

data2_filtered = data2(:, vars);
data1_filtered = data1(:, vars);
data1_filtered.TotDipole = sqrt(data1_filtered.DipoleX.^2 + data1_filtered.DipoleY.^2 + data1_filtered.DipoleZ.^2);
data2_filtered.TotDipole = sqrt(data2_filtered.DipoleX.^2 + data2_filtered.DipoleY.^2 + data2_filtered.DipoleZ.^2);
% Vettori dei gruppi definiti da indici di 'NomeCombo'

%divisione per Y-spacer
group3 = {'Combo16', 'Combo36', 'Combo56', 'Combo17', 'Combo37', 'Combo57', 'Combo20', 'Combo40', 'Combo60'};
group2 = {'Combo6', 'Combo26', 'Combo46', 'Combo7', 'Combo27', 'Combo47', 'Combo10', 'Combo30', 'Combo50'};
group1 = {'Combo1', 'Combo2', 'Combo5', 'Combo21', 'Combo22', 'Combo25', 'Combo41', 'Combo42', 'Combo45'};

group4 = {'Combo62', 'Combo63', 'Combo64', 'Combo65', 'Combo66'};
group6 = {'Combo25', 'Combo66'};

group7 = {'Combo62'};
group8 = {'Combo63'};
group9 = {'Combo64'};
group10 = {'Combo65'};
group11 = {'Combo66'};

group12 = {'Combo20'};
group13 = {'Combo40'};
group14 = {'Combo60'};


% Filtraggio per rimuovere le righe con NomeCombo presente in group4
% data1_filtered_OnlyTriples = data1_filtered(~ismember(data1_filtered.NomeCombo, group4), :);
% data2_filtered_OnlyTriples = data2_filtered(~ismember(data2_filtered.NomeCombo, group4), :);
% data1_filtered_OnlyTriples.TotDipole = sqrt(data1_filtered_OnlyTriples.DipoleX.^2 + data1_filtered_OnlyTriples.DipoleY.^2 + data1_filtered_OnlyTriples.DipoleZ.^2);
% data2_filtered_OnlyTriples.TotDipole = sqrt(data2_filtered_OnlyTriples.DipoleX.^2 + data2_filtered_OnlyTriples.DipoleY.^2 + data2_filtered_OnlyTriples.DipoleZ.^2);
% Creazione delle strutture per ogni gruppo
group_data = struct();

% Assegnazione dei dati ai gruppi (per entrambe le tabelle)
group_data.group1 = getGroupData(data2_filtered, group1);
group_data.group2 = getGroupData(data2_filtered, group2);
group_data.group3 = getGroupData(data2_filtered, group3);
group_data.group4 = getGroupData(data2_filtered, group4);
group_data.group6 = getGroupData(data2_filtered, group6);
group_data.group7 = getGroupData(data2_filtered, group7);
group_data.group8 = getGroupData(data2_filtered, group8);
group_data.group9 = getGroupData(data2_filtered, group9);
group_data.group10 = getGroupData(data2_filtered, group10);
group_data.group11 = getGroupData(data2_filtered, group11);
group_data.group12 = getGroupData(data2_filtered, group12);
group_data.group13 = getGroupData(data2_filtered, group13);
group_data.group14 = getGroupData(data2_filtered, group14);

% (Se desideri anche aggiungere i dati da `data1`, ad esempio per un altro set di gruppi):
group_data.group1_Ox = getGroupData(data1_filtered, group1);
group_data.group2_Ox = getGroupData(data1_filtered, group2);
group_data.group3_Ox = getGroupData(data1_filtered, group3);
group_data.group4_Ox = getGroupData(data1_filtered, group4);
group_data.group6_Ox = getGroupData(data1_filtered, group6);
group_data.group7_Ox = getGroupData(data1_filtered, group7);
group_data.group8_Ox = getGroupData(data1_filtered, group8);
group_data.group9_Ox = getGroupData(data1_filtered, group9);
group_data.group10_Ox = getGroupData(data1_filtered, group10);
group_data.group11_Ox = getGroupData(data1_filtered, group11);

% Parametro di input: gruppi da considerare per il bar plot
selected_groups_N = {'group7', 'group8','group9','group10','group11'};  % Es: {'group1', 'group3'}
%selected_groups_Ox = {'group1_Ox', 'group2_Ox','group3_Ox'};  % Es: {'group1', 'group3'}
selected_groups_Ox = {'group7_Ox', 'group8_Ox','group9_Ox','group10_Ox','group11_Ox'};  % Es: {'group1', 'group3'}
% selected_groups_Ox_Single = {'group6_Ox'};  % Es: {'group1', 'group3'}
% selected_groups_N_Single = {'group6'};  % Es: {'group1', 'group3'}
% Creazione del bar plot per DipoleY separato per gruppi
%plotDipoleYBarPlot(group_data, selected_groups_Ox);
% plotDipoleYBarPlot(group_data, selected_groups_Ox_Single, selected_groups_N_Single)
% plotDipoleXBarPlot(group_data, selected_groups_Ox_Single, selected_groups_N_Single)
% plotIsotropicPlot(group_data, selected_groups_Ox_Single, selected_groups_N_Single)
% calculatePearsonCorrelation(group_data, selected_groups_N);

%  plotDipoleYBarPlot(group_data, selected_groups_N);
%  plotWBarPlot(group_data, selected_groups_N);
%  plotPolBarPlot(group_data, selected_groups_N);
%  plotDipoleXBarPlot(group_data, selected_groups_N);

%calculatePearsonCorrelation(group_data, selected_groups_N);
%clusterAndPlotDipole(group_data, selected_groups_Ox, 'DipoleX', 3,'Termination+YSpacer');
%clusterAndPlotDipole(group_data, selected_groups_N_Single, 'DipoleX', 3,'Termination+YSpacer');
%clusterAndPlotDipole(group_data, selected_groups_Ox, 'DipoleX', 3, 'Termination');
% clusterAndPlotDipole(group_data, selected_groups_Ox, 'DipoleY', 3, 'YSpacer');
%clusterAndPlotDipole(group_data, selected_groups_Ox, 'DipoleX', 3, 'Termination+YSpacer');
% clusterAndPlotDipoleThreshold(group_data, selected_groups_Ox, 'DipoleX', 3, 'Termination+YSpacer',0);


% Esegui PCA e clustering
% [idx_N, centroids_N, resultTable_N, coeff_N, score_N, explained_N] = performPCAandClustering(data2_filtered_OnlyTriples);
% [idx, centroids, resultTable, coeff, score, explained]= performPCAandClustering(data1_filtered_OnlyTriples);
% statsTable = computeClusterStatsAndBoxplots(data1_filtered_OnlyTriples, idx);
% [allDataNeutral] = concatenateData(group_data, selected_groups_N);
%[allDataOx] = concatenateData(group_data, selected_groups_Ox);
%scatterPlot(group_data.group6_Ox , 'DipoleY', 'F');
%scatterColored(group_data, 'TotDipole', 'PolarizabilityIsotropic', selected_groups_Ox, 'YSpacer', 'DipoleX');
%scatterColored(group_data, 'PolarizabilityIsotropic', 'SpecY', selected_groups_Ox, 'Termination+YSpacer', 'DipoleX');
%scatterColored(group_data, 'DipoleY', 'F', selected_groups_N, 'Termination+YSpacer', 'DipoleX');
%scatterColored(group_data, 'DipoleX', 'F', selected_groups_N, 'Termination+YSpacer', 'DipoleX');
%scatterColored(group_data, 'DipoleX', 'PolarizabilityIsotropic', selected_groups_Ox_Single, 'Termination+YSpacer', 'DipoleX');
plotScatterTwoVars(group_data, selected_groups_Ox, 'PolarizabilityIsotropic', 'SpecY');
plotScatterTwoVars(group_data, selected_groups_N, 'PolarizabilityIsotropic', 'SpecY');