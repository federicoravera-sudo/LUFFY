function [assoctable,errors_x,errors_y,errors_z]  = S3_AnalyseCharacteristicsFEDE(userSettings, opt_dipole, opt_vout, opt_dipole_z, opt_dipole_y, errors_x,errors_y,errors_z);

keepVoutChargeChanges = 1;
keepDipoleZChargeChanges = 0;
%function parameters and constants
dot_plot_colors = {'r','g','b','c','m','y','k'};

%% molecule geometry
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

%Plot molecule
figure(1)
subplot(1,4,1)
Display_Molecule(molGeometry);
for ii=1:molGeometry.n_atoms
    text(molGeometry.x(ii),molGeometry.y(ii),molGeometry.z(ii),num2str(ii))
end
axis equal

%% aggregated charge model

%Aggregated Charge - Groups
if ~isfield(userSettings,'ACListAtoms')
    if userSettings.TC_ACNUMBER==2
        userSettings.ACListAtoms{1} = find(molGeometry.y < 0);
        userSettings.ACListAtoms{2} = find(molGeometry.y >= 0);
    else
        userSettings.ACListAtoms{1} = find(molGeometry.y < -userSettings.AC_THRESHOLD);
        userSettings.ACListAtoms{2} = find(molGeometry.y > userSettings.AC_THRESHOLD);
        userSettings.ACListAtoms{3} = find(molGeometry.y >= -userSettings.AC_THRESHOLD & molGeometry.y<=userSettings.AC_THRESHOLD);
    end
end

for ii=1:length(userSettings.ACListAtoms)
    fprintf('settings.ACListAtoms{%d} = [%s];\n',ii,sprintf('%d ',userSettings.ACListAtoms{ii}));
end
fprintf("Grouped atoms: %d out of %d\n",molGeometry.n_atoms,length([userSettings.ACListAtoms{:}]));

%Aggregated Charge - Positions
DOT_coords=zeros(userSettings.TC_ACNUMBER,3);

if ~isfield(userSettings,'TC_OPTIMUMPOSITION') 
    userSettings.TC_OPTIMUMPOSITION = false;
end
if userSettings.TC_OPTIMUMPOSITION == true %optimal positions
    %Single Point simulation file
    SP_simulationDir = fullfile(userSettings.working_path,userSettings.WORKSPACE,'02_sp_folder');
    SP_simulationFile = fullfile(SP_simulationDir,strcat(userSettings.MOLECULE_NAME,'_EQ.out'));
    SP_molecule = importFromOrca(SP_simulationFile,molGeometry.n_atoms); 

    %evaluate optimal position of each dot
    for dot_index=1:userSettings.TC_ACNUMBER

        %charges associated to the dot
        dot_charges = userSettings.ACListAtoms{dot_index}; 
        dot_totalCharge = sum(abs(SP_molecule.espCharge(dot_charges)));

        %optimal position
        % DOT_coords(dot_index,1) = sum(SP_molecule.x(dot_charges).*SP_molecule.espCharge(dot_charges))/dot_totalCharge;
        % DOT_coords(dot_index,2) = sum(SP_molecule.y(dot_charges).*SP_molecule.espCharge(dot_charges))/dot_totalCharge;
        % DOT_coords(dot_index,3) = sum(SP_molecule.z(dot_charges).*SP_molecule.espCharge(dot_charges))/dot_totalCharge;
        DOT_coords(dot_index,1) = sum(SP_molecule.x(dot_charges).*abs(SP_molecule.espCharge(dot_charges)))/dot_totalCharge;
        DOT_coords(dot_index,2) = sum(SP_molecule.y(dot_charges).*abs(SP_molecule.espCharge(dot_charges)))/dot_totalCharge;
        DOT_coords(dot_index,3) = sum(SP_molecule.z(dot_charges).*abs(SP_molecule.espCharge(dot_charges)))/dot_totalCharge;

    end
else %user defined positions
    for dot_index = 1:userSettings.TC_ACNUMBER
        DOT_coords(dot_index,1) = molGeometry.x(userSettings.CHAR_ATOMS(dot_index));
        DOT_coords(dot_index,2) = molGeometry.y(userSettings.CHAR_ATOMS(dot_index));
        DOT_coords(dot_index,3) = molGeometry.z(userSettings.CHAR_ATOMS(dot_index));
    end
end
disp("Dot positions:")
disp(DOT_coords)
dot_distance = norm(DOT_coords(1,:)-DOT_coords(2,:));

%Plot Aggregated Charges
subplot(1,4,2), hold on
for ac_index=1:userSettings.TC_ACNUMBER
    for ii=userSettings.ACListAtoms{ac_index}
        plot(molGeometry.x(ii),molGeometry.y(ii),strcat(dot_plot_colors{ac_index},'.'),'MarkerSize',15)
        text(molGeometry.x(ii),molGeometry.y(ii),num2str(ii))
    end
    plot(DOT_coords(ac_index,1),DOT_coords(ac_index,2),strcat(dot_plot_colors{ac_index},'o'),'MarkerSize',20)
end
axis equal

%simulation files
TC_simulationDir = fullfile(userSettings.working_path,userSettings.WORKSPACE,'02_characterisation_folder_OPT_ck-1');

[~,PCTemplate_coords] = importPCFileTemplate(fullfile(TC_simulationDir,"pointchargesTEMPLATE.pc"));
PC.x([1 2]) = [PCTemplate_coords(1,1) PCTemplate_coords(2,1)];
PC.y([1 2]) = [PCTemplate_coords(1,2) PCTemplate_coords(2,2)];
PC.z([1 2]) = [PCTemplate_coords(1,3) PCTemplate_coords(2,3)];
PC.element = ["big_red","big_red"];
PC.n_atoms = 2;


%Display_Molecule(PC), axis equal
% 
% % generation of clock pointcharges
% if length(userSettings.CHAR_ATOMS) == 3
%     PC_CK.x([1 2]) = [-userSettings.CHAR_CLOCKS_DIST   userSettings.CHAR_CLOCKS_DIST + mol_height];
%     PC_CK.y([1 2]) = 0.5*(DOT1_coord(2) + DOT2_coord(2)).*[1 1];
%     PC_CK.z([1 2]) = 0.5*(DOT1_coord(2) + DOT2_coord(2)).*[1 1];
%     PC_CK.element = ["big_blue","big_blue"];
%     PC_CK.n_atoms = 2;  
%     Display_Molecule(PC_CK), axis equal
% else
%     PC_CK.n_atoms = 0;
% end



%get files for the VACT
nameFormat = strcat(userSettings.MOLECULE_NAME,'tc_%f_%f_ck%f.out');
tc_fileList = dir(fullfile(TC_simulationDir,'*.out'));
tc_numFiles = length(tc_fileList); 

for ii = 1:tc_numFiles
    %import current molecule
    if ii == 22
        a = 1;
    end
    tc_simulation(ii) = importFromOrca(fullfile(TC_simulationDir,tc_fileList(ii).name),molGeometry.n_atoms); 
    
end

