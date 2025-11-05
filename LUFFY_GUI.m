function params = LUFFY_GUI()
    % ====================================================================
    % MATLAB GUI to configure LUFFY parameters
    % Returns a struct "params" containing all selected values
    % ====================================================================

    fig = uifigure('Name','LUFFY Configuration', ...
                   'Position',[100 100 480 500], ...
                   'Resize','on');

    % --- Molecule name input ---
    uilabel(fig,'Position',[30 450 150 20], ...
            'Text','Molecule short name:','FontWeight','bold');
    edit_molecule = uieditfield(fig,'text', ...
                    'Position',[190 450 220 22], ...
                    'Value','Combo10');

    % --- VACT analysis name input ---
    uilabel(fig,'Position',[30 420 150 20], ...
            'Text','VACT analysis name:','FontWeight','bold');
    edit_VACT = uieditfield(fig,'text', ...
                  'Position',[190 420 220 22], ...
                  'Value','02_characterisation_folder_ck0');

    % --- Section: Execution flags ---
    uilabel(fig,'Position',[30 390 200 20], ...
            'Text','Execution flags:','FontWeight','bold');
    cb_LUFFYsim = uicheckbox(fig,'Text','LUFFYsimulation','Position',[30 365 150 22]);
    cb_LUFFYload = uicheckbox(fig,'Text','LUFFYload','Position',[200 365 150 22]);
    cb_LUFFYanalysis = uicheckbox(fig,'Text','LUFFYanalysis','Position',[30 340 150 22]);

    % --- Section: File preparation flags ---
    uilabel(fig,'Position',[30 310 250 20], ...
            'Text','File preparation flags:','FontWeight','bold');
    cb_opt = uicheckbox(fig,'Text','Optimization (opt)','Position',[30 285 150 22]);
    cb_SP = uicheckbox(fig,'Text','Single Point (SP)','Position',[200 285 150 22]);
    cb_VACT = uicheckbox(fig,'Text','VACT Analysis','Position',[30 260 150 22]);
    cb_extract = uicheckbox(fig,'Text','Extract conformers','Position',[200 260 170 22]);

   % --- Section: Analysis options ---
uilabel(fig,'Position',[30 230 200 20], ...
    'Text','Analysis options:','FontWeight','bold');
cb_analysis = uicheckbox(fig,'Text','Run VACT extraction','Position',[30 205 170 22]);
cb_singleSPanalysis = uicheckbox(fig,'Text','Run single SP analysis','Position',[200 205 180 22]);

% --- Add new molecule button ---
uibutton(fig, 'Text', '➕ Add new molecule to database', ...
    'Position', [30 175 220 25], ...
    'BackgroundColor', [0.8 0.9 1], ...
    'FontWeight', 'bold', ...
    'ButtonPushedFcn', @(btn,event) addNewMoleculeDialog());

% --- Analyse database button ---
uibutton(fig, 'Text', '🔍 Analyse database', ...
    'Position', [270 175 180 25], ...
    'BackgroundColor', [0.9 0.95 0.9], ...
    'FontWeight', 'bold', ...
    'ButtonPushedFcn', @(btn,event) analyseDatabaseDialog());

% --- Generate Boltzmann Button ---
btn_boltzmann = uibutton(fig, 'Text', sprintf('Generate Boltzmann'), ...
    'Position', [30 150 200 25], ...
    'BackgroundColor', [1 0.85 0.75], ...
    'FontWeight', 'bold', ...
    'ButtonPushedFcn', @(btn,event) generateBoltzmannDialog(edit_molecule.Value, edit_VACT.Value));

% --- Check MD Analysis button ---
uibutton(fig, 'Text', '📈 Check MD analysis', ...
    'Position', [250 145 200 25], ...
    'BackgroundColor', [0.95 0.9 0.8], ...
    'FontWeight', 'bold', ...
    'ButtonPushedFcn', @(btn,event) checkMDanalysisDialog(edit_molecule.Value, edit_VACT.Value));



