function settings = initSettings(moleculeName, ii,charAtomsMatrix, opt, charge, mult)
settings.MOLECULE_NAME        =   sprintf("%s_Cf%d",moleculeName,ii);
settings.MOLECULE_FORMULA     =   sprintf("%s_Cf%d",moleculeName,ii);
settings.WORKSPACE            =   sprintf("%s\\Cf%d",moleculeName,ii);
settings.CHAR_ATOMS = charAtomsMatrix;
settings.GEOMETRY_COMMENT     =   "Automatic file conformers generation";
settings.GEOMETRY_FILE        =   fullfile(pwd, moleculeName, "conformers",sprintf("Conformer%d.txt",ii));
settings.ABINITIO_CHARGE      =   charge;
settings.ABINITIO_MULT        =   mult;
if opt == 1
  settings.ABINITIO_METHOD      =   "UKS";
else
  settings.ABINITIO_METHOD      =   "UKS OPT";
end

settings.ABINITIO_FUNCTIONAL  =   "CAM-B3LYP";
settings.ABINITIO_BASISSET    =   "def2-TZVP";
settings.ABINITIO_CORRECTIONS =   "D4";
settings.ABINITIO_NPROC       =   64;

settings.ABINITIO_OPTIONS     =   ""; % for instance VerySlowConv and similar

settings.CHAR_MODE            =   "FIELD"; %SW or FIELD

settings.CHAR_CLOCKS_LIST     =   0; %V/nm
settings.CHAR_CLOCKS_DIST     =   80; %FIELD
settings.CHAR_MAXCHARGE       =   1; %SW
settings.CHAR_SPAN            =   0.2; %SW
settings.CHAR_MAXFIELD        =   1; % V/nm FIELD
settings.CHAR_FIELDMODE_DIST  =   50; %FIELD
settings.CHAR_POINTS          =   21; %FIELD

%transchar conf
settings.TC_ACNUMBER          =   3;
settings.AC_THRESHOLD         =   2;
settings.DB_GEOMNUMBER        =   1;
settings.working_path = pwd;
end