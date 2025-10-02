% Funzione per estrarre dati per un dato gruppo
function groupStruct = getGroupData(data, groupNames)
    % Trova gli indici che corrispondono ai nomi dei combo
    groupIndices = ismember(data.NomeCombo, groupNames);
    
    % Crea la struttura per il gruppo
    groupStruct = struct();
    groupStruct.NomeCombo = data.NomeCombo(groupIndices);
    groupStruct.NumeroConformer = data.NumeroConformer(groupIndices);
    groupStruct.DipoleX = data.DipoleX(groupIndices);
    groupStruct.DipoleY = data.DipoleY(groupIndices);
    groupStruct.DipoleZ = data.DipoleZ(groupIndices);
    groupStruct.PolarizabilityIsotropic = data.PolarizabilityIsotropic(groupIndices);
%     numArray = (data.CartesianTensor(groupIndices));
%     matrixSize = sqrt(length(numArray));  % Calcola la dimensione della matrice
%     matrix = reshape(numArray, matrixSize, matrixSize);
%     % Estrai la diagonale
%     diagonalElements = diag(matrix);
%     groupStruct.PolarizabilityX = diagonalElements(1);
%     groupStruct.PolarizabilityY = diagonalElements(2);
%     groupStruct.PolarizabilityZ = diagonalElements(3);
    groupStruct.SinglePointEnergy = data.SinglePointEnergy_eV_(groupIndices);
    groupStruct.HOMO = data.HOMO(groupIndices);
    groupStruct.LUMO = data.LUMO(groupIndices);
    groupStruct.w = data.w(groupIndices);
    groupStruct.YSpacer = data.YSpacer(groupIndices);
    groupStruct.Termination = data.Termination(groupIndices);
    groupStruct.SpecX = data.SpecX(groupIndices);
    groupStruct.SpecY = data.SpecY(groupIndices);
    groupStruct.SpecZ = data.SpecZ(groupIndices);
    groupStruct.GlobSymm = data.GlobSymm(groupIndices);
    groupStruct.symmetry_y = data.symmetry_y(groupIndices);
    groupStruct.F = data.F(groupIndices);
    groupStruct.rmsd = data.rmsd(groupIndices);
    groupStruct.TotDipole = data.TotDipole(groupIndices);
%     groupStruct.par = data.par(groupIndices);
end