%extract clock values list
files = {tc_fileList.name}';                % get out file names
clkList = regexp(files, '.*_ck([-|+]?[0-9]*.[0-9]*).out', 'tokens');     % find all the clock values
tmp = [clkList{:}]; %type conversion
tmp = [tmp{:}]; %type conversion
clkList = str2double(unique(tmp)); % get a vector with the list of all the clock values
tc_numFilePerClock = tc_numFiles/length(clkList);
tc_numClocks = length(clkList);

%preallocation
TCDATA_Vin = zeros(tc_numClocks,1,tc_numFilePerClock);
TCDATA_dotCharge = zeros(tc_numClocks,userSettings.TC_ACNUMBER,tc_numFilePerClock);
TCDATA_dipole = zeros(tc_numClocks,3,tc_numFilePerClock);
TCDATA_energy = zeros(tc_numClocks,1,tc_numFilePerClock);
jj = [1 1];

%constants
DefineConstants

%loop on simulations
for ii = 1:tc_numFiles
    
    %import current molecule
    simUnderAnalysis = tc_simulation(ii); 
      
    %get driver conditions of current molecule
    driverCharges = textscan(tc_fileList(ii).name,nameFormat);
    QD1 = driverCharges{1};
    QD2 = driverCharges{2};
    CLK = driverCharges{3};
    PC.espCharge = [QD1 QD2];
    
    %Evaluate voltage
    TCDATA_Vin(clkList == CLK,1,jj(clkList == CLK)) = (q*k*(QD1/norm(DOT_coords(1,:) - [PC.x(1) PC.y(1) PC.z(1)]) + QD2/norm(DOT_coords(1,:) - [PC.x(2) PC.y(2) PC.z(2)]) - QD1/norm(DOT_coords(2,:) - [PC.x(1) PC.y(1) PC.z(1)]) - QD2/norm(DOT_coords(2,:) - [PC.x(2) PC.y(2) PC.z(2)])))/1e-10;
%    TCDATA_VinVert(clkList == CLK,1,jj(clkList == CLK)) = (q*k*(QD1/norm(DOT_coords(1,:) - [PC.x(1) PC.y(1) PC.z(1)]) + QD2/norm(DOT_coords(1,:) - [PC.x(2) PC.y(2) PC.z(2)]) - QD1/norm(DOT_coords(2,:) - [PC.x(1) PC.y(1) PC.z(1)]) - QD2/norm(DOT_coords(2,:) - [PC.x(2) PC.y(2) PC.z(2)])))/1e-10;
    %Evaluate charges (somma le cariche del raggruppamento qui)
    for ac_index=1:userSettings.TC_ACNUMBER
        TCDATA_dotCharge(clkList == CLK,ac_index,jj(clkList == CLK)) = sum(simUnderAnalysis.espCharge(userSettings.ACListAtoms{ac_index}));
    end
    
    %dipole
    TCDATA_dipole(clkList == CLK,:,jj(clkList == CLK)) = simUnderAnalysis.dipole;
     
    %energy
    TCDATA_energy(clkList == CLK,1,jj(clkList == CLK)) = simUnderAnalysis.energyEV;
    
    %orbitals
    TCDATA_orbitals(clkList == CLK,jj(clkList == CLK)).dataUP = simUnderAnalysis.orbitals_up;
    TCDATA_orbitals(clkList == CLK,jj(clkList == CLK)).dataDOWN = simUnderAnalysis.orbitals_down;
    jj(clkList == CLK) = jj(clkList == CLK) + 1;
  
    %vout eval
    posVout1.x = DOT_coords(1,1); posVout1.y = DOT_coords(1,2); posVout1.z = DOT_coords(1,3)-10;
    posVout2.x = DOT_coords(2,1); posVout2.y = DOT_coords(2,2); posVout2.z = DOT_coords(2,3)-10;
    Vout(ii) = EvaluatePotential(simUnderAnalysis,posVout1) - EvaluatePotential(simUnderAnalysis,posVout2); % qua mi calcolo la Vout
    ACmol.x = DOT_coords(:,1); ACmol.y = DOT_coords(:,2); ACmol.z = DOT_coords(:,3); ACmol.n_atoms = length(DOT_coords(:,3));
    ACmol.espCharge=TCDATA_dotCharge(1,:,ii);
    Vout_AC(ii) = EvaluatePotential(ACmol,posVout1) - EvaluatePotential(ACmol,posVout2); %la prima Vout_AC mi serve
    %dipole_AC(:,ii) = convUnit(EvaluateDipole(ACmol,[0 0 0]),"dipole_D_to_au");
dipole_AC(:,ii) = EvaluateDipole(ACmol,[0 0 0]);
%     dipole_CHELPG(:,ii) = convUnit(EvaluateDipole(simUnderAnalysis,[0 0 0]),"dipole_D_to_au");
 dipole_CHELPG(:,ii) = EvaluateDipole(simUnderAnalysis,[0 0 0]);


end

dipole_DFT_comp = TCDATA_dipole;
dipole_DFT_comp = squeeze(dipole_DFT_comp).*2.54;
% dipole_DFT_comp = dipole_DFT_comp';
dipole_DFT_comp =(dipole_DFT_comp(1,:));
% a questo punto ho i due vettori, posso applicare l'algoritmo
current_Dot1 = userSettings.ACListAtoms{1};
current_Dot2 = userSettings.ACListAtoms{2};
current_Dot3 = userSettings.ACListAtoms{3};
%Vout_AC = sort(Vout_AC);
%Vout_AC = flip(Vout_AC);
current_error = calculateError(Vout, Vout_AC);
% Parametri Simulated Annealing
max_iterations = 20000;
foundV = 0;
max_iterations_vc = linspace(1, max_iterations+1, max_iterations+1);
optimized_atomGroups = userSettings.ACListAtoms;
     for ac_index=1:userSettings.TC_ACNUMBER
        current_TCDATA_dotCharge(clkList == CLK,ac_index,jj(clkList == CLK)) = sum(simUnderAnalysis.espCharge(userSettings.ACListAtoms{ac_index}));
     end
initial_temperature = 1.0;
cooling_rate = 0.99;
temperature = initial_temperature;
errors = linspace(1,max_iterations+1,max_iterations+1);
errors(1) = current_error;
jj = [1 1];
temp_TCDATA_dotCharge = zeros(tc_numClocks,userSettings.TC_ACNUMBER,tc_numFilePerClock);
if opt_vout == 1
for iteration = 1:max_iterations
 jj = [1 1];
    % Proponi una nuova configurazione cambiando i raggruppamenti
  [new_Dot1, new_Dot2, new_Dot3] = perturbGroups(current_Dot1, current_Dot2,current_Dot3,1);
%   [new_Dot1, new_Dot2] = perturbGroups(current_Dot1, current_Dot2,1);
   tempACListAtoms{1} =new_Dot1;
   tempACListAtoms{2} =new_Dot2;
  tempACListAtoms{3} =new_Dot3;
for ii=1:length(userSettings.ACListAtoms)
    fprintf('settings.ACListAtoms{%d} = [%s];\n',ii,sprintf('%d ',tempACListAtoms{ii}));
