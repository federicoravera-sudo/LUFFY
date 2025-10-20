function params = LUFFY_GUI()
    % ====================================================================
    % MATLAB GUI to configure LUFFY parameters
    % Returns a struct "params" containing all selected values
    % ====================================================================

    fig = uifigure('Name','LUFFY Configuration', ...
                   'Position',[100 100 480 500], ...
                   'Resize','off');

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

    % --- Section: Numeric / text inputs ---
    uilabel(fig,'Position',[30 175 200 20], ...
            'Text','Simulation parameters:','FontWeight','bold');

    uilabel(fig,'Text','Min conformer index:', 'Position',[30 150 150 20]);
    edit_min = uieditfield(fig,'numeric','Position',[180 150 60 22],'Value',1);

    uilabel(fig,'Text','Max conformer index:', 'Position',[260 150 150 20]);
    edit_max = uieditfield(fig,'numeric','Position',[410 150 40 22],'Value',4);

    uilabel(fig,'Text','Number of atoms:', 'Position',[30 125 150 20]);
    edit_atoms = uieditfield(fig,'text','Position',[180 125 100 22],'Value','83');

    uilabel(fig,'Text','Charge:', 'Position',[30 100 60 20]);
    edit_charge = uieditfield(fig,'numeric','Position',[90 100 50 22],'Value',1);

    uilabel(fig,'Text','Multiplicity:', 'Position',[160 100 80 20]);
    edit_mult = uieditfield(fig,'numeric','Position',[240 100 50 22],'Value',3);

    uilabel(fig,'Text','Processors (nprocs):', 'Position',[30 75 130 20]);
    edit_nprocs = uieditfield(fig,'numeric','Position',[180 75 80 22],'Value',64);

    uilabel(fig,'Text','ck value:', 'Position',[280 75 60 20]);
    edit_ckValue = uieditfield(fig,'numeric','Position',[340 75 50 22],'Value',+1);

    uilabel(fig,'Text','ck flag:', 'Position',[280 50 60 20]);
    edit_ck = uieditfield(fig,'numeric','Position',[340 50 50 22],'Value',0);

    % --- Confirm button ---
    uibutton(fig,'Text','Confirm','Position',[180 10 120 30], ...
             'ButtonPushedFcn', @(btn,event) uiresume(fig));

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