% === Spostiamo la sezione sotto di ~70 pixel ===
baseShift = -70;  % valore di spostamento verticale

% --- Section: Numeric / text inputs ---
uilabel(fig,'Position',[30 175+baseShift 200 20], ...
        'Text','Simulation parameters:','FontWeight','bold');

uilabel(fig,'Text','Min conformer index:', 'Position',[30 150+baseShift 150 20]);
edit_min = uieditfield(fig,'numeric','Position',[180 150+baseShift 60 22],'Value',1);

uilabel(fig,'Text','Max conformer index:', 'Position',[260 150+baseShift 150 20]);
edit_max = uieditfield(fig,'numeric','Position',[410 150+baseShift 40 22],'Value',4);

uilabel(fig,'Text','Number of atoms:', 'Position',[30 125+baseShift 150 20]);
edit_atoms = uieditfield(fig,'text','Position',[180 125+baseShift 100 22],'Value','83');

uilabel(fig,'Text','Charge:', 'Position',[30 100+baseShift 60 20]);
edit_charge = uieditfield(fig,'numeric','Position',[90 100+baseShift 50 22],'Value',1);

uilabel(fig,'Text','Multiplicity:', 'Position',[160 100+baseShift 80 20]);
edit_mult = uieditfield(fig,'numeric','Position',[240 100+baseShift 50 22],'Value',3);

uilabel(fig,'Text','Processors (nprocs):', 'Position',[30 75+baseShift 130 20]);
edit_nprocs = uieditfield(fig,'numeric','Position',[180 75+baseShift 80 22],'Value',64);

uilabel(fig,'Text','ck value:', 'Position',[280 75+baseShift 60 20]);
edit_ckValue = uieditfield(fig,'numeric','Position',[340 75+baseShift 50 22],'Value',+1);

uilabel(fig,'Text','ck flag:', 'Position',[280 50+baseShift 60 20]);
edit_ck = uieditfield(fig,'numeric','Position',[340 10+baseShift 120 30],'Value',0);


    % --- Confirm button ---
    uibutton(fig,'Text','Confirm','Position',[350 100 60 20], ...
             'ButtonPushedFcn', @(btn,event) uiresume(fig));
uibutton(fig, 'Text', 'Close', ...
         'Position', [280 100 60 20], ...
         'ButtonPushedFcn', @(btn,event) close(fig));
    % --- Wait for user input ---
    uiwait(fig);

    % --- Collect values ---
    params.moleculeShortName   = edit_molecule.Value;
    params.VACTanalysisName    = edit_VACT.Value;
    params.max_indexCf         = edit_max.Value;
    params.min_indexCf         = edit_min.Value;
    params.LUFFYsimulation     = cb_LUFFYsim.Value;
    params.LUFFYload           = cb_LUFFYload.Value;
    params.LUFFYanalysis       = cb_LUFFYanalysis.Value;
    params.opt                 = cb_opt.Value;
    params.SP                  = cb_SP.Value;
    params.set_VACT_analysis   = cb_VACT.Value;
    params.extract_conf        = cb_extract.Value;
    params.analysis            = cb_analysis.Value;
    params.singleSPanalysis    = cb_singleSPanalysis.Value;
    params.ck                  = edit_ck.Value;
    params.numberofAtoms       = edit_atoms.Value;
    params.ckValue             = edit_ckValue.Value;
    params.charge              = edit_charge.Value;
    params.mult                = edit_mult.Value;
    params.nprocs              = edit_nprocs.Value;

    % --- Close GUI ---
    close(fig);
end