end
fprintf("Grouped atoms: %d out of %d\n",molGeometry.n_atoms,length([tempACListAtoms{:}]));
    %calcolo la nuova carica aggregata del nuovo dot 
    for ii = 1:tc_numFiles
 %import current molecule
    simUnderAnalysis = tc_simulation(ii); 
            for ac_index=1:userSettings.TC_ACNUMBER
                temp_TCDATA_dotCharge(clkList == CLK,ac_index,jj(clkList == CLK)) = sum(simUnderAnalysis.espCharge(tempACListAtoms{ac_index}));
            end
     jj(clkList == CLK) = jj(clkList == CLK) + 1;
    % Calcola le nuove tensioni Vout_AC
     temp_ACmol.x = DOT_coords(:,1); temp_ACmol.y = DOT_coords(:,2); temp_ACmol.z = DOT_coords(:,3); temp_ACmol.n_atoms = length(DOT_coords(:,3));
    temp_ACmol.espCharge=temp_TCDATA_dotCharge(1,:,ii);
    temp_Vout_AC(ii) = EvaluatePotential(temp_ACmol,posVout1) - EvaluatePotential(temp_ACmol,posVout2); 
    end
    % Calcola il nuovo errore
    %temp_Vout_AC(1,:) = flip(sort(temp_Vout_AC(1,:)));
    temp_Vout_AC(1,:) =temp_Vout_AC(1,:);
%     disp("temp Vout AC")
%     disp(temp_Vout_AC)
%     disp("Vout")
%     disp(Vout)
    new_error = calculateError(Vout, temp_Vout_AC);
    errors(iteration+1) = new_error;
    % Calcola la variazione dell'errore
    delta_error = new_error - current_error;
    
    % Decidi se accettare la nuova configurazione
    if (abs(new_error) < abs(current_error)) % || (exp(-delta_error/temperature) > rand())
        proposedAtomGroups = tempACListAtoms;
        if foundV == 0
            foundV =1;
        end

        if keepVoutChargeChanges == 1
        current_Dot1 =  tempACListAtoms{1}; % queste due righe sono per metodo due, ossia che si tengono le nuove configurazioni come configurazione di partenza
        current_Dot2 =  tempACListAtoms{2};
        end
        winning_iter = iteration;
        current_error = new_error;
        current_TCDATA_dotCharge = temp_TCDATA_dotCharge;
        Vout_AC = temp_Vout_AC;
    end
    
    % Raffreddamento
    temperature = temperature * cooling_rate;
    
    % Opzionale: Visualizza i progressi
    fprintf('Iteration %d: Just evaluated error = %f\n', iteration, new_error);
end

% Risultato finale
if foundV == 0
    disp('not found Vout improvement')
    proposedAtomGroups = userSettings.ACListAtoms;
     for ac_index=1:userSettings.TC_ACNUMBER
        current_TCDATA_dotCharge(clkList == CLK,ac_index,jj(clkList == CLK)) = sum(simUnderAnalysis.espCharge(userSettings.ACListAtoms{ac_index}));
     end
     winning_iter = 0;
end

 jj = [1 1];
optimized_atomGroups = proposedAtomGroups;
userSettings.ACListAtoms = proposedAtomGroups;
TCDATA_dotCharge = current_TCDATA_dotCharge;
for ii = 1:tc_numFiles % calcola dipolo 
     simUnderAnalysis = tc_simulation(ii); 
             for ac_index=1:userSettings.TC_ACNUMBER
                temp_TCDATA_dotCharge(clkList == CLK,ac_index,jj(clkList == CLK)) = sum(simUnderAnalysis.espCharge(userSettings.ACListAtoms {ac_index}));
            end
     jj(clkList == CLK) = jj(clkList == CLK) + 1;
    ACmol.x = DOT_coords(:,1); ACmol.y = DOT_coords(:,2); ACmol.z = DOT_coords(:,3); ACmol.n_atoms = length(DOT_coords(:,3));
    ACmol.espCharge=temp_TCDATA_dotCharge(1,:,ii);
    %dipole_AC(:,ii) = convUnit(EvaluateDipole(ACmol,[0 0 0]),"dipole_D_to_au");
    dipole_AC(:,ii) = EvaluateDipole(ACmol,[0 0 0]);
    %dipole_CHELPG(:,ii) = convUnit(EvaluateDipole(simUnderAnalysis,[0 0 0]),"dipole_D_to_au");
    %dipole_CHELPG(:,ii) = EvaluateDipole(simUnderAnalysis,[0 0 0]);
end 

new_errorDipole = calculateError(dipole_DFT_comp,dipole_AC(1,:));

% riplotto la configurazione ottenuta dei dot
subplot(1,4,3), hold on
for ac_index=1:userSettings.TC_ACNUMBER
    for ii=proposedAtomGroups{ac_index}
        plot(molGeometry.x(ii),molGeometry.y(ii),strcat(dot_plot_colors{ac_index},'.'),'MarkerSize',15)
        text(molGeometry.x(ii),molGeometry.y(ii),num2str(ii))
    end
    plot(DOT_coords(ac_index,1),DOT_coords(ac_index,2),strcat(dot_plot_colors{ac_index},'o'),'MarkerSize',20)
end
axis equal
for ii=1:length(userSettings.ACListAtoms)
    fprintf('settings.ACListAtoms{%d} = [%s];\n',ii,sprintf('%d ',optimized_atomGroups{ii}));
end
fprintf("Grouped atoms: %d out of %d\n",molGeometry.n_atoms,length([optimized_atomGroups{:}]));
disp("optimized_error:  " + current_error+ " Winning Iteration: "+ winning_iter);
disp("dipole error:  " + new_errorDipole);
% pause;
end
% ok fin qui ho ottimizzato solo il dipolo lungo y (solo la Vout in realtà)... ma è importante anche
% ottimizzare il più possibile il dipolo lungo x (ossia lungo la verticale,
% e questo è fondamentale per quando poi avremo anche il clock da gestire)
% quindi unisco gli atomi in due nuovi gruppi: 





if opt_dipole == 1
secondOPTStartingGroups = optimized_atomGroups;
VoutOptError = current_error;
dipole_DFT_comp = TCDATA_dipole;
dipole_DFT_comp = squeeze(dipole_DFT_comp).*2.54;
% dipole_DFT_comp = dipole_DFT_comp';
dipole_DFT_comp =(dipole_DFT_comp(1,:));
%dipole_AC =sort(dipole_AC(1,:));
current_errorDIPOLE = calculateError(dipole_DFT_comp(1,:),dipole_AC(1,:));
% current_errorDIPOLE = calculateError(dipole_DFT_comp,dipole_AC(2,:));
initial_errorIDIPOLE = current_errorDIPOLE;
found = 0;
temp_TCDATA_dotCharge = zeros(tc_numClocks,userSettings.TC_ACNUMBER,tc_numFilePerClock);
temp_Dipole_AC =  zeros(3,tc_numFilePerClock);
for iteration = 1:max_iterations
 jj = [1 1];
    % Proponi una nuova configurazione cambiando i raggruppamenti
 [new_Dot1, new_Dot2, new_Dot3] = perturbGroups(current_Dot1, current_Dot2,current_Dot3, 2); %qua devo scegliere come fare la perturbazione
