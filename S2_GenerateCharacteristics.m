function S2_GenerateCharacteristics(userSettings)

%constants
DefineConstants

%copy geometry into the DB
OptFileName = sprintf('%sOpt.xyz',userSettings.MOLECULE_NAME);
OptFilePath = fullfile(userSettings.working_path,userSettings.WORKSPACE,'01_optimization_folder',OptFileName);
DB_MolFolderName=sprintf("%s_%s",userSettings.MOLECULE_NAME,userSettings.MOLECULE_FORMULA);
DB_GeomFolderName=sprintf("Geom%d_%s_%s",userSettings.DB_GEOMNUMBER,userSettings.ABINITIO_FUNCTIONAL,userSettings.ABINITIO_BASISSET);

%Import coordinates
optimizedMolLines = fileread(OptFilePath);
optimizedMolLines = regexp(optimizedMolLines,"([A-z]*\s+[-|+]?[0-9][0-9]?.[0-9]+\s+[-|+]?[0-9][0-9]?.[0-9]+\s+[-|+]?[0-9][0-9]?.[0-9]+)","tokens");

%create mol structure
optimizedMol.n_atoms = length(optimizedMolLines);
for ii=1:optimizedMol.n_atoms
    line = textscan(char(optimizedMolLines{ii}),"%s %f %f %f");
    optimizedMol.element(ii) = line{1};
    optimizedMol.x(ii) = line{2};
    optimizedMol.y(ii) = line{3};
    optimizedMol.z(ii) = line{4};
end

