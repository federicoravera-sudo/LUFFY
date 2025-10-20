function [ result ] = importFromOrca(filePath,n_atoms)
%This function import a GAUSSIAN output file into matlab creating a MATLAB structure
%   filePath: input file

%open the file
fid = fopen(filePath);

%save number of atoms
result.n_atoms = n_atoms;

%ignore lines before z-matrix
tline = fgetl(fid);
while ~strcmp(tline,'CARTESIAN COORDINATES (ANGSTROEM)');
    tline = fgetl(fid);
end

tline = fgetl(fid);

%save id-cordinates-atomic type-x-y-z
for i=1:result.n_atoms
    tline = fgetl(fid);
    data = textscan(tline,'  %s     %f   %f   %f');
    result.ID(i) = i;
    result.atomicNumber(i) = i;
    result.element(i) = data{1};
    result.x(i) = data{2};
    result.y(i) = data{3};
    result.z(i) = data{4};
end

%ignore everything up to the energy section
while ~strcmp(tline,'TOTAL SCF ENERGY')
    tline = fgetl(fid);
end
tline = fgetl(fid);
tline = fgetl(fid);
tline = fgetl(fid);
data = textscan(tline,'Total Energy       :         %f Eh          %f eV');
result.energy = data{1};
result.energyEV = data{2};

%ignore everything up to spin up orbital section
while ~strcmp(tline,'                 SPIN UP ORBITALS')
    tline = fgetl(fid);
end
tline = fgetl(fid); %ignore next line 
orbitalLineIsValid = 1;%get next line
orbitals_number = 1;
while orbitalLineIsValid
    tline = fgetl(fid);
        
    data=regexp(tline,'\s*([0-9])+\s+([0-9].[0-9]+)\s+[+|-]?[0-9]+.[0-9]+\s+([+|-]?[0-9]+.[0-9]+)\s*','tokens');
    if ~isempty(tline)
        result.orbitals_up(orbitals_number,[1:3]) = [str2double(data{1}{1}) str2double(data{1}{2}) str2double(data{1}{3})];
        orbitals_number = orbitals_number+1;
    else
        orbitalLineIsValid = 0;
    end
end

%ignore everything up to spin down orbital section
while ~strcmp(tline,'                 SPIN DOWN ORBITALS')
    tline = fgetl(fid);
end
tline = fgetl(fid); %ignore next line 
orbitalLineIsValid = 1;%get next line
orbitals_number = 1;
while orbitalLineIsValid
    tline = fgetl(fid);
        
    data=regexp(tline,'\s*([0-9])+\s+([0-9].[0-9]+)\s+[+|-]?[0-9]+.[0-9]+\s+([+|-]?[0-9]+.[0-9]+)\s*','tokens');
    if ~isempty(tline)
        result.orbitals_down(orbitals_number,[1:3]) = [str2double(data{1}{1}) str2double(data{1}{2}) str2double(data{1}{3})];
        orbitals_number = orbitals_number+1;
    else
        orbitalLineIsValid = 0;
    end
end

%ignore everything up to the mulliken section
while ~strcmp(tline,'MULLIKEN ATOMIC CHARGES AND SPIN POPULATIONS')
    tline = fgetl(fid);
end
tline = fgetl(fid); %ignore --- line
for i=1:result.n_atoms
    tline = fgetl(fid);
    data=regexp(tline,'[0-9]+\s[A-Z][a-z]?\s?:\s*([+|-]?[0-9].[0-9]*)\s+[+|-]?[0-9].[0-9]*','tokens');
    result.mullikenCharge(i) = str2double(cell2mat(data{1}));
end

%ignore everything up to the loewdin section
while ~strcmp(tline,'LOEWDIN ATOMIC CHARGES AND SPIN POPULATIONS')
    tline = fgetl(fid);
end
tline = fgetl(fid); %ignore --- line
for i=1:result.n_atoms
    tline = fgetl(fid);
    data=regexp(tline,'[0-9]+\s[A-Z][a-z]?\s?:\s*([+|-]?[0-9].[0-9]*)\s+[+|-]?[0-9].[0-9]*','tokens');
    result.lowedinCharge(i) = str2double(cell2mat(data{1}));
end

%ignore everything up to the energy section
while ~strcmp(tline,'DIPOLE MOMENT')
    tline = fgetl(fid);
end
tline = fgetl(fid);
tline = fgetl(fid);
tline = fgetl(fid);
tline = fgetl(fid);
tline = fgetl(fid);
tline = fgetl(fid);
data = textscan(tline,'Total Dipole Moment    :     %f       %f      %f');
result.dipole = [data{1} data{2} data{3}];

%ignore lines before ESP
tline = fgetl(fid);
while ~strcmp(tline,'CHELPG Charges            ')
    tline = fgetl(fid);
end
   