function addNewMoleculeDialog()
    choice = questdlg('Select the type of molecule to add:', ...
                      'Add Molecule', ...
                      'Oxidized', 'Neutral', 'Cancel', 'Neutral');

    if strcmp(choice, 'Cancel') || isempty(choice)
        return;
    end

    % --- Richiesta dei dati principali ---
    prompt = {'Molecule name:', 'Number of conformers:'};
    dlgtitle = ['Add new ' choice ' molecule'];
    dims = [1 50];
    definput = {'', '1'};
    answer = inputdlg(prompt, dlgtitle, dims, definput);

    if isempty(answer)
        return;
    end

    % --- Conversione dati ---
    newMol = struct('Name', answer{1}, ...
                    'NumConformers', str2double(answer{2}), ...
                    'Type', choice);

   extract_LUFFY_toDatabase(newMol.Name, newMol.NumConformers, newMol.Type)

    % --- Messaggio di conferma ---
    msg = sprintf('Molecule "%s" (%s, %d conformers) added to %s database.', ...
                  newMol.Name, newMol.Type, newMol.NumConformers, lower(choice));
    uialert(uifigure, msg, 'Success');
end

function analyseDatabaseDialog()
    % ================================================================
    % Step 1: scelta database
    % ================================================================
    dbChoice = questdlg('Select which database to analyse:', ...
                        'Analyse Database', ...
                        'Oxidized', 'Neutral', 'Cancel', 'Oxidized');

    if strcmp(dbChoice, 'Cancel') || isempty(dbChoice)
        return;
    end

    % --- Carica il database corrispondente ---
    if strcmp(dbChoice, 'Oxidized')
        dbfile = "C:\Users\55fed\OneDrive - Politecnico di Torino\Dottorato\Molecules_DB\DFTB\the-molecular-suite-developer2\autochar\LUFFY\DatabaseMol\DatabaseOx.xlsx";
    else
        dbfile = "C:\Users\55fed\OneDrive - Politecnico di Torino\Dottorato\Molecules_DB\DFTB\the-molecular-suite-developer2\autochar\LUFFY\DatabaseMol\DatabaseNeutral.xlsx";
    end

    if ~isfile(dbfile)
        uialert(uifigure, sprintf('Database "%s" not found.', dbChoice), 'Error');
        return;
    end

      % Legge il database Excel come tabella
    data = readtable(dbfile);
    if isempty(data)
        uialert(uifigure, sprintf('The "%s" database is empty.', dbChoice), 'Warning');
        return;
    end

    % ================================================================
    % Step 2: finestra analisi disponibili
    % ================================================================
    fig = uifigure('Name', ['Database Analysis – ' dbChoice], ...
                   'Position', [100 100 420 420], ...
                   'Resize', 'off');

    uilabel(fig, 'Position', [20 385 300 22], ...
            'Text', 'Select analyses to perform:', ...
            'FontWeight', 'bold');

    % --- Checkboxes per analisi ---
    cb_scatter = uicheckbox(fig, 'Text', 'Scatter two variables with correlation', ...
                            'Position', [20 350 250 22]);

    % Dropdown per variabili scatter
variables = {'SinglePointEnergyeV', 'DipoleX', 'DipoleY', 'DipoleZ', ...
             'HOMO', 'LUMO', 'HOMOLUMO_gap', 'PolarizabilityIsotropic'};


    uilabel(fig, 'Text', 'Variable X:', 'Position', [40 320 70 22]);
    dd_x = uidropdown(fig, 'Items', variables, 'Position', [110 320 120 22]);

    uilabel(fig, 'Text', 'Variable Y:', 'Position', [240 320 70 22]);
    dd_y = uidropdown(fig, 'Items', variables, 'Position', [310 320 90 22]);

    % --- Altre analisi ---
    cb_pearson = uicheckbox(fig, 'Text', 'Compute Pearson correlation matrix', ...
                            'Position', [20 280 300 22]);
    cb_pca = uicheckbox(fig, 'Text', 'Run PCA and clustering analysis', ...
                        'Position', [20 250 250 22]);
    cb_bar = uicheckbox(fig, 'Text', 'Plot bar charts (Dipole X/Y, Isotropic polarizability)', ...
                        'Position', [20 220 350 22]);

    % --- Bottone di esecuzione ---
    uibutton(fig, 'Text', 'Run Selected Analyses', ...
        'FontWeight', 'bold', ...
        'BackgroundColor', [0.7 0.9 0.7], ...
        'Position', [120 160 180 30], ...
        'ButtonPushedFcn', @(~,~) runDatabaseAnalyses(dbChoice, data, ...
                                                      cb_scatter.Value, ...
                                                      dd_x.Value, dd_y.Value, ...
                                                      cb_pearson.Value, ...
                                                      cb_pca.Value, ...
                                                      cb_bar.Value));

    % --- Bottone di chiusura ---
    uibutton(fig, 'Text', 'Close', ...
             'Position', [170 110 80 25], ...
             'ButtonPushedFcn', @(btn,event) close(fig));
