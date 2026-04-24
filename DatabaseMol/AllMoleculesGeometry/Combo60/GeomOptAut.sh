#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --partition=barnard
#SBATCH -J Combo60OptAC
#SBATCH --output=sdip1.out
#SBATCH --error=sdip1.err
#SBATCH -A p_qca
#SBATCH --ntasks-per-node=1
#SBATCH --nodes=2
#SBATCH --cpus-per-task=32
#SBATCH --mail-type=all
#SBATCH --mail-user=federico.ravera@tu-dresden.de
#SBATCH --mem-per-cpu=3900

# Initialize conda for the shell session
source ~/.bashrc
conda init bash
source ~/.bashrc

# Activate the conda environment
conda activate dftbplus


# Numero massimo di iterazioni
max_iter=2

# Iterazione sui file ConformerX.xyz
for (( i=1; i<=max_iter; i++ ))
do
    # Genera il nome del file
    xyz_file="Conformer${i}.xyz"
    gen_file="Conformer${i}.gen"
    output_dir="Conformer${i}"

    # Controlla se il file xyz esiste
    if [ ! -f "$xyz_file" ]; then
        echo "File $xyz_file non trovato, salto all'iterazione successiva."
        continue
    fi

    # Esegui il comando xyz2gen
    xyz2gen "$xyz_file"

    # Modifica il file di input dftb_in.hsd
    cat > dftb_in.hsd <<EOL
Geometry = genFormat {
<<< '$gen_file'
}

Driver = GeometryOptimization {
  Optimizer = Rational {} #optimiser, check for second derivative
  MovedAtoms = 1:-1
  MaxSteps = 3000
  OutputPrefix = "geom.out"
  Convergence {
    GradElem = 2E-5
  }
}

Hamiltonian = DFTB {
  Scc = Yes
  ThirdOrderFull = Yes
  MaxSCCIterations = 1000
  HubbardDerivs {
    C = -0.1492
    H = -0.1857
    N = -0.1535
    #O = -0.1575
    S = -0.11
  }
  HCorrection = Damping {
    Exponent = 4.00
  }

  Mixer = Broyden {
    MixingParameter = 0.4
  }
  Dispersion = MBD {
    Beta = 0.83
    KGrid = {1 1 1}
    NOmegaGrid = 25
    ReferenceSet = "TS"
  }
  Filling = Fermi {
    Temperature [Kelvin] = 100
  }
  SlaterKosterFiles = Type2FileNames {
    Prefix = "/data/horse/ws/fera477g-geomOptFCN/slako/3ob/3ob-3-1/"
    Separator = "-"
    Suffix = ".skf"
  }
  MaxAngularMomentum {
    C = "p"
    H = "s"
    N = "p"
    #O = "p"
    S = "d"
  }
}

Options {}

Analysis {
  CalculateForces = Yes
}

ParserOptions {
  ParserVersion = 11
}
EOL

    # Crea la directory per i risultati
    mkdir -p "$output_dir"

    # Esegui la simulazione
   dftb+ dftb_in.hsd | tee output.og

    # Copia il file geom.out.xyz, rinominalo e rimuovi le prime due righe
    cp geom.out.xyz "$output_dir/geom.txt"
    sed -i '1,2d' "$output_dir/geom.txt"
    # Sposta i risultati nella directory creata
    mv band.out "$output_dir/"
    mv charges.bin "$output_dir/"
    mv detailed.out "$output_dir/"
    mv dftb_pin.hsd "$output_dir/"
    mv geom.out.xyz "$output_dir/"
    mv geom.out.gen "$output_dir/"
    mv output.log "$output_dir/"

done

echo "Simulazioni completate."
