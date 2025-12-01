#!/bin/bash
#SBATCH --time=120:00:00
#SBATCH --partition=barnard
#SBATCH -J OxCharCombo10Cf1
#SBATCH --output=sdip1.out
#SBATCH --error=sdip1.err
#SBATCH -A p_nanoparticle
#SBATCH --ntasks=64
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=32
#SBATCH --mail-type=ALL
#SBATCH --mail-user=federico.ravera@tu-dresden.de
#SBATCH --mem-per-cpu=3900

# Load modules
module load release/23.04
module load GCC/11.2.0
module load OpenMPI/4.1.1
module load ORCA/5.0.3

# Preprocess input file (remove carriage return characters)
sed -e "s///g" Combo10_Cf1TEMPLATE.inp

D1=($(seq -8.6808 0.86808 -1.73616) $(seq -0.86808 0.21702 0.86808) $(seq 1.73616 0.86808 8.6808))
D2=($(seq 8.6808 -0.86808 1.73616) $(seq 0.86808 -0.21702 -0.86808) $(seq -1.73616 -0.86808 -8.6808))

CLK1=(0)
CLK2=(0)
CKVOLTAGE=(0)

total_drivers=${#D1[*]}
total_clocks=${#CKVOLTAGE[*]}

echo "Number of drivers: $total_drivers"
echo "Number of clocks: $total_clocks"

for i in `seq 0 $(( $total_clocks - 1 ))`;
do
    for j in `seq 0 $(( $total_drivers - 1 ))`;
    do
        echo "Launching simulation charges: ${D1[j]} ${D2[j]} Clock: ${CLK1[i]} ${CLK2[i]} (${CKVOLTAGE[i]})"

        # Pointcharge file
        cp pointchargesTEMPLATE.pc pointcharges.pc
        sed -i "s/PCD1/${D1[j]}/g" pointcharges.pc
        sed -i "s/PCD2/${D2[j]}/g" pointcharges.pc
        sed -i "s/PCLK1/${CLK1[i]}/g" pointcharges.pc
        sed -i "s/PCLK2/${CLK2[i]}/g" pointcharges.pc

        # Name of files
        infile="Combo10_Cf1tc_${D1[j]}_${D2[j]}_ck${CKVOLTAGE[i]}.inp"
        outfile="Combo10_Cf1tc_${D1[j]}_${D2[j]}_ck${CKVOLTAGE[i]}.out"

        # Copy pointcharge file for debug purpose
        pcfile="Combo10_Cf1tc_${D1[j]}_${D2[j]}_ck${CKVOLTAGE[i]}.pc"
        cp pointcharges.pc $pcfile

        # Check if simulation was already done in a previous launch
        if [[ -f "$outfile" ]]; then
            echo "$outfile already exists, skipping simulation."
        else
            # Create input file
            cp Combo10_Cf1TEMPLATE.inp $infile

            # Run simulation
            /software/rapids/r23.04/ORCA/5.0.3-gompi-2021b/bin/orca $infile > $outfile
        fi
    done  
done