end


function generateBoltzmannDialog(moleculeName, VACTname)

    % Converti a string
    moleculeName = string(moleculeName);
    VACTname     = string(VACTname);

    % 1) Input temperatura
    answer = inputdlg({'Temperature (K):'}, 'Boltzmann Population Analysis', 1, {'298'});
    if isempty(answer), return; end
    T = str2double(answer{1});
    if isnan(T) || T <= 0
        uialert(uifigure, 'Invalid temperature.', 'Error');
        return;
    end
    kT = 8.617333e-5 * T; % eV

    % 2) Scelta database Neutral / Oxidized
    dbChoice = questdlg('Select molecule charge state:', ...
                        'Database Selection', ...
                        'Neutral', 'Oxidized', 'Cancel', 'Neutral');
    if strcmp(dbChoice, 'Cancel'), return; end

    % 3) Paths
    baseDir = "C:\Users\55fed\OneDrive - Politecnico di Torino\Dottorato\Molecules_DB\DFTB\the-molecular-suite-developer2\autochar\LUFFY\DatabaseMol\";
    targetDir = fullfile(baseDir, moleculeName);

    if strcmp(dbChoice,'Neutral')
        dbFile = fullfile(baseDir, "DatabaseNeutral.xlsx");
    else
        dbFile = fullfile(baseDir, "DatabaseOx.xlsx");
    end

    % 4) Carica database energie
    DB = readtable(dbFile);
    DB = DB(strcmpi(DB.Molecule, moleculeName), :); % Filtra solo la molecola
    if isempty(DB)
        uialert(uifigure, 'Molecule not found in database.', 'Error');
        return;
    end
    energies = DB.SinglePointEnergy_eV_; % vettore energie

% 5) Cerca i file VACT della molecola (escludendo file generati)
VACTname = string(VACTname);
pattern = "*" + VACTname + "*.txt";
files = dir(fullfile(targetDir, pattern));

% Filtra fuori i file Boltzmann precedenti
filenames = string({files.name});
mask = ~contains(filenames, "Boltzmann", "IgnoreCase", true);
files = files(mask);

if isempty(files)
    uialert(uifigure, sprintf('No valid VACT files found for "%s" (excluding Boltzmann outputs).', VACTname), 'Warning');
    return;
end
    fprintf("\n🔥 Found %d conformer VACT curves.\n", numel(files));

    dipole_curves = {};
    all_curves = {};

%% 6) Leggi file e plottali
fprintf("\n📂 Reading and plotting VACT curves:\n");

figure('Name','VACT Curves per Conformer','Color','white'); hold on;