%   [new_Dot1, new_Dot2] = perturbGroups(current_Dot1, current_Dot2,1);
   tempACListAtoms{1} =new_Dot1;
   tempACListAtoms{2} =new_Dot2;
 
   tempACListAtoms{3} =new_Dot3;
for ii=1:length(userSettings.ACListAtoms)
    fprintf('settings.ACListAtoms{%d} = [%s];\n',ii,sprintf('%d ',tempACListAtoms{ii}));
end
fprintf("Grouped atoms: %d out of %d\n",molGeometry.n_atoms,length([tempACListAtoms{:}]));
    %calcolo la nuova carica aggregata del nuovo dot 
    for ii = 1:tc_numFiles
 %import current molecule
    simUnderAnalysis = tc_simulation(ii); 
            for ac_index=1:userSettings.TC_ACNUMBER
                temp_TCDATA_dotCharge(clkList == CLK,ac_index,jj(clkList == CLK)) = sum(simUnderAnalysis.espCharge(tempACListAtoms{ac_index}));
            end
     jj(clkList == CLK) = jj(clkList == CLK) + 1;
    % Calcola le nuove tensioni Vout_AC
     temp_ACmol.x = DOT_coords(:,1); temp_ACmol.y = DOT_coords(:,2); temp_ACmol.z = DOT_coords(:,3); temp_ACmol.n_atoms = length(DOT_coords(:,3));
    temp_ACmol.espCharge=temp_TCDATA_dotCharge(1,:,ii);
    temp_Vout_AC(ii) = EvaluatePotential(temp_ACmol,posVout1) - EvaluatePotential(temp_ACmol,posVout2); 
    temp_Dipole_AC(:,ii) = EvaluateDipole(temp_ACmol,[0 0 0]); %calcolo il dipolo temporaneo, occhio che devo invertire il segno
    temp_Dipole_AC(1, ii) = temp_Dipole_AC(1, ii);
    temp_Dipole_AC(2, ii)  = temp_Dipole_AC(2, ii);
    temp_Dipole_AC(3, ii)  = temp_Dipole_AC(3, ii);
    end
    % Calcola il nuovo errore
    new_errorVout = calculateError(Vout_AC, temp_Vout_AC);
    new_errorDipole = calculateError(dipole_DFT_comp,temp_Dipole_AC(1,:));
    
    % Decidi se accettare la nuova configurazione
    %
    if abs(new_errorVout ) < 1  &&   (abs(new_errorDipole) < abs(current_errorDIPOLE))  % || new_errorDipole < 1)% || (exp(-delta_error/temperature) > rand())
        proposedAtomGroups = tempACListAtoms;
        current_Dot1 =  tempACListAtoms{1}; % queste due righe sono per metodo due, ossia che si tengono le nuove configurazioni come configurazione di partenza
        current_Dot2 =  tempACListAtoms{2};
         current_Dot3 =  tempACListAtoms{3};
if found == 0
    found = 1;
end
current_error = new_errorVout;
winning_iter = iteration;
        current_errorDIPOLE = new_errorDipole;
        current_TCDATA_dotCharge = temp_TCDATA_dotCharge;
        Vout_AC = temp_Vout_AC;
        dipole_AC = temp_Dipole_AC;
    end
   
    
    % Opzionale: Visualizza i progressi
    fprintf('Iteration %d: Just evaluated error = %f\n', iteration, new_error);
end

userSettings.ACListAtoms = proposedAtomGroups;
TCDATA_dotCharge = current_TCDATA_dotCharge;
subplot(1,4,4), hold on
for ac_index=1:userSettings.TC_ACNUMBER
    for ii=proposedAtomGroups{ac_index}
        plot(molGeometry.x(ii),molGeometry.y(ii),strcat(dot_plot_colors{ac_index},'.'),'MarkerSize',15)
        text(molGeometry.x(ii),molGeometry.y(ii),num2str(ii))
    end
    plot(DOT_coords(ac_index,1),DOT_coords(ac_index,2),strcat(dot_plot_colors{ac_index},'o'),'MarkerSize',20)
end
axis equal
for ii=1:length(userSettings.ACListAtoms)
    fprintf('settings.ACListAtoms{%d} = [%s];\n',ii,sprintf('%d ',proposedAtomGroups{ii}));
end
fprintf("Grouped atoms: %d out of %d\n",molGeometry.n_atoms,length([proposedAtomGroups{:}]));
disp("optimized_error dipole:  " + current_errorDIPOLE + " optimized_error Vout:  " + current_error + " Winning Iteration: "+ winning_iter);
disp("initial error dipole:  " + initial_errorIDIPOLE + " initial error vout:  "+ VoutOptError);
if found == 0
    disp("no found!");
end
% pause;

end





if opt_dipole_y == 1
secondOPTStartingGroups = optimized_atomGroups;
VoutOptError = current_error;
dipole_DFT_comp = TCDATA_dipole;
dipole_DFT_comp = squeeze(dipole_DFT_comp).*2.54;
% dipole_DFT_comp = dipole_DFT_comp';
dipole_DFT_comp =(dipole_DFT_comp(2,:));
%dipole_AC =sort(dipole_AC(1,:));
current_errorDIPOLE = calculateError(dipole_DFT_comp,dipole_AC(2,:));
% current_errorDIPOLE = calculateError(dipole_DFT_comp,dipole_AC(2,:));
initial_errorIDIPOLE = current_errorDIPOLE;
found = 0;
temp_TCDATA_dotCharge = zeros(tc_numClocks,userSettings.TC_ACNUMBER,tc_numFilePerClock);
temp_Dipole_AC =  zeros(3,tc_numFilePerClock);
for iteration = 1:max_iterations
 jj = [1 1];
    % Proponi una nuova configurazione cambiando i raggruppamenti
 [new_Dot1, new_Dot2, new_Dot3] = perturbGroups(current_Dot1, current_Dot2,current_Dot3, 1); %qua devo scegliere come fare la perturbazione
%   [new_Dot1, new_Dot2] = perturbGroups(current_Dot1, current_Dot2,1);
   tempACListAtoms{1} =new_Dot1;
   tempACListAtoms{2} =new_Dot2;
 
   tempACListAtoms{3} =new_Dot3;
for ii=1:length(userSettings.ACListAtoms)
    fprintf('settings.ACListAtoms{%d} = [%s];\n',ii,sprintf('%d ',tempACListAtoms{ii}));
