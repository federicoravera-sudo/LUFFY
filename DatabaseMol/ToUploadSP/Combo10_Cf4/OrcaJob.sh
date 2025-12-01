#!/bin/bash
#SBATCH --time=120:00:00
#SBATCH --partition=barnard
#SBATCH -J OxSPCombo10Cf4
#SBATCH --output=sdip1.out
#SBATCH --error=sdip1.err
#SBATCH -A p_nanoparticle
#SBATCH --ntasks=36
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=18
#SBATCH --mail-type=ALL
#SBATCH --mail-user=federico.ravera@tu-dresden.de
#SBATCH --mem-per-cpu=3900

# Load modules
module load release/23.04
module load GCC/11.2.0
module load OpenMPI/4.1.1
module load ORCA/5.0.3

infile="Combo10_Cf4_EQ.inp"
outfile="Combo10_Cf4_EQ.out"

# Run simulation
/software/rapids/r23.04/ORCA/5.0.3-gompi-2021b/bin/orca $infile > $outfile
