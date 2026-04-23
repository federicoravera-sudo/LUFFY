function settings = initSettings(comboNumber, cfIndex, nature, charAtoms)
%INITSETTINGS Initialize the settings struct for autochar workflow
%
%   settings = initSettings(comboNumber, cfIndex, nature, charAtoms)
%
%   comboNumber : integer ID of the molecule combo (e.g. 30)
%   cfIndex     : integer index of the conformer
%   nature      : string descriptor (e.g. "Ox")
%   charAtoms   : vector of atom indices used for CHAR alignment
%
%   Returns a struct `settings` with all required fields.

    % ---- Basic identifiers ----
    settings.MOLECULE_NAME    = sprintf("Combo%d_Cf%d", comboNumber, cfIndex);
    settings.MOLECULE_FORMULA = settings.MOLECULE_NAME;
    settings.WORKSPACE        = sprintf("Conformers%sWs\\Combo%d_Cf%d", ...
                                        nature, comboNumber, cfIndex);
    settings.CHAR_ATOMS       = charAtoms;
    settings.DB_GEOMNUMBER    = 1;

    % ---- Geometry ----
    settings.GEOMETRY_COMMENT = "Automatic conformer generation";
    settings.GEOMETRY_FILE    = sprintf( ...
        "C:\\Users\\55fed\\OneDrive - Politecnico di Torino\\Dottorato\\Molecules_DB\\DFTB\\Transport\\W15\\NanoribbonNoMol\\NewTrials_0508\\Combo%d\\Crest\\Conformers\\Conformer%d.txt", ...
        comboNumber, cfIndex);

    % ---- Ab initio setup ----
    settings.ABINITIO_METHOD      = "UKS OPT";         % method
    settings.ABINITIO_FUNCTIONAL  = "CAM-B3LYP";       % functional
    settings.ABINITIO_BASISSET    = "def2-TZVP";       % basis set
    settings.ABINITIO_CORRECTIONS = "D4";              % dispersion correction
    settings.ABINITIO_NPROC       = 36;                % number of processors
    settings.ABINITIO_OPTIONS     = "";                % extra flags (optional)

    % ---- Characterisation setup ----
    settings.CHAR_MODE            = "FIELD";           % "SW" or "FIELD"
    settings.CHAR_CLOCKS_LIST     = 0;                 % list of clock fields (V/nm)
    settings.CHAR_CLOCKS_DIST     = 80;                % distance for clock field (Å)
    settings.CHAR_MAXCHARGE       = 1;                 % max charge for SW mode
    settings.CHAR_SPAN            = 0.2;               % charge span for SW
    settings.CHAR_MAXFIELD        = 1;                 % max field (V/nm) for FIELD
    settings.CHAR_FIELDMODE_DIST  = 50;                % distance for FIELD mode
    settings.CHAR_POINTS          = 21;                % number of sampling points

    % ---- Transcharacteristic setup ----
    settings.TC_ACNUMBER          = 3;                 % number of dots
    settings.AC_THRESHOLD         = 2;                 % Å threshold for dot partition

end