for i = 1:numel(files)
    fname = fullfile(files(i).folder, files(i).name);
    fprintf("   → (%d/%d) %s\n", i, numel(files), files(i).name);

    % Leggi file
    TBL = readtable(fname, "Delimiter", ",", "ReadVariableNames", true);

    % Trova asse VIN automaticamente
    if any(strcmpi(TBL.Properties.VariableNames, "Vin"))
        x = TBL.Vin;
    else
        x = TBL{:,1}; % usa prima colonna se "Vin" non esiste
    end

    % Estrai curve
    dipole_curves{i,1} = TBL.Dipole_1;
    dipole_curves{i,2} = TBL.Dipole_2;
    dipole_curves{i,3} = TBL.Dipole_3;

    all_curves{i,1} = TBL.AC_1;
    all_curves{i,2} = TBL.AC_2;
    all_curves{i,3} = TBL.AC_3;

    % === Plot: AC curves per conformero (trasparenti) ===
    plot(x, all_curves{i,1}, 'Color', [1 0 0 0.15], 'LineWidth', 2);
    plot(x, all_curves{i,2}, 'Color', [0 1 0 0.15], 'LineWidth', 2);
    plot(x, all_curves{i,3}, 'Color', [0 0 1 0.15], 'LineWidth', 2);

    % (Opzionale) testo di etichetta
    text(x(end), all_curves{i,1}(end), sprintf(" Cf%d", i), 'FontSize', 8);
end

xlabel('V_{in} (V)');
ylabel('AC curves');
title(sprintf('%s — Raw conformer response curves', moleculeName), 'Interpreter','none');
grid on; box on;

fprintf("\n✅ Raw conformer curves plotted.\n");


    % 7) Boltzmann weights
    deltaE = energies - min(energies);
    weights = exp(-deltaE / kT);
    weights = weights / sum(weights);

    % 8) Media pesata
    x_axis      =  x;
    media_AC1   = zeros(size(x_axis));
    media_AC2   = zeros(size(x_axis));
    media_AC3   = zeros(size(x_axis));
    media_dip1  = zeros(size(x_axis));
    media_dip2  = zeros(size(x_axis));
    media_dip3  = zeros(size(x_axis));

    for i = 1:numel(files)
        media_AC1  = media_AC1 + weights(i)*all_curves{i,1};
        media_AC2  = media_AC2 + weights(i)*all_curves{i,2};
        media_AC3  = media_AC3 + weights(i)*all_curves{i,3};
        media_dip1 = media_dip1 + weights(i)*dipole_curves{i,1};
        media_dip2 = media_dip2 + weights(i)*dipole_curves{i,2};
        media_dip3 = media_dip3 + weights(i)*dipole_curves{i,3};
    end

    AC4 = zeros(size(x_axis));

    fprintf("\n✅ Boltzmann weighting complete.\n");

    % 9) Costruzione tabella risultati
    T_out = table(x_axis, media_AC1, media_AC2, media_AC3, AC4, ...
                  x_axis, media_dip1, media_dip2, media_dip3, ...
                  'VariableNames', {'x_axis','media_AC1','media_AC2','media_AC3','AC4', ...
                                    'x_axis_dip','media_dip1','media_dip2','media_dip3'});

    outFile = fullfile(targetDir, moleculeName + "_Boltzmann_" + VACTname + ".txt");
    writetable(T_out, outFile, 'Delimiter', '\t');
    fprintf("💾 Saved weighted results to:\n%s\n\n", outFile);

    %10) Plot AC curves
    figure; hold on;
    plot(x_axis, media_AC1, 'Color',[0.5 0 0],'LineWidth',4);
    plot(x_axis, media_AC2, 'Color',[0 0.4 0],'LineWidth',4);
    plot(x_axis, media_AC3, 'Color',[0 0 0.5],'LineWidth',4);

    for i = 1:numel(files)
        plot(x_axis, all_curves{i,1}, '--', 'Color', [1 0 0 0.1], 'LineWidth', 2);
        plot(x_axis, all_curves{i,2}, '--', 'Color', [0 1 0 0.1], 'LineWidth', 2);
        plot(x_axis, all_curves{i,3}, '--', 'Color', [0 0 1 0.1], 'LineWidth', 2);
    end
    xlabel('Vin (V)'); ylabel('Weighted AC'); grid on;

    %11) Plot Dipoles
    figure; hold on;
    colX=[0.6 0 0]; colY=[0 0.4 0]; colZ=[0 0 0.5];
    plot(x_axis, media_dip1*2.54, '-', 'Color', colX,'LineWidth',4);
    plot(x_axis, media_dip2*2.54, '-', 'Color', colY,'LineWidth',4);
    plot(x_axis, media_dip3*2.54, '-', 'Color', colZ,'LineWidth',4);

    for i = 1:numel(files)
        plot(x_axis, dipole_curves{i,1}*2.54, '-', 'Color',[colX 0.05],'LineWidth',2.5);
        plot(x_axis, dipole_curves{i,2}*2.54, '-', 'Color',[colY 0.05],'LineWidth',2.5);
        plot(x_axis, dipole_curves{i,3}*2.54, '-', 'Color',[colZ 0.05],'LineWidth',2.5);
    end

    xlabel('$V_{in}$ (V)','Interpreter','latex');
    ylabel('$\mu$ (D)','Interpreter','latex');
    set(gca,'FontSize',12,'LineWidth',1.2);