% show the molecule
figure(1)
text(optimizedMol.x+0.2,optimizedMol.y+0.2,num2str((1:optimizedMol.n_atoms)'))
Display_Molecule(optimizedMol)

%Alignment Figure
figure(2)
DisplayMoleculeScatter(optimizedMol,'r','filled')

%Define atoms of the principal axis
DOT1_coord = [optimizedMol.x(userSettings.CHAR_ATOMS(1)) optimizedMol.y(userSettings.CHAR_ATOMS(1)) optimizedMol.z(userSettings.CHAR_ATOMS(1))];
DOT2_coord = [optimizedMol.x(userSettings.CHAR_ATOMS(2)) optimizedMol.y(userSettings.CHAR_ATOMS(2)) optimizedMol.z(userSettings.CHAR_ATOMS(2))];
DOT3_coord = [optimizedMol.x(userSettings.CHAR_ATOMS(3)) optimizedMol.y(userSettings.CHAR_ATOMS(3)) optimizedMol.z(userSettings.CHAR_ATOMS(3))];

dot_distance = norm(DOT1_coord - DOT2_coord);

%translate molecule on the center of the two dots
mol_center=[(DOT1_coord(1)+DOT2_coord(1))/2 (DOT1_coord(2)+DOT2_coord(2))/2 (DOT1_coord(3)+DOT2_coord(3))/2];
optimizedMol.x = optimizedMol.x-mol_center(1);
optimizedMol.y = optimizedMol.y-mol_center(2);
optimizedMol.z = optimizedMol.z-mol_center(3);
DisplayMoleculeScatter(optimizedMol,'b','filled')
DOT1_coord = [optimizedMol.x(userSettings.CHAR_ATOMS(1)) optimizedMol.y(userSettings.CHAR_ATOMS(1)) optimizedMol.z(userSettings.CHAR_ATOMS(1))];
DOT2_coord = [optimizedMol.x(userSettings.CHAR_ATOMS(2)) optimizedMol.y(userSettings.CHAR_ATOMS(2)) optimizedMol.z(userSettings.CHAR_ATOMS(2))];
DOT3_coord = [optimizedMol.x(userSettings.CHAR_ATOMS(3)) optimizedMol.y(userSettings.CHAR_ATOMS(3)) optimizedMol.z(userSettings.CHAR_ATOMS(3))];

%align on the xy-plane NEW BASIS
y_molAxis = (DOT2_coord - DOT1_coord)/norm(DOT2_coord - DOT1_coord);
x_molAxis = cross(y_molAxis,[0 0 1])/norm(cross(y_molAxis,[0 0 1]));
z_molAxis = cross(x_molAxis,y_molAxis)/norm(cross(x_molAxis,y_molAxis));

BCM = [x_molAxis' y_molAxis' z_molAxis'];
for ii=1:optimizedMol.n_atoms
    vec = [optimizedMol.x(ii) optimizedMol.y(ii) optimizedMol.z(ii)];
    newvec = vec*BCM;
    optimizedMol.x(ii) = newvec(1);
    optimizedMol.y(ii) = newvec(2);
    optimizedMol.z(ii) = newvec(3);
end
DOT1_coord = [optimizedMol.x(userSettings.CHAR_ATOMS(1)) optimizedMol.y(userSettings.CHAR_ATOMS(1)) optimizedMol.z(userSettings.CHAR_ATOMS(1))];
DOT2_coord = [optimizedMol.x(userSettings.CHAR_ATOMS(2)) optimizedMol.y(userSettings.CHAR_ATOMS(2)) optimizedMol.z(userSettings.CHAR_ATOMS(2))];
DOT3_coord = [optimizedMol.x(userSettings.CHAR_ATOMS(3)) optimizedMol.y(userSettings.CHAR_ATOMS(3)) optimizedMol.z(userSettings.CHAR_ATOMS(3))];

DisplayMoleculeScatter(optimizedMol,'g','filled')

figure(3)
Display_Molecule(optimizedMol)

%save geometry into database
ORCA_newGeometry = GenerateORCAGeometry(optimizedMol);
DB_GeomFileName = fullfile(userSettings.working_path,userSettings.WORKSPACE,'DB',DB_MolFolderName,'isolated_characterization',DB_GeomFolderName,'geometry.txt');
DB_GeomFileContent = sprintf("%d\r\nGenerated with autochar tool\r\n%s",optimizedMol.n_atoms,ORCA_newGeometry);
generateFile(0,DB_GeomFileName,DB_GeomFileContent);

% generation of pointcharges
if strcmp(userSettings.CHAR_MODE,"SW")
    PC.x([1 2 3 4 5]) = [DOT1_coord(1) DOT2_coord(1) DOT3_coord(1) DOT3_coord(1) DOT3_coord(1)];
    PC.y([1 2 3 4 5]) = [DOT1_coord(2) DOT2_coord(2) DOT3_coord(2) DOT3_coord(2) DOT3_coord(2)];
    PC.z([1 2 3 4 5]) = [DOT1_coord(3) DOT2_coord(3)-dot_distance DOT3_coord(3)+userSettings.CHAR_FIELDMODE_DIST DOT3_coord(3)-userSettings.CHAR_FIELDMODE_DIST DOT3_coord(3)];
    PC.element = ["big_red","big_red","big_red","big_red","big_red"];
    PC.n_atoms = 5;

elseif strcmp(userSettings.CHAR_MODE,"FIELD")
    % Calcola il vettore che va dal DOT3 al centro della molecola
    vector_to_center = mol_center - DOT3_coord;
    vector_to_center = vector_to_center / norm(vector_to_center); % Normalizza il vettore

    % Definisci le distanze delle nuove cariche dal DOT3
    distances = [userSettings.CHAR_FIELDMODE_DIST, -userSettings.CHAR_FIELDMODE_DIST];

    PC.x([1 2 3 4 5 6]) = [DOT1_coord(1) DOT2_coord(1) DOT3_coord(1) ...
                           DOT3_coord(1) + distances(1) * vector_to_center(1) ...
                           DOT3_coord(1) + distances(2) * vector_to_center(1) ...
                           DOT3_coord(1)];
    PC.y([1 2 3 4 5 6]) = [DOT1_coord(2) DOT2_coord(2) DOT3_coord(2) ...
                           DOT3_coord(2) + distances(1) * vector_to_center(2) ...
                           DOT3_coord(2) + distances(2) * vector_to_center(2) ...
                           DOT3_coord(2)];
    PC.z([1 2 3 4 5 6]) = [DOT1_coord(3) DOT2_coord(3) DOT3_coord(3) ...
                           DOT3_coord(3) + distances(1) * vector_to_center(3) ...
                           DOT3_coord(3) + distances(2) * vector_to_center(3) ...
                           DOT3_coord(3)];
    PC.element = ["big_red","big_red","big_red","big_red","big_red","big_red"];
    PC.n_atoms = 6; 

end

Display_Molecule(PC), axis equal

%create pointcharge template file
ORCA_pointchargeTemplateFolder = fullfile(userSettings.working_path,userSettings.WORKSPACE,'02_characterisation_folder');
ORCA_pointchargeTemplateeFileName = fullfile(userSettings.working_path,userSettings.WORKSPACE,'02_characterisation_folder','pointchargesTEMPLATE.pc');
ORCA_pointchargeTemplateContent = sprintf("%d\r\n",PC.n_atoms);
for ii=1:PC.n_atoms
    ORCA_pointchargeTemplateContent = sprintf("%sPCD%d %.7f %.7f %.7f\r\n",ORCA_pointchargeTemplateContent,ii,PC.x(ii),PC.y(ii),PC.z(ii));
end
generateFile(0,ORCA_pointchargeTemplateeFileName,ORCA_pointchargeTemplateContent);

%copy gbw from optimization
ORCA_GBWInFileName=sprintf('%sOpt.gbw',userSettings.MOLECULE_NAME);
ORCA_GBWInFilePath = fullfile(userSettings.working_path,userSettings.WORKSPACE,'01_optimization_folder',ORCA_GBWInFileName);
try
    copyfile(ORCA_GBWInFilePath,fullfile(userSettings.working_path,userSettings.WORKSPACE,'02_characterisation_folder','initialOrbitals.gbw'));
%     NOINITIALGBW=0;
catch
    warning("No GBW found")
%     NOINITIALGBW=1;
end

%SH FILE
ORCA_SHContent = fileread("./TEMPLATE_FILES/automatic_char_noclock");

%create SH file
ORCA_SHName = fullfile(userSettings.working_path,userSettings.WORKSPACE,'02_characterisation_folder','autochar.sh');
ORCA_SHContent = strrep(ORCA_SHContent,'SERVER_ORCAINIT',userSettings.SERVER_ORCAINIT);
ORCA_SHContent = strrep(ORCA_SHContent,'MOLECULE_NAME',userSettings.MOLECULE_NAME);
if strcmp(userSettings.CHAR_MODE,"SW")
    char_maxCharge = userSettings.CHAR_MAXCHARGE;
    char_minCharge = 0;
    char_chargeSpan = userSettings.CHAR_SPAN;
elseif strcmp(userSettings.CHAR_MODE,"FIELD")
    char_maxCharge = 2*(userSettings.CHAR_MAXFIELD*1e9)*(pi*e0*(userSettings.CHAR_FIELDMODE_DIST*1e-10)^2)/q;
    char_minCharge = -char_maxCharge;
    char_chargeSpan = 2*char_maxCharge/(userSettings.CHAR_POINTS - 1);
end
ORCA_SHContent = strrep(ORCA_SHContent,'CHAR_MINCHARGE',num2str(char_minCharge));
ORCA_SHContent = strrep(ORCA_SHContent,'CHAR_MAXCHARGE',num2str(char_maxCharge));
ORCA_SHContent = strrep(ORCA_SHContent,'CHAR_SPAN',num2str(char_chargeSpan));

generateFile(0,ORCA_SHName,ORCA_SHContent);

%copy launch file
copyfile(fullfile('TEMPLATE_FILES','launch.sh'),fullfile(userSettings.working_path,userSettings.WORKSPACE,'02_characterisation_folder','launch.sh'))

end
