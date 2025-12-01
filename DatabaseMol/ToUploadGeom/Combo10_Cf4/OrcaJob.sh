#!/bin/bash
#SBATCH --time=120:00:00
#SBATCH --partition=barnard
#SBATCH -J OxOptCombo10Cf4
#SBATCH --output=sdip1.out
#SBATCH --error=sdip1.err
#SBATCH -A p_nanoparticle
#SBATCH --ntasks=64
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=64
#SBATCH --mail-type=ALL
#SBATCH --mail-user=federico.ravera@tu-dresden.de
#SBATCH --mem-per-cpu=3900

# Load modules
module load release/23.04
module load GCC/11.2.0
module load OpenMPI/4.1.1
module load ORCA/5.0.3

# Run Orca calculation
orca Combo10_Cf4Opt.inp > Combo10_Cf4Opt.out
