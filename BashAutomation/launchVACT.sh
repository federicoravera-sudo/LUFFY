#!/bin/bash

# Molecule name
moleculeName="Combo10_betterFunctional"

# Maximum number of conformers
max_conformers=4

# Base directory
base_src_dir="$(pwd)"
# Loop over all conformers
for ((B=1; B<=max_conformers; B++)); do
  # Define the source directory for each conformer
  src_dir="$base_src_dir/${moleculeName}_Cf${B}/02_characterisation_folder_ck0/" 

  if [ -d "$src_dir" ]; then
    cd "$src_dir" || { echo "Error: could not enter $src_dir"; continue; }

    # Convert the OrcaJob.sh script to Unix format (remove Windows carriage returns)
    if [ -f "OrcaJob.sh" ]; then
      dos2unix OrcaJob.sh
      echo "[$moleculeName] Converted OrcaJob.sh to Unix format in Cf${B}"

      # Submit the job using sbatch
      sbatch OrcaJob.sh
      echo "[$moleculeName] Job submitted for Cf${B}"
    else
      echo "[$moleculeName] OrcaJob.sh not found in Cf${B}!"
    fi
  else
    echo "[$moleculeName] Directory not found for Cf${B}!"
  fi
done