end
fprintf("Grouped atoms: %d out of %d\n",molGeometry.n_atoms,length([tempACListAtoms{:}]));
    %calcolo la nuova carica aggregata del nuovo dot 
    for ii = 1:tc_numFiles
 %import current molecule
    simUnderAnalysis = tc_simulation(ii); 
            for ac_index=1:userSettings.TC_ACNUMBER
                temp_TCDATA_dotCharge(clkList == CLK,ac_index,jj(clkList == CLK)) = sum(simUnderAnalysis.espCharge(tempACListAtoms{ac_index}));
            end
     jj(clkList == CLK) = jj(clkList == CLK) + 1;
    % Calcola le nuove tensioni Vout_AC
     temp_ACmol.x = DOT_coords(:,1); temp_ACmol.y = DOT_coords(:,2); temp_ACmol.z = DOT_coords(:,3); temp_ACmol.n_atoms = length(DOT_coords(:,3));
    temp_ACmol.espCharge=temp_TCDATA_dotCharge(1,:,ii);
    temp_Vout_AC(ii) = EvaluatePotential(temp_ACmol,posVout1) - EvaluatePotential(temp_ACmol,posVout2); 
    temp_Dipole_AC(:,ii) = EvaluateDipole(temp_ACmol,[0 0 0]); %calcolo il dipolo temporaneo, occhio che devo invertire il segno
    temp_Dipole_AC(1, ii) = temp_Dipole_AC(1, ii);
    temp_Dipole_AC(2, ii)  = temp_Dipole_AC(2, ii);
    temp_Dipole_AC(3, ii)  = temp_Dipole_AC(3, ii);
    end
    % Calcola il nuovo errore
    new_errorVout = calculateError(Vout_AC, temp_Vout_AC);
    new_errorDipole = calculateError(dipole_DFT_comp,temp_Dipole_AC(2,:));
    
    % Decidi se accettare la nuova configurazione
    %
    if abs(new_errorVout ) < 1  &&   (abs(new_errorDipole) < abs(current_errorDIPOLE))  % || new_errorDipole < 1)% || (exp(-delta_error/temperature) > rand())
        proposedAtomGroups = tempACListAtoms;
        current_Dot1 =  tempACListAtoms{1}; % queste due righe sono per metodo due, ossia che si tengono le nuove configurazioni come configurazione di partenza
        current_Dot2 =  tempACListAtoms{2};
         current_Dot3 =  tempACListAtoms{3};
if found == 0
    found = 1;
end
current_error = new_errorVout;
winning_iter = iteration;
        current_errorDIPOLE = new_errorDipole;
        current_TCDATA_dotCharge = temp_TCDATA_dotCharge;
        Vout_AC = temp_Vout_AC;
        dipole_AC = temp_Dipole_AC;
    end
   
    
    % Opzionale: Visualizza i progressi
    fprintf('Iteration %d: Just evaluated error = %f\n', iteration, new_error);
end

userSettings.ACListAtoms = proposedAtomGroups;
TCDATA_dotCharge = current_TCDATA_dotCharge;
subplot(1,4,4), hold on
for ac_index=1:userSettings.TC_ACNUMBER
    for ii=proposedAtomGroups{ac_index}
        plot(molGeometry.x(ii),molGeometry.y(ii),strcat(dot_plot_colors{ac_index},'.'),'MarkerSize',15)
        text(molGeometry.x(ii),molGeometry.y(ii),num2str(ii))
    end
    plot(DOT_coords(ac_index,1),DOT_coords(ac_index,2),strcat(dot_plot_colors{ac_index},'o'),'MarkerSize',20)
end
axis equal
for ii=1:length(userSettings.ACListAtoms)
    fprintf('settings.ACListAtoms{%d} = [%s];\n',ii,sprintf('%d ',proposedAtomGroups{ii}));
end
fprintf("Grouped atoms: %d out of %d\n",molGeometry.n_atoms,length([proposedAtomGroups{:}]));
disp("optimized_error dipole:  " + current_errorDIPOLE + " optimized_error Vout:  " + current_error + " Winning Iteration: "+ winning_iter);
disp("initial error dipole:  " + initial_errorIDIPOLE + " initial error vout:  "+ VoutOptError);
if found == 0
    disp("no found!");
end
% pause;

end



if opt_dipole_z == 1
secondOPTStartingGroups = optimized_atomGroups;
VoutOptError = current_error;
dipole_DFT_comp = TCDATA_dipole;
dipole_DFT_comp = squeeze(dipole_DFT_comp).*2.54;
% dipole_DFT_comp = dipole_DFT_comp';
dipole_DFT_comp =(dipole_DFT_comp(3,:));
%dipole_AC =sort(dipole_AC(1,:));
current_errorDIPOLE = calculateError(dipole_DFT_comp,dipole_AC(3,:));
% current_errorDIPOLE = calculateError(dipole_DFT_comp,dipole_AC(2,:));
initial_errorIDIPOLE = current_errorDIPOLE;
found = 0;
temp_TCDATA_dotCharge = zeros(tc_numClocks,userSettings.TC_ACNUMBER,tc_numFilePerClock);
temp_Dipole_AC =  zeros(3,tc_numFilePerClock);
for iteration = 1:max_iterations
 jj = [1 1];
    % Proponi una nuova configurazione cambiando i raggruppamenti
 [new_Dot1, new_Dot2, new_Dot3] = perturbGroups(current_Dot1, current_Dot2,current_Dot3, 2); %qua devo scegliere come fare la perturbazione
%   [new_Dot1, new_Dot2] = perturbGroups(current_Dot1, current_Dot2,1);
   tempACListAtoms{1} =new_Dot1;
   tempACListAtoms{2} =new_Dot2;
 
   tempACListAtoms{3} =new_Dot3;
for ii=1:length(userSettings.ACListAtoms)
    fprintf('settings.ACListAtoms{%d} = [%s];\n',ii,sprintf('%d ',tempACListAtoms{ii}));
end
fprintf("Grouped atoms: %d out of %d\n",molGeometry.n_atoms,length([tempACListAtoms{:}]));
    %calcolo la nuova carica aggregata del nuovo dot 
    for ii = 1:tc_numFiles
 %import current molecule
    simUnderAnalysis = tc_simulation(ii); 
            for ac_index=1:userSettings.TC_ACNUMBER
                temp_TCDATA_dotCharge(clkList == CLK,ac_index,jj(clkList == CLK)) = sum(simUnderAnalysis.espCharge(tempACListAtoms{ac_index}));
            end
     jj(clkList == CLK) = jj(clkList == CLK) + 1;
    % Calcola le nuove tensioni Vout_AC
     temp_ACmol.x = DOT_coords(:,1); temp_ACmol.y = DOT_coords(:,2); temp_ACmol.z = DOT_coords(:,3); temp_ACmol.n_atoms = length(DOT_coords(:,3));
    temp_ACmol.espCharge=temp_TCDATA_dotCharge(1,:,ii);
    temp_Vout_AC(ii) = EvaluatePotential(temp_ACmol,posVout1) - EvaluatePotential(temp_ACmol,posVout2); 
    temp_Dipole_AC(:,ii) = EvaluateDipole(temp_ACmol,[0 0 0]); %calcolo il dipolo temporaneo, occhio che devo invertire il segno
    temp_Dipole_AC(1, ii) = temp_Dipole_AC(1, ii);
    temp_Dipole_AC(2, ii)  = temp_Dipole_AC(2, ii);
    temp_Dipole_AC(3, ii)  = temp_Dipole_AC(3, ii);
    end
    % Calcola il nuovo errore
    new_errorVout = calculateError(Vout_AC, temp_Vout_AC);
    new_errorDipole = calculateError(dipole_DFT_comp,temp_Dipole_AC(3,:));
    
    % Decidi se accettare la nuova configurazione
    %
    if abs(new_errorVout ) < 1  &&   (abs(new_errorDipole) < abs(current_errorDIPOLE))  % || new_errorDipole < 1)% || (exp(-delta_error/temperature) > rand())
        proposedAtomGroups = tempACListAtoms;
        if keepDipoleZChargeChanges == 1
        current_Dot1 =  tempACListAtoms{1}; % queste due righe sono per metodo due, ossia che si tengono le nuove configurazioni come configurazione di partenza
        current_Dot2 =  tempACListAtoms{2};
         current_Dot3 =  tempACListAtoms{3};
        end
