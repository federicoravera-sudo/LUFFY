function [ newmol ] = extractFromMol(mol,index)
%This function...
%   mol: molecule
%   index: atoms to extract

%charge
newmol.espCharge = mol.espCharge(index);

%total charge

newmol.totalCharge = sum(newmol.espCharge);


% newmol.multeplicity = newmol.multeplicity + mol2.multeplicity;
newmol.n_atoms = length(index);

%coordinates
newmol.x = mol.x(index);
newmol.y = mol.y(index);
newmol.z = mol.z(index);

try 
    newmol.element = mol.element(index);
catch
    warning('No elements!');
end


end

