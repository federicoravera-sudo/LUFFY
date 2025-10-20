function DisplayMoleculeScatter(mol,color_property,markerType_property)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

try
    color = color_property;
catch
    color = 'r';
end

try
    type = markerType_property;
catch
    type = 'o';
end

%scatter_plot
hold on
for ii = 1:mol.n_atoms
    scatter3(mol.x(ii),mol.y(ii),mol.z(ii),color,type)
end
xlabel('x [\AA]','Interpreter','Latex')
ylabel('y [\AA]','Interpreter','Latex')
zlabel('z [\AA]','Interpreter','Latex')



end