if found == 0
    found = 1;
end
current_error = new_errorVout;
winning_iter = iteration;
        current_errorDIPOLE = new_errorDipole;
        current_TCDATA_dotCharge = temp_TCDATA_dotCharge;
        Vout_AC = temp_Vout_AC;
        dipole_AC = temp_Dipole_AC;
    end
   
    
    % Opzionale: Visualizza i progressi
    fprintf('Iteration %d: Just evaluated error = %f\n', iteration, new_error);
end

userSettings.ACListAtoms = proposedAtomGroups;
TCDATA_dotCharge = current_TCDATA_dotCharge;
subplot(1,4,4), hold on
for ac_index=1:userSettings.TC_ACNUMBER
    for ii=proposedAtomGroups{ac_index}
        plot(molGeometry.x(ii),molGeometry.y(ii),strcat(dot_plot_colors{ac_index},'.'),'MarkerSize',15)
        text(molGeometry.x(ii),molGeometry.y(ii),num2str(ii))
    end
    plot(DOT_coords(ac_index,1),DOT_coords(ac_index,2),strcat(dot_plot_colors{ac_index},'o'),'MarkerSize',20)
end
axis equal
for ii=1:length(userSettings.ACListAtoms)
    fprintf('settings.ACListAtoms{%d} = [%s];\n',ii,sprintf('%d ',proposedAtomGroups{ii}));
end
fprintf("Grouped atoms: %d out of %d\n",molGeometry.n_atoms,length([proposedAtomGroups{:}]));
disp("optimized_error dipole:  " + current_errorDIPOLE + " optimized_error Vout:  " + current_error + " Winning Iteration: "+ winning_iter);
disp("initial error dipole:  " + initial_errorIDIPOLE + " initial error vout:  "+ VoutOptError);
if found == 0
    disp("no found!");
end

% pause;

end

%% post analysis

% generate files
%scerpa tc file
SCERPA_tcFolder = sprintf('N.%s_%d',userSettings.MOLECULE_NAME,userSettings.DB_GEOMNUMBER);
SCERPA_tcFolderPath = fullfile(userSettings.working_path,userSettings.WORKSPACE,'SCERPA',SCERPA_tcFolder);
SCERPA_infoFileName =  fullfile(SCERPA_tcFolderPath,'info.txt');

%generate coordinates of the aggregated charges
SCERPA_infoFile_ChargesCoordinates="";
for dd = 1:userSettings.TC_ACNUMBER
    SCERPA_infoFile_ChargesCoordinates=sprintf("%s%f %f %f\n",SCERPA_infoFile_ChargesCoordinates,DOT_coords(dd,1),DOT_coords(dd,2),DOT_coords(dd,3));
end

%add ghost coordinates
for dd=(userSettings.TC_ACNUMBER+1):4
    SCERPA_infoFile_ChargesCoordinates=sprintf("%s0 0 0\n",SCERPA_infoFile_ChargesCoordinates);
end

%generate SCERPA association table

if ~isfield(userSettings,'SCERPA_ASSOC')
    userSettings.SCERPA_ASSOC = [1 2];
end
SCERPA_infoFile_Associations = sprintf("ASSOCIATION %d\n",size(userSettings.SCERPA_ASSOC,1));
for aa=1:size(userSettings.SCERPA_ASSOC,1)
    SCERPA_infoFile_Associations = sprintf("%s%s\n",SCERPA_infoFile_Associations,num2str(userSettings.SCERPA_ASSOC(aa,:)));
end

%generate info file content
SCERPA_infoFileContent = sprintf("CHARGES 4\n%s\n%s\nCLOCKDATA %d\n",SCERPA_infoFile_ChargesCoordinates,SCERPA_infoFile_Associations,length(clkList));    

% DB folder
DB_tcFolderName = fullfile(userSettings.working_path,userSettings.WORKSPACE,'DB','FCN_characterization');
    