end



function checkMDanalysisDialog(moleculeName, VACTname)

    moleculeName = string(moleculeName);
    VACTname     = string(VACTname);

    % === 0) Chiedi Vin target ===
    answer = inputdlg({'Vin target value (V):'}, 'Select Vin', 1, {'0.0'});
    if isempty(answer), return; end
    Vin_target = str2double(answer{1});
    if isnan(Vin_target)
        uialert(uifigure, "Invalid Vin value.", "Error");
        return;
    end

    % === 1) Selezione file MD ===
    [xyz_file, xyz_path] = uigetfile({'*.xyz','XYZ Trajectory (*.xyz)'}, 'Select XYZ trajectory file');
    if isequal(xyz_file,0), return; end
    xyz_filename = fullfile(xyz_path, xyz_file);

    [out_file, out_path] = uigetfile({'*.out','DFTB Output (*.out)'}, 'Select MD OUT file');
    if isequal(out_file,0), return; end
    out_filename = fullfile(out_path, out_file);

    % === 2) Gruppi AC ===
    ACListAtoms{1} = [8 35 25 26 27 28 29 30 39 40 41 42 43 34 45 18 55 70 73 71 48 62 69 60 67 65]; 
    ACListAtoms{2} = [14 44 20 21 22 23 24 19 31 32 33 15 46 36 37 38 64 54 63 59 3 57 49 9 12 72];
    ACListAtoms{3} = [1 2 50 4 5 6 7 17 61 10 11 52 13 16 47 56 58 53 51 66 68];

    frame_idx_max = 1048;
    dipoli = extractDipolesMD(xyz_filename, out_filename, ACListAtoms, frame_idx_max);
    dipole_means = mean(dipoli, 1);   % MD average dipole [x y z]

    % Convert to Debye
    dipole_means = dipole_means;

    % === 3) Carica curva Boltzmann ===
    baseDir = "C:\Users\55fed\OneDrive - Politecnico di Torino\Dottorato\Molecules_DB\DFTB\the-molecular-suite-developer2\autochar\LUFFY\DatabaseMol\";
    boltzFile = fullfile(baseDir, moleculeName, moleculeName + "_Boltzmann_" + VACTname + ".txt");

    if ~isfile(boltzFile)
        uialert(uifigure, "Boltzmann analysis not found. Run Boltzmann first.", "Error");
        return;
    end

    T = readtable(boltzFile, 'Delimiter', '\t');
    Vin = T.x_axis_dip;
    Dipole = [T.media_dip1, T.media_dip2, T.media_dip3] * 2.54;

    % === 4) Interp Boltzmann @ Vin_target ===
    dip_boltz_at_target = interp1(Vin, Dipole, Vin_target);

    % === 5) Carica anche Cf1 ===
    cf1file = fullfile(baseDir, moleculeName, VACTname+ "_Cf1"  + ".txt");
    if isfile(cf1file)
        Cf1 = readmatrix(cf1file);
        dip_cf1_at_target = interp1(Cf1(:,1), [Cf1(:,3) Cf1(:,4) Cf1(:,5)]*2.54, Vin_target);
    else
        dip_cf1_at_target = [NaN NaN NaN];
    end

    % === 6) Calcola errori ===
    err_MD_vs_Boltz = dip_boltz_at_target - dipole_means;
    err_Cf1_vs_Boltz = dip_boltz_at_target - dip_cf1_at_target;

    fprintf("\n---- Dipole Comparison at Vin = %.3f V ----\n", Vin_target);
    fprintf("Boltzmann:    [%.3f  %.3f  %.3f] D\n", dip_boltz_at_target);
    fprintf("MD average:   [%.3f  %.3f  %.3f] D   →  Error: [%.3f  %.3f  %.3f]\n", dipole_means, err_MD_vs_Boltz);
    fprintf("Cf1:          [%.3f  %.3f  %.3f] D   →  Error: [%.3f  %.3f  %.3f]\n\n", dip_cf1_at_target, err_Cf1_vs_Boltz);

    %% === 7) Plot Boltzmann vs MD ===
