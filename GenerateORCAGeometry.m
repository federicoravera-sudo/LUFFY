function [outData] = GenerateORCAGeometry(mol)
%Display the molecule in the space
%   mol: the GAUSSIAN result
%   atoms: is the vector containing the numberof atoms to be shown

%figure, hold on, grid on

%model: copy and paste to consider other elements
% scatter3(X,Y,Z,... 
%             DIMENSION,... 
%             'Filled','MarkerEdgeColor','k',...
%             'MarkerFaceColor',[COLOR-RGB]...
%         )
outData = "";
for ii=1:mol.n_atoms
    outData = strcat(outData,sprintf("%2s %.8f %.8f %.8f\n",mol.element{ii},mol.x(ii),mol.y(ii),mol.z(ii)));
end

end