for i = clkList % for each clock value, generate files and plots
    
    %sort data
    Vin(1,:) = TCDATA_Vin(clkList == i,:,:);
    dotCharge(:,:) = TCDATA_dotCharge(clkList == i,:,:);
    dipole_DFT(:,:) = TCDATA_dipole(clkList == i,:,:);
    energy(1,:) = TCDATA_energy(clkList == i,:,:);
    [Vin,sortI] = sort(Vin,2);
    dotCharge = dotCharge(:,sortI);
    dipole_DFT = dipole_DFT(:,sortI);
    energy = energy(:,sortI);
    Vout = Vout(sortI);
    Vout_AC = Vout_AC(:,sortI);
    dipole_AC = dipole_AC(:,sortI);
    dipole_CHELPG = dipole_CHELPG(:,sortI);
    orbital_data = TCDATA_orbitals(clkList == i,sortI);

    SCERPA_tcFileName = sprintf('ck%f.txt',i);
    SCERPA_tcFileNamePath =  fullfile(SCERPA_tcFolderPath,SCERPA_tcFileName);

    %generate info file content
    infoFileClock = sprintf("<%d> %s %f V %d values </%d>\n",clkList == i,SCERPA_tcFileName,i,tc_numFiles/length(clkList),clkList == i);
    SCERPA_infoFileContent = strcat(SCERPA_infoFileContent,infoFileClock);

    %generate ck0.txt file content
    SCERPA_ckFileContent = '';
    for ii=sortI
        try dot3_charge = TCDATA_dotCharge(clkList == i,3,ii); catch; dot3_charge=0; end
        try dot4_charge = TCDATA_dotCharge(clkList == i,4,ii); catch; dot4_charge=0; end

        ck_line = sprintf("%f %f %f %f %f\n",TCDATA_Vin(clkList == i,ii),TCDATA_dotCharge(clkList == i,1,ii),TCDATA_dotCharge(clkList == i,2,ii),dot3_charge,dot4_charge);
        SCERPA_ckFileContent = strcat(SCERPA_ckFileContent,ck_line);
    end

    generateFile(SCERPA_tcFolderPath,SCERPA_tcFileNamePath,SCERPA_ckFileContent)
    
    % DB files
    DB_tcFileName = sprintf('VACT_%s_%s_Geom%d_ck%f',userSettings.ABINITIO_FUNCTIONAL,userSettings.ABINITIO_BASISSET,userSettings.DB_GEOMNUMBER,i);
    DB_tcFilePath = fullfile(DB_tcFolderName,DB_tcFileName);

    DB_tcFileContent = SCERPA_ckFileContent;
    generateFile(DB_tcFolderName,DB_tcFilePath,DB_tcFileContent)

    %orbital plot
    orbital_energies_up = zeros(length(orbital_data(1).dataUP(:,3)),length(Vin));
    orbital_occ_up = zeros(length(orbital_data(1).dataUP(:,2)),length(Vin));
    orbital_energies_down = zeros(length(orbital_data(1).dataDOWN(:,3)),length(Vin));
    orbital_occ_down = zeros(length(orbital_data(1).dataDOWN(:,2)),length(Vin));
    for vv=1:length(Vin)
              orbital_energies_up(:,vv) = orbital_data(vv).dataUP(:,3);
              orbital_occ_up(:,vv) = orbital_data(vv).dataUP(:,2);
              orbital_energies_down(:,vv) = orbital_data(vv).dataDOWN(:,3);
              orbital_occ_down(:,vv) = orbital_data(vv).dataDOWN(:,2);
    end
    %     orbitalsAll_occ = TCDATA_orbitals(clkList == i,sortI)
    
    %plot   
    figure(2)
    subplot(2,1,1)
        for dd=1:userSettings.TC_ACNUMBER
            plot(Vin,dotCharge(dd,:),dot_plot_colors{dd},'LineWidth',2), hold on
        end
        plot([Vin(1) Vin(end)],[0 0],'k','LineWidth',1)
        xlabel('Vin (V)'), ylabel('Aggregated Charge (a.u.)'), grid minor
        legend(split(sprintf("DOT%d.",(1:userSettings.TC_ACNUMBER)'),'.'))
        
    subplot(2,1,2), hold on
        plot(Vin/norm(DOT_coords(1,:)*1e-10 - DOT_coords(2,:)*1e-10)/1e9,dipole_DFT.*2.5417984,'LineWidth',2)
        plot(Vin/norm(DOT_coords(1,:)*1e-10 - DOT_coords(2,:)*1e-10)/1e9,dipole_CHELPG,'LineWidth',2)
        xlabel('E (V/nm)'), ylabel('Dipole (D)')
        legend('x','y','z','x_C','y_C','z_C'), grid minor
    sgtitle(sprintf('clk = %.1f V/nm',i))
    figure
         plot(Vin,energy,'.r','MarkerSize',10)
         xlabel('Vin (V)'), ylabel('SCF Energy (eV)'), grid minor

    %print info
    fprintf('Max charge variation DOT1-DOT2 (clk = %.1f V/nm): %.2f e\n',i,max(TCDATA_dotCharge(clkList == i,1,:)-TCDATA_dotCharge(clkList == i,2,:)))
    
    %orbitals
%     figure, hold on, title(sprintf('Orbitals - clk = %.1f V/nm',i))
%     subplot(1,3,1)
%         hold on
%         plot(Vin,(orbital_energies_up.*(orbital_occ_up==0))','r','LineWidth',1)
%         plot(Vin,(orbital_energies_up.*(orbital_occ_up==1))','b','LineWidth',1)
%         xlabel('Vin'), ylabel('Energy [eV]'), grid minor
%         title('UP')
%     subplot(1,3,2)
%     hold on
%         plot(Vin,(orbital_energies_down.*(orbital_occ_down==0))','r','LineWidth',1)
%         plot(Vin,(orbital_energies_down.*(orbital_occ_down==1))','b','LineWidth',1)
%         xlabel('Vin'), ylabel('Energy [eV]'), grid minor
%         title('DOWN')
%     subplot(1,3,3), hold on
%         plot(Vin,(orbital_energies_up.*(orbital_occ_up==0))','r-','LineWidth',1)
%         plot(Vin,(orbital_energies_up.*(orbital_occ_up==1))','b-','LineWidth',1)
%         plot(Vin,(orbital_energies_down.*(orbital_occ_down==0))','r--','LineWidth',1)
%         plot(Vin,(orbital_energies_down.*(orbital_occ_down==1))','b--','LineWidth',1)
%         xlabel('Vin'), ylabel('Energy [eV]'), grid minor
%         title('-UP -- DOWN')



end
generateFile(SCERPA_tcFolderPath,SCERPA_infoFileName,SCERPA_infoFileContent)
    

%% potential plot
% 
% select potential to plot
% to_plot1 = find(TCDATA_Vin==min(TCDATA_Vin));
% to_plot2 = find(abs(TCDATA_Vin)==min(abs(TCDATA_Vin)));
% to_plot3 = find(TCDATA_Vin==max(TCDATA_Vin));
% potentialMap_size = 300;
% 
% evaluation mesh
% x_span = linspace(min(molGeometry.x)-5,max(molGeometry.x)+5,potentialMap_size);
% y_span = linspace(min(molGeometry.y)-5,max(molGeometry.y)+5,potentialMap_size);
% z = max(molGeometry.z)+1;
% [x,y] = meshgrid(x_span,y_span);
% 
% evaluate ESP
% for ii=1:potentialMap_size
%     for jj=1:potentialMap_size
%         pos.x = x(ii,jj);
%         pos.y = y(ii,jj);
%         pos.z = z;
% 
%         molESP_1(ii,jj) = EvaluatePotential(tc_simulation(to_plot1),pos);
%         molESP_2(ii,jj) = EvaluatePotential(tc_simulation(to_plot2),pos);
%         molESP_3(ii,jj) = EvaluatePotential(tc_simulation(to_plot3),pos);
% 
%         
%         if userSettings.TC_OPTIMUMPOSITION == true
%             SP_ESP(ii,jj) = EvaluatePotential(SP_molecule,pos);
%         end
%     end
% end
% 
% 
% plot
% zmin = min([min(molESP_1),min(molESP_2),min(molESP_3)]);
% zmax = max([min(molESP_1),max(molESP_2),max(molESP_3)]);
% figure(5);
% subplot(2,4,1)
%     surf(x,y,0*x-5,molESP_1,'EdgeColor','none','LineStyle','none'), hold on
%     Display_Molecule(molGeometry)
%     text(mean(molGeometry.x)-2.5,min(molGeometry.y)-2.5,-5,sprintf('[%.2f %.2f %.2f]',tc_simulation(to_plot1).dipole))
%     colormap('turbo'),colormap(flipud(colormap)),colorbar('Location','northoutside'), clim([zmin zmax])
%     axis equal
%     title(string(TCDATA_Vin(to_plot1)))
%     view([0,90])
% subplot(2,4,2)
%     surf(x,y,0*x-5,molESP_2,'EdgeColor','none','LineStyle','none'), hold on
%     Display_Molecule(molGeometry)
%     text(mean(molGeometry.x)-2.5,min(molGeometry.y)-2.5,-5,sprintf('[%.2f %.2f %.2f]',tc_simulation(to_plot2).dipole))
%     colormap('turbo'),colormap(flipud(colormap)),colorbar('Location','northoutside'), clim([zmin zmax])
%     axis equal
%     title(string(TCDATA_Vin(to_plot2)))
%     view([0,90])
% subplot(2,4,3)
%     surf(x,y,0*x-5,molESP_3,'EdgeColor','none','LineStyle','none'), hold on
%     Display_Molecule(molGeometry)
%     text(mean(molGeometry.x)-2.5,min(molGeometry.y)-2.5,-5,sprintf('[%.2f %.2f %.2f]',tc_simulation(to_plot3).dipole))
%     colormap('turbo'),colormap(flipud(colormap)),colorbar('Location','northoutside'), clim([zmin zmax])
%     axis equal
%     title(string(TCDATA_Vin(to_plot3)))
%     view([0,90])
% 
% ESP variation
% subplot(2,4,4)
%     surf(x,y,0*x-5,molESP_1-molESP_3,'EdgeColor','none','LineStyle','none'), hold on
%     Display_Molecule(molGeometry)
%     colormap('turbo'),colormap(flipud(colormap)),colorbar('Location','northoutside')
%     title("ESP difference")
%     axis equal
%     view([0,90])
% 
% vdw
% subplot(2,4,5)
%     EvaluateVdWPotential(tc_simulation(to_plot1));
%     title(string(TCDATA_Vin(to_plot1)))
%     clim1 = clim;
% subplot(2,4,6)
%     EvaluateVdWPotential(tc_simulation(to_plot2));
%     title(string(TCDATA_Vin(to_plot2)))
%     clim2 = clim;
% subplot(2,4,7)
%     EvaluateVdWPotential(tc_simulation(to_plot3));
%     title(string(TCDATA_Vin(to_plot3)))
%     clim3 = clim;
% 
% minMEP = min([clim1(1),clim2(1),clim3(1)],[],'all');
% maxMEP = max([clim1(2),clim2(2),clim3(2)],[],'all');
% subplot(2,4,5), clim([minMEP,maxMEP])
% subplot(2,4,6), clim([minMEP,maxMEP])
% subplot(2,4,7), clim([minMEP,maxMEP])
% 
% %add esp on figure(1)
% figure(1)
% subplot(1,3,3), hold on %plot position on the ESP
%     plot(DOT_coords(:,1),DOT_coords(:,2),'k.','MarkerSize',15)
%     axis equal
%     if userSettings.TC_OPTIMUMPOSITION == true
%         surf(x,y,0*x-5,SP_ESP,'EdgeColor','none','LineStyle','none'), hold on
%         colormap('turbo'),colormap(flipud(colormap)),colorbar('Location','northoutside'), clim([zmin zmax])
%         axis equal
%         view([0,90])
%     end

%model evaluation 
figure(7)
    DisplayMoleculeScatter(molGeometry), hold on
    plot3(DOT_coords(:,1),DOT_coords(:,2),DOT_coords(:,3),'.k','MarkerSize',20)
    scatter3(DOT_coords(1,1),DOT_coords(1,2),DOT_coords(1,3),'r','filled')
    scatter3(DOT_coords(2,1),DOT_coords(2,2),DOT_coords(2,3),'g','filled')
    plot3([posVout1.x posVout2.x],[posVout1.y posVout2.y],[posVout1.z posVout2.z],'ok','LineStyle','--')
    axis equal
    %print associations
    for aa=1:size(userSettings.SCERPA_ASSOC,1)
        plot3(...
            [DOT_coords(userSettings.SCERPA_ASSOC(aa,1),1) DOT_coords(userSettings.SCERPA_ASSOC(aa,2),1)],...
            [DOT_coords(userSettings.SCERPA_ASSOC(aa,1),2) DOT_coords(userSettings.SCERPA_ASSOC(aa,2),2)],...
            [DOT_coords(userSettings.SCERPA_ASSOC(aa,1),3) DOT_coords(userSettings.SCERPA_ASSOC(aa,2),3)],'k')
        
    end
figure(8)
    plot(Vin,Vout,'LineWidth',3)
    hold on
    plot(Vin,Vout_AC,'LineWidth',3)
    xlabel('Vin (V)'), ylabel('Vout (V)')
    hold on
    yyaxis right, plot(Vin,Vout-Vout_AC,'--g','LineWidth',2)
    legend('ORCA','ACmodel','Error')

figure(9); clf
hold on; box on;

% colori scuri
colX = [0.8 0 0];   % rosso scuro
colY = [0 0.6 0];   % verde scuro
colZ = [0 0 0.8];   % blu scuro

% --- calcolo errori medi ---
errX = mean(abs(dipole_AC(1,:) - dipole_DFT(1,:).*2.54));
errY = mean(abs(dipole_AC(2,:) - dipole_DFT(2,:).*2.54));
errZ = mean(abs(dipole_AC(3,:) - dipole_DFT(3,:).*2.54));

errors_x(end+1) = errX;
errors_y(end+1) = errY;
errors_z(end+1) = errZ;

% curve AC (continue, trasparenti)
plot(Vin, dipole_AC(1,:), 'Color', [colX 0.5], 'LineWidth', 3);
plot(Vin, dipole_AC(2,:), 'Color', [colY 0.5], 'LineWidth', 3);
plot(Vin, dipole_AC(3,:), 'Color', [colZ 0.5], 'LineWidth', 3);

% curve DFT (tratteggiate, opache)
plot(Vin, dipole_DFT(1,:).*2.54, '--', 'Color', colX, 'LineWidth', 2.5);
plot(Vin, dipole_DFT(2,:).*2.54, '--', 'Color', colY, 'LineWidth', 2.5);
plot(Vin, dipole_DFT(3,:).*2.54, '--', 'Color', colZ, 'LineWidth', 2.5);

% etichette assi
xlabel('$V_{in}$ [V]', 'Interpreter','latex', 'FontSize',14)
ylabel('Dipole moment [D]', 'Interpreter','latex', 'FontSize',14)

% legenda con errore medio
legend({sprintf('$\\mu_x$ (AC) [err=%.2f]',errX), ...
        sprintf('$\\mu_y$ (AC) [err=%.2f]',errY), ...
        sprintf('$\\mu_z$ (AC) [err=%.2f]',errZ), ...
        '$\mu_x$ (DFT)','$\mu_y$ (DFT)','$\mu_z$ (DFT)'}, ...
        'Interpreter','latex','Location','best','FontSize',12)

% stile assi
set(gca, 'FontSize', 12, 'LineWidth',1.2)


    
fprintf("Max error in the Vin/Vout %.3f V \n",max(abs(Vout-Vout_AC)))


%assoctable creation
Files = {tc_fileList(sortI).name}';
assoctable = table(Vin',Files,dipole_DFT',dotCharge',Vout', 'VariableNames',{'Vin','Files','Dipole','AC', 'Vout'});   
disp(assoctable)


end