figure('Name',"MD vs Boltzmann Dipole",'Color','white'); hold on;
colX=[0.6 0 0]; colY=[0 0.4 0]; colZ=[0 0 0.5];

plot(Vin, Dipole(:,1), '-', 'Color', colX, 'LineWidth', 3, 'DisplayName','\mu_x (Boltz)');
plot(Vin, Dipole(:,2), '--', 'Color', colY, 'LineWidth', 3, 'DisplayName','\mu_y (Boltz)');
plot(Vin, Dipole(:,3), '-.', 'Color', colZ, 'LineWidth', 3, 'DisplayName','\mu_z (Boltz)');

yline(dipole_means(1), '-', 'Color', colX, 'LineWidth', 2, 'DisplayName','<\mu_x>_{MD}');
yline(dipole_means(2), '-', 'Color', colY, 'LineWidth', 2, 'DisplayName','<\mu_y>_{MD}');
yline(dipole_means(3), '-', 'Color', colZ, 'LineWidth', 2, 'DisplayName','<\mu_z>_{MD}');

xline(Vin_target, ':k','LineWidth',2,'DisplayName',sprintf('Vin = %.3f',Vin_target));

xlabel('V_{in} (V)');
ylabel('Dipole (Debye)');
legend('Location','best','Interpreter','latex');
grid on; box on;


%% === 8) Plot Cf1 vs MD ===
if ~isnan(dip_cf1_at_target(1))
    figure('Name',"MD vs Cf1 Dipole",'Color','white'); hold on;

    plot(Cf1(:,1), Cf1(:,3)*2.54, '-',  'Color', colX, 'LineWidth', 3, 'DisplayName','\mu_x (Cf1)');
    plot(Cf1(:,1), Cf1(:,4)*2.54, '--', 'Color', colY, 'LineWidth', 3, 'DisplayName','\mu_y (Cf1)');
    plot(Cf1(:,1), Cf1(:,5)*2.54, '-.', 'Color', colZ, 'LineWidth', 3, 'DisplayName','\mu_z (Cf1)');

    % Linee orizzontali MD
    yline(dipole_means(1), '-', 'Color', colX, 'LineWidth', 2, 'DisplayName','<\mu_x>_{MD}');
    yline(dipole_means(2), '-', 'Color', colY, 'LineWidth', 2, 'DisplayName','<\mu_y>_{MD}');
    yline(dipole_means(3), '-', 'Color', colZ, 'LineWidth', 2, 'DisplayName','<\mu_z>_{MD}');

    % Linea verticale Vin
    xline(Vin_target, ':k','LineWidth',2,'DisplayName',sprintf('Vin = %.3f',Vin_target));

    xlabel('V_{in} (V)');
    ylabel('Dipole (Debye)');
    legend('Location','best','Interpreter','latex');
    grid on; box on;
end

fprintf("\n✅ Plots generated: (1) Boltz vs MD, (2) Cf1 vs MD\n\n");

end