tline = fgetl(fid);

for i=1:result.n_atoms
    tline = fgetl(fid);
    data = textscan(tline,'  %f   %s   :      %f');
    result.espCharge(i) = data{3};
end
result.totalCharge = sum(result.espCharge);

% %save total charge and multiplicity
% tline = fgetl(fid);
% data = textscan(tline,'Charge = %d Multiplicity = %d');
% result.totalCharge = data{1};
% result.multeplicity = data{2};
% 
% %count atoms
% result.n_atoms = -1;
% while ~strcmp(tline,'       Variables:');
%     tline = fgetl(fid);
%     result.n_atoms = result.n_atoms+1;
% end
% %ignore up to coordinate section
% while ~strcmp(tline,' Point Charges:');
%     tline = fgetl(fid);
% end
% 
% %get backgroundcharges
% charges = 1;
% tline = fgetl(fid);
% data = textscan(tline,' XYZ=   %f   %f    %f Q=    %f A=    %f R=    %f C=    %f');
% while ~isempty(data{1})
%     result.bgcharge(charges,1) = data{1};
%     result.bgcharge(charges,2) = data{2};
%     result.bgcharge(charges,3) = data{3};
%     result.bgcharge(charges,4) = data{4};
%     charges=charges+1;
%     tline = fgetl(fid);
%     data = textscan(tline,' XYZ=   %f   %f    %f Q=    %f A=    %f R=    %f C=    %f');
% end
% 
% %ignore up to coordinate section
% while ~strcmp(tline,'                         Standard orientation:                         ');
%     tline = fgetl(fid);
% end
% 
% %ignore coordinate table head
% fgetl(fid); fgetl(fid); fgetl(fid); fgetl(fid);
% 
% %pre-allocate vectors for efficiency
% result.ID = zeros(1,result.n_atoms);
% result.atomicNumber = zeros(1,result.n_atoms);
% result.atomicType = zeros(1,result.n_atoms);
% result.x = zeros(1,result.n_atoms);
% result.y = zeros(1,result.n_atoms);
% result.z = zeros(1,result.n_atoms);
%     
% %save id-cordinates-atomic type-x-y-z
% for i=1:result.n_atoms
%     tline = fgetl(fid);
%     data = textscan(tline,'%d %d %d %f %f %f');
%     result.ID(i) = data{1};
%     result.atomicNumber(i) = data{2};
%     result.atomicType(i) = data{3};
%     result.x(i) = data{4};
%     result.y(i) = data{5};
%     result.z(i) = data{6};
% end
% 
% %ignore up to Mulliken section
% while ~strcmp(tline,' Mulliken atomic charges:');
%     tline = fgetl(fid);
% end
% 
% %ignore following line
% fgetl(fid);
% 
% %pre-allocate vector for efficiency
% result.mullikenCharge = zeros(1,result.n_atoms);
% 
% %save mulliken charges and atom type
% for i=1:result.n_atoms
%     tline = fgetl(fid);
%     data = textscan(tline,'     %d  %s   %f');
%     result.element(data{1}) = data{2};
%     result.mullikenCharge(data{1}) = data{3};
% end
% 
% %ignore up to radius section
% while ~strcmp(tline,' Merz-Kollman atomic radii used.');
%     tline = fgetl(fid);
% end
% 
% %ignore head and consider first line
% fgetl(fid); fgetl(fid); fgetl(fid);
% 
% %pre-allocate vectors for efficiency
% result.radius = zeros(1,result.n_atoms);
% 
% %save radii
% for i=1:result.n_atoms
%     tline = fgetl(fid);
%     data = textscan(tline,'    %d     %d    %f');
%     result.radius(data{1}) = data{3};
% end
% 
% %ignore up to ESP charge section
% while ~strcmp(tline,' Fitting point charges to electrostatic potential');
%     tline = fgetl(fid);
% end
% 
% %ignore head
% fgetl(fid); fgetl(fid); fgetl(fid);
% 
% %pre-allocate vectors for efficiency
% result.espCharge = zeros(1,result.n_atoms);
% 
% %save espCharge
% for i=1:result.n_atoms
%     tline = fgetl(fid);
%     data = textscan(tline,'    %d  %s   %f');
%     result.espCharge(data{1}) = data{3};
% end
% 
% %ignore up to potential section
% while ~strcmp(tline,'               Potential          X             Y             Z');
%     tline = fgetl(fid);
% end
% 
% %ignore head
% fgetl(fid);
% 
% %pre-allocate vectors for efficiency
% result.potential = zeros(1,result.n_atoms);
% 
% %save potential
% for i=1:result.n_atoms
%     tline = fgetl(fid);
%     data = textscan(tline,'    %d Atom    %f');
%     result.potential(data{1}) = data{2};
% end

%close file
fclose(fid);

end

