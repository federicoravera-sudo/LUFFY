function S3_AnalyseSP(userSettings)

%geometry from DB
DB_MolFolderName=sprintf("%s_%s",userSettings.MOLECULE_NAME,userSettings.MOLECULE_FORMULA);
DB_GeomFolderName=sprintf("Geom%d_%s_%s",userSettings.DB_GEOMNUMBER,userSettings.ABINITIO_FUNCTIONAL,userSettings.ABINITIO_BASISSET);
DB_GeomFilePath = fullfile(userSettings.working_path,userSettings.WORKSPACE,'DB',DB_MolFolderName,'isolated_characterization',DB_GeomFolderName,'geometry.txt');

%import coordinates
geometryFileLines = fileread(DB_GeomFilePath);
geometryFileLines = regexp(geometryFileLines,"([A-z]*\s+[-|+]?[0-9][0-9]?.[0-9]+\s+[-|+]?[0-9][0-9]?.[0-9]+\s+[-|+]?[0-9][0-9]?.[0-9]+)","tokens");

%create mol structure
molGeometry.n_atoms = length(geometryFileLines);
for ii=1:molGeometry.n_atoms
    line = textscan(char(geometryFileLines{ii}),"%s %f %f %f");
    molGeometry.element(ii) = line{1};
    molGeometry.x(ii) = line{2};
    molGeometry.y(ii) = line{3};
    molGeometry.z(ii) = line{4};
end

%Define Aggregated charge
if ~isfield(userSettings,'ACListAtoms')
    if userSettings.TC_ACNUMBER==2
        userSettings.ACListAtoms{1} = find(molGeometry.y > 0);
        userSettings.ACListAtoms{2} = find(molGeometry.y <= 0);
    else
        userSettings.ACListAtoms{1} = find(molGeometry.y < -userSettings.AC_THRESHOLD);
        userSettings.ACListAtoms{2} = find(molGeometry.y > userSettings.AC_THRESHOLD);
        userSettings.ACListAtoms{3} = find(molGeometry.y >= -userSettings.AC_THRESHOLD & molGeometry.y<=userSettings.AC_THRESHOLD);
    end
end

for ii=1:length(userSettings.ACListAtoms)
    fprintf('settings.ACListAtoms{%d} = [%s];\n',ii,sprintf('%d ',userSettings.ACListAtoms{ii}));
end
fprintf("Total atoms: %d\n",molGeometry.n_atoms);

%Plot molecule
figure(1)
subplot(1,2,1)
Display_Molecule(molGeometry);
for ii=1:molGeometry.n_atoms
    text(molGeometry.x(ii),molGeometry.y(ii),molGeometry.z(ii),num2str(ii))
end
axis equal

%Plot Aggregated Charges
subplot(1,2,2), hold on,colors = {'r.','b.','g.'};
for ac_index=1:userSettings.TC_ACNUMBER
    for ii=userSettings.ACListAtoms{ac_index}
        plot(molGeometry.x(ii),molGeometry.y(ii),colors{ac_index},'MarkerSize',15)
        text(molGeometry.x(ii),molGeometry.y(ii),num2str(ii))
    end
end
axis equal


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DOT1_coord = [molGeometry.x(userSettings.CHAR_ATOMS(1)) molGeometry.y(userSettings.CHAR_ATOMS(1)) molGeometry.z(userSettings.CHAR_ATOMS(1))];
DOT2_coord = [molGeometry.x(userSettings.CHAR_ATOMS(2)) molGeometry.y(userSettings.CHAR_ATOMS(2)) molGeometry.z(userSettings.CHAR_ATOMS(2))];

dot_distance = norm(DOT2_coord-DOT1_coord);


% % generation of pointcharges
% if strcmp(userSettings.CHAR_MODE,"SW")
%     PC.x([1 2]) = [DOT1_coord(1) DOT2_coord(1)];
%     PC.y([1 2]) = [DOT1_coord(2) DOT2_coord(2)];
%     PC.z([1 2]) = [DOT1_coord(3) DOT2_coord(3)] - dot_distance;
%     PC.element = ["big_red","big_red"];
%     PC.n_atoms = 2;
% 
% elseif strcmp(userSettings.CHAR_MODE,"FIELD")
%     PC.x([1 2]) = [DOT1_coord(1) DOT2_coord(1)];
%     PC.y([1 2]) = [-userSettings.CHAR_FIELDMODE_DIST userSettings.CHAR_FIELDMODE_DIST];
%     PC.z([1 2]) = [DOT1_coord(3) DOT2_coord(3)];
%     PC.element = ["big_red","big_red"];
%     PC.n_atoms = 2;
% 
% end
% 
% %simulation files
str = userSettings.WORKSPACE;
parts =strsplit(str, '\');
sp_simulationDir = fullfile(userSettings.working_path,parts(1),'SPwithPolRight', parts(2));
sp_filename = strcat(userSettings.MOLECULE_NAME,'_EQ.out');

%get files
sp_simulation = importFromOrca(fullfile(sp_simulationDir,sp_filename),molGeometry.n_atoms);        
 
%constants
DefineConstants
   

%Evaluate charges
for ac_index=1:userSettings.TC_ACNUMBER
    SPRESULT_charge = sum(sp_simulation.espCharge(userSettings.ACListAtoms{ac_index}));

    %print info
    fprintf('Charge Dot-%d: %f\n',ac_index,SPRESULT_charge);

end

%dipole
SPRESULT_dipole = sp_simulation.dipole';
fprintf('Dipole: [%f %f %f]\n',SPRESULT_dipole(1),SPRESULT_dipole(2),SPRESULT_dipole(3));


%energy
SPRESULT_energy = sp_simulation.energyEV;
fprintf('Energy %f\n',SPRESULT_energy);

figure(2) %plot potential
EvaluateVdWPotential(sp_simulation)


