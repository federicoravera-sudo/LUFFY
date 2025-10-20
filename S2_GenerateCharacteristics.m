function S2_GenerateCharacteristics(userSettings)

%constants
DefineConstants

%import geometry
%if userSettings.optimizedGeometry=="true"
    %from previous optimization
    OptFileName = sprintf('%sOpt.xyz', regexp(userSettings.MOLECULE_NAME, '[^\\\/]+$', 'match', 'once'));
    OptFilePath = fullfile(userSettings.working_path,userSettings.WORKSPACE,'01_optimization_folder',OptFileName);
    %Import coordinates
    optimizedMolLines = fileread(OptFilePath);
    optimizedMolLines = regexp(optimizedMolLines,"([A-z]*\s+[-|+]?[0-9][0-9]?.[0-9]+\s+[-|+]?[0-9][0-9]?.[0-9]+\s+[-|+]?[0-9][0-9]?.[0-9]+)","tokens");
%else
    %Import coordinates
   % optimizedMolLines = fileread(userSettings.GEOMETRY_FILE);
   % optimizedMolLines = regexp(optimizedMolLines,"([A-z]*\s+[-|+]?[0-9][0-9]?.[0-9]+\s+[-|+]?[0-9].[0-9]+\s+[-|+]?[0-9].[0-9]+)","tokens");
%end

%define DB files
DB_MolFolderName=sprintf("%s_%s",userSettings.MOLECULE_NAME,userSettings.MOLECULE_FORMULA);
DB_GeomFolderName=sprintf("Geom%d_%s_%s",userSettings.DB_GEOMNUMBER,userSettings.ABINITIO_FUNCTIONAL,userSettings.ABINITIO_BASISSET);

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
Display_Molecule(optimizedMol)

%Alignment Figure
figure(2)
DisplayMoleculeScatter(optimizedMol,'r','filled')

%Define atoms of the principal axis
DOT1_coord = [optimizedMol.x(userSettings.CHAR_ATOMS(1)) optimizedMol.y(userSettings.CHAR_ATOMS(1)) optimizedMol.z(userSettings.CHAR_ATOMS(1))];
DOT2_coord = [optimizedMol.x(userSettings.CHAR_ATOMS(2)) optimizedMol.y(userSettings.CHAR_ATOMS(2)) optimizedMol.z(userSettings.CHAR_ATOMS(2))];
 
logic_dot_distance = norm(DOT1_coord - DOT2_coord);

%translate molecule on the center of the two logic dots
mol_center=[(DOT1_coord(1)+DOT2_coord(1))/2 (DOT1_coord(2)+DOT2_coord(2))/2 (DOT1_coord(3)+DOT2_coord(3))/2];
optimizedMol.x = optimizedMol.x-mol_center(1);
optimizedMol.y = optimizedMol.y-mol_center(2);
optimizedMol.z = optimizedMol.z-mol_center(3);
DisplayMoleculeScatter(optimizedMol,'b','filled')
DOT1_coord = [optimizedMol.x(userSettings.CHAR_ATOMS(1)) optimizedMol.y(userSettings.CHAR_ATOMS(1)) optimizedMol.z(userSettings.CHAR_ATOMS(1))];
DOT2_coord = [optimizedMol.x(userSettings.CHAR_ATOMS(2)) optimizedMol.y(userSettings.CHAR_ATOMS(2)) optimizedMol.z(userSettings.CHAR_ATOMS(2))];

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

%calculate rotation around y to align dot3
% Assicurati di avere le librerie necessarie per visualizzare i campi vettoriali
% e le linee di campo elettrico.

if length(userSettings.CHAR_ATOMS) == 4
    DOT3_coord = [optimizedMol.x(userSettings.CHAR_ATOMS(3)) optimizedMol.y(userSettings.CHAR_ATOMS(3)) optimizedMol.z(userSettings.CHAR_ATOMS(3))];
    DOT4_coord = [optimizedMol.x(userSettings.CHAR_ATOMS(4)) optimizedMol.y(userSettings.CHAR_ATOMS(4)) optimizedMol.z(userSettings.CHAR_ATOMS(4))];

    projection_vector = norm([DOT3_coord(1) - DOT4_coord(1), 0, DOT3_coord(3) - DOT4_coord(3)]);
    rotation_angle = acos((DOT3_coord(1) - DOT4_coord(1)) / projection_vector);
    rotation_angle = -rotation_angle;

    x_molAxis = [cos(rotation_angle), 0, sin(rotation_angle)];
    y_molAxis = [0, 1, 0];
    z_molAxis = [-sin(rotation_angle), 0, cos(rotation_angle)];
    BCM = [x_molAxis', y_molAxis', z_molAxis'];

    for ii = 1:optimizedMol.n_atoms
        vec = [optimizedMol.x(ii), optimizedMol.y(ii), optimizedMol.z(ii)];
        newvec = vec * BCM;
        optimizedMol.x(ii) = newvec(1);
        optimizedMol.y(ii) = newvec(2);
        optimizedMol.z(ii) = newvec(3);
    end
    DOT3_coord = [optimizedMol.x(userSettings.CHAR_ATOMS(3)) optimizedMol.y(userSettings.CHAR_ATOMS(3)) optimizedMol.z(userSettings.CHAR_ATOMS(3))];
    DOT4_coord = [optimizedMol.x(userSettings.CHAR_ATOMS(4)) optimizedMol.y(userSettings.CHAR_ATOMS(4)) optimizedMol.z(userSettings.CHAR_ATOMS(4))];

    mol_height = abs(0.5 * (DOT1_coord(1) + DOT2_coord(1)) + DOT3_coord(1));
end

DisplayMoleculeScatter(optimizedMol, 'g', 'filled');
figure(3);
Display_Molecule(optimizedMol);

% Save geometry into database
ORCA_newGeometry = GenerateORCAGeometry(optimizedMol);
DB_GeomFolder = fullfile(userSettings.working_path, userSettings.WORKSPACE, 'DB', regexp(userSettings.MOLECULE_NAME, '[^\\\/]+$', 'match', 'once'), 'isolated_characterization', DB_GeomFolderName);
DB_GeomFileName = fullfile(DB_GeomFolder, 'geometry.txt');
DB_GeomFileContent = sprintf("%d\r\nGenerated with autochar tool\r\n%s", optimizedMol.n_atoms, ORCA_newGeometry);
generateFile(0, DB_GeomFileName, DB_GeomFileContent);

% Generation of point charges
if strcmp(userSettings.CHAR_MODE, "SW")
    PC.x([1 2]) = [DOT1_coord(1) DOT2_coord(1)];
    PC.y([1 2]) = [DOT1_coord(2) DOT2_coord(2)];
    PC.z([1 2]) = [DOT1_coord(3) DOT2_coord(3)] - logic_dot_distance;
    PC.element = ["big_red", "big_red"];
    PC.n_atoms = 2;

elseif strcmp(userSettings.CHAR_MODE, "FIELD")
    PC.x([1 2]) = [DOT1_coord(1) DOT2_coord(1)];
    PC.y([1 2]) = [-userSettings.CHAR_FIELDMODE_DIST userSettings.CHAR_FIELDMODE_DIST];
    PC.z([1 2]) = [DOT1_coord(3) DOT2_coord(3)];
    PC.element = ["big_red", "big_red"];
    PC.n_atoms = 2;
end

Display_Molecule(PC), axis equal;

% Generation of clock point charges
if length(userSettings.CHAR_ATOMS) == 4
    % Calculate the direction vector between DOT3 and DOT4
    direction_vector = DOT4_coord - DOT3_coord;
    % Normalize the direction vector
    direction_vector = direction_vector / norm(direction_vector);
    % Calculate the center of the axis (cartesian origin)
    axis_center = (DOT3_coord + DOT4_coord) / 2;
    % Define the positions of PC_CK along the direction vector relative to axis_center
    PC_CK_positions = axis_center + direction_vector .* [-userSettings.CHAR_CLOCKS_DIST; userSettings.CHAR_CLOCKS_DIST + mol_height];
    % Assign positions to PC_CK
    PC_CK.x = PC_CK_positions(:, 1);
    PC_CK.y = PC_CK_positions(:, 2);
    PC_CK.z = PC_CK_positions(:, 3);
    PC_CK.element = ["big_blue", "big_blue"];
    PC_CK.n_atoms = 2;

    Display_Molecule(PC_CK);
    axis equal;
else
    PC_CK.n_atoms = 0;
end

% Create point charge template file
ORCA_pointchargeTemplateFolder = fullfile(userSettings.working_path, userSettings.WORKSPACE, userSettings.VACTanalysisName);
ORCA_pointchargeTemplateeFileName = fullfile(userSettings.working_path, userSettings.WORKSPACE, userSettings.VACTanalysisName, 'pointchargesTEMPLATE.pc');
ORCA_pointchargeTemplateContent = sprintf("%d\r\n", PC.n_atoms + PC_CK.n_atoms);
for ii = 1:PC.n_atoms
    ORCA_pointchargeTemplateContent = sprintf("%sPCD%d %.7f %.7f %.7f\r\n", ORCA_pointchargeTemplateContent, ii, PC.x(ii), PC.y(ii), PC.z(ii));
end
for ii = 1:PC_CK.n_atoms
    ORCA_pointchargeTemplateContent = sprintf("%sPCLK%d %.7f %.7f %.7f\r\n", ORCA_pointchargeTemplateContent, ii, PC_CK.x(ii), PC_CK.y(ii), PC_CK.z(ii));
end
generateFile(ORCA_pointchargeTemplateFolder, ORCA_pointchargeTemplateeFileName, ORCA_pointchargeTemplateContent);

% Create input template file
ORCA_InputFileContent = fileread(fullfile('TEMPLATE_FILES', 'inputCharTemplate'));
ORCA_InputFileContent = keyWordReplace(ORCA_InputFileContent, userSettings);
ORCA_InputFileContent = strrep(ORCA_InputFileContent, "BASH_COORDINATES", ORCA_newGeometry);

% Create input template file
ORCA_charTemplateName = sprintf("%sTEMPLATE.inp", OptFileName);
ORCA_charTemplatePath = fullfile(userSettings.working_path, userSettings.WORKSPACE, userSettings.VACTanalysisName, ORCA_charTemplateName);
generateFile(0, ORCA_charTemplatePath, ORCA_InputFileContent);

% GBW file
ORCA_GBWInFileName = sprintf('%sOpt.gbw', userSettings.MOLECULE_NAME);
ORCA_GBWInFilePath = fullfile(userSettings.working_path, userSettings.WORKSPACE, '01_optimization_folder', ORCA_GBWInFileName);
try
    copyfile(ORCA_GBWInFilePath, fullfile(userSettings.working_path, userSettings.WORKSPACE, userSettings.VACTanalysisName, 'initialOrbitals.gbw'));
catch
    warning("No GBW found");
end

% Common part for both sbatch and sh files
if strcmp(userSettings.CHAR_MODE, "SW")
    char_maxCharge = userSettings.CHAR_MAXCHARGE;
    char_minCharge = 0;
    char_chargeSpan = userSettings.CHAR_SPAN;
elseif strcmp(userSettings.CHAR_MODE, "FIELD")
    char_maxCharge = 2 * (userSettings.CHAR_MAXFIELD * 1e9) * (pi * e0 * (userSettings.CHAR_FIELDMODE_DIST * 1e-10)^2) / q;
    char_minCharge = -char_maxCharge;
    char_chargeSpan = 2 * char_maxCharge / (userSettings.CHAR_POINTS - 1);
end

if length(userSettings.CHAR_ATOMS) == 4
    char_chargeCK1 = -2 * (userSettings.CHAR_CLOCKS_LIST * 1e9) * (pi * e0 * (userSettings.CHAR_CLOCKS_DIST * 1e-10)^2) / q;
    char_chargeCK2 = -char_chargeCK1;
    char_chargeSpan = 2 * char_maxCharge / (userSettings.CHAR_POINTS - 1);
end

% Define grid for electric field calculation only CLK
[X, Y, Z] = meshgrid(linspace(min(optimizedMol.x) - 40, max(optimizedMol.x) + 40,80), ...
                     linspace(min(optimizedMol.y) - 40, max(optimizedMol.y) + 40, 80), ...
                     linspace(min(optimizedMol.z) - 5, max(optimizedMol.z) + 5, 10));

% Initialize electric field components
Ex = zeros(size(X));
Ey = zeros(size(Y));
Ez = zeros(size(Z));

% Charges and their positions
charges = [char_chargeCK1, char_chargeCK2];
positions = [PC_CK.x(1) PC_CK.y(1) PC_CK.z(1); PC_CK.x(2) PC_CK.y(2) PC_CK.z(2)];

% Constants
k_e = 8.9875517873681764e9*10^18; % Coulomb's constant in N·m²/C² --> convertito in N*m^2/C^2
q = 1.6*10^-19;
% Calculate electric field due to each charge
for i = 1:length(charges)
    Rx =( X - positions(i, 1)).*0.1; % nm
    Ry = (Y - positions(i, 2)).*0.1; %nm
    Rz = (Z - positions(i, 3)).*0.1; %nm
    R = sqrt(Rx.^2 + Ry.^2 + Rz.^2); %nm
    Ex = Ex + k_e *q* charges(i) *Rx ./ R.^3*1e-9; 
    Ey = Ey + k_e *q* charges(i) * Ry ./ R.^3*1e-9;
    Ez = Ez + k_e *q* charges(i) * Rz ./ R.^3*1e-9;
end

% Plot the molecule
figure;
Display_Molecule(optimizedMol);
hold on;

% Plot the point charges
scatter3(PC_CK.x(1), PC_CK.y(1), PC_CK.z(1), 'filled', 'r');
scatter3(PC_CK.x(2), PC_CK.y(2), PC_CK.z(2), 'filled', 'r');

% Plot the electric field lines
scale_factor = 3; % Adjust the scale factor for better visualization
quiver3(X, Y, Z, Ex, Ey, Ez, scale_factor, 'b');

xlabel('X [Å]');
ylabel('Y [Å]');
zlabel('Z [Å]');
title('Electric Field Lines');
axis equal;
grid on;
hold off;


% Define grid for electric field calculation CLK + Vin
% Calcolo dell'intervallo tra i punti
intervallo = 2 * char_maxCharge / (userSettings.CHAR_POINTS - 1);

% Creazione del vettore charges_Vin utilizzando l'operatore ':'
charges_Vin = char_minCharge:intervallo:char_maxCharge;
for ii = 1:length(charges_Vin)
[X1, Y1, Z1] = meshgrid(linspace(min(optimizedMol.x) - 10, max(optimizedMol.x) + 10,20), ...
                     linspace(min(optimizedMol.y) - 10, max(optimizedMol.y) + 10, 20), ...
                     linspace(min(optimizedMol.z) - 5, max(optimizedMol.z) + 5, 20));

% Initialize electric field components
Ex1 = zeros(size(X1));
Ey1 = zeros(size(Y1));
Ez1 = zeros(size(Z1));

% Charges and their positions
charges1 = [char_chargeCK1, char_chargeCK2 charges_Vin(ii) -charges_Vin(ii)];
positions1 = [PC_CK.x(1) PC_CK.y(1) PC_CK.z(1); PC_CK.x(2) PC_CK.y(2) PC_CK.z(2);PC.x(1) PC.y(1) PC.z(1); PC.x(2) PC.y(2) PC.z(2)];

% Constants
k_e = 8.9875517873681764e9*10^18; % Coulomb's constant in N·m²/C² --> convertito in N*m^2/C^2
q = 1.6*10^-19;
% Calculate electric field due to each charge
for i = 1:length(charges1)
    Rx1 =( X1 - positions1(i, 1)).*0.1; % nm
    Ry1 = (Y1 - positions1(i, 2)).*0.1; %nm
    Rz1 = (Z1 - positions1(i, 3)).*0.1; %nm
    R1 = sqrt(Rx1.^2 + Ry1.^2 + Rz1.^2); %nm
    Ex1 = Ex1 + k_e *q* charges1(i) *Rx1 ./ R1.^3*1e-9; 
    Ey1 = Ey1 + k_e *q* charges1(i) * Ry1 ./ R1.^3*1e-9;
    Ez1 = Ez1 + k_e *q* charges1(i) * Rz1 ./ R1.^3*1e-9;
end

% Plot the molecule
figure;
Display_Molecule(optimizedMol);
hold on;

% Plot the point charges
scatter3(PC_CK.x(1), PC_CK.y(1), PC_CK.z(1), 'filled', 'b');
scatter3(PC_CK.x(2), PC_CK.y(2), PC_CK.z(2), 'filled', 'b');
scatter3(PC.x(2), PC.y(2), PC.z(2), 'filled', 'r');
scatter3(PC.x(1), PC.y(1), PC.z(1), 'filled', 'r');
% Plot the electric field lines
scale_factor =3; % Adjust the scale factor for better visualization
quiver3(X1, Y1, Z1, Ex1, Ey1, Ez1, scale_factor, 'b');
xlabel('X [Å]');
ylabel('Y [Å]');
zlabel('Z [Å]');
title(sprintf('Electric Field with Charge: %g & %g', charges_Vin(ii), -charges_Vin(ii)));
axis equal;
grid on;
hold off;
xlim([-20 25])
ylim([-20 20])
end
end

