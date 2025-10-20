function writeOrcaJob(moleculeName, conformers_number,SP, analysis, opt, ck, ckValue, basePath,VACTanalysisName)
    % open OrcaJob.sh in the right folder
    if opt == 1
        newFolder = fullfile(basePath,moleculeName,sprintf("Cf%d",conformers_number), '01_optimization_folder');
    else
        newFolder = fullfile(basePath,moleculeName,sprintf("Cf%d",conformers_number), VACTanalysisName);
    end
    if ~exist(newFolder, 'dir'); mkdir(newFolder); end
    jobFile = fullfile(newFolder, "OrcaJob.sh");
    fid_orca = fopen(jobFile, 'w');

    % select template depending on SP/analysis/opt
    if SP==0 && analysis==0 && opt==1
        fprintf(fid_orca, '#!/bin/bash\n');
        fprintf(fid_orca, '#SBATCH --time=120:00:00\n');
        fprintf(fid_orca, '#SBATCH --partition=barnard\n');
        fprintf(fid_orca, '#SBATCH -J OxOpt%sCf%d\n', moleculeName, conformers_number);
        fprintf(fid_orca, '#SBATCH --output=sdip1.out\n');
        fprintf(fid_orca, '#SBATCH --error=sdip1.err\n');
        fprintf(fid_orca, '#SBATCH -A p_nanoparticle\n');
        fprintf(fid_orca, '#SBATCH --ntasks=64\n');
        fprintf(fid_orca, '#SBATCH --nodes=1\n');
        fprintf(fid_orca, '#SBATCH --ntasks-per-node=64\n');
        fprintf(fid_orca, '#SBATCH --mail-type=ALL\n');
        fprintf(fid_orca, '#SBATCH --mail-user=federico.ravera@tu-dresden.de\n');
        fprintf(fid_orca, '#SBATCH --mem-per-cpu=3900\n\n');
        fprintf(fid_orca, '# Load modules\n');
        fprintf(fid_orca, 'module load release/23.04\n');
        fprintf(fid_orca, 'module load GCC/11.2.0\n');
        fprintf(fid_orca, 'module load OpenMPI/4.1.1\n');
        fprintf(fid_orca, 'module load ORCA/5.0.3\n\n');
        fprintf(fid_orca, '# Run Orca calculation\n');
        fprintf(fid_orca, 'orca %s_Cf%dOpt.inp > %s_Cf%dOpt.out\n', moleculeName, conformers_number, moleculeName, conformers_number);
    elseif SP==0 && analysis==0 && opt==0
        fprintf(fid_orca, '#!/bin/bash\n');
        fprintf(fid_orca, '#SBATCH --time=120:00:00\n');
        fprintf(fid_orca, '#SBATCH --partition=barnard\n');
        fprintf(fid_orca, '#SBATCH -J OxChar%sCf%d\n', moleculeName, conformers_number);
        fprintf(fid_orca, '#SBATCH --output=sdip1.out\n');
        fprintf(fid_orca, '#SBATCH --error=sdip1.err\n');
        fprintf(fid_orca, '#SBATCH -A p_nanoparticle\n');
        fprintf(fid_orca, '#SBATCH --ntasks=64\n');
        fprintf(fid_orca, '#SBATCH --nodes=2\n');
        fprintf(fid_orca, '#SBATCH --ntasks-per-node=32\n');
        fprintf(fid_orca, '#SBATCH --mail-type=ALL\n');
        fprintf(fid_orca, '#SBATCH --mail-user=federico.ravera@tu-dresden.de\n');
        fprintf(fid_orca, '#SBATCH --mem-per-cpu=3900\n\n');

        % Moduli
        fprintf(fid_orca, '# Load modules\n');
        fprintf(fid_orca, 'module load release/23.04\n');
        fprintf(fid_orca, 'module load GCC/11.2.0\n');
        fprintf(fid_orca, 'module load OpenMPI/4.1.1\n');
        fprintf(fid_orca, 'module load ORCA/5.0.3\n\n');

        % Preprocess input file
        fprintf(fid_orca, '# Preprocess input file (remove carriage return characters)\n');
        fprintf(fid_orca, 'sed -e "s/\r//g" %s_Cf%dTEMPLATE.inp\n\n',moleculeName, conformers_number);

        % Definizione degli array
        % fprintf(fid_orca, 'D1=($(seq -8.6808 0.86808 8.6808))\n');
        % fprintf(fid_orca, 'D2=($(seq 8.6808 -0.86808 -8.6808))\n\n');
        fprintf(fid_orca, 'D1=($(seq -8.6808 0.86808 -1.73616) $(seq -0.86808 0.21702 0.86808) $(seq 1.73616 0.86808 8.6808))\n');
        fprintf(fid_orca, 'D2=($(seq 8.6808 -0.86808 1.73616) $(seq 0.86808 -0.21702 -0.86808) $(seq -1.73616 -0.86808 -8.6808))\n\n');

        if ck == 0
            fprintf(fid_orca, 'CLK1=(0)\n');
            fprintf(fid_orca, 'CLK2=(0)\n');
            fprintf(fid_orca, 'CKVOLTAGE=(0)\n\n');
        else
            scale = 22.2222 * abs(ckValue);
            if ck > 0
                CLK1 = -scale;
                CLK2 = +scale;
            else
                CLK1 = +scale;
                CLK2 = -scale;
            end

            fprintf(fid_orca, 'CLK1=(%.4f)\n', CLK1);
            fprintf(fid_orca, 'CLK2=(%.4f)\n', CLK2);
            fprintf(fid_orca, 'CKVOLTAGE=(%+d)\n\n', ckValue);
        end

        fprintf(fid_orca, 'total_drivers=${#D1[*]}\n');
        fprintf(fid_orca, 'total_clocks=${#CKVOLTAGE[*]}\n\n');

        fprintf(fid_orca, 'echo "Number of drivers: $total_drivers"\n');
        fprintf(fid_orca, 'echo "Number of clocks: $total_clocks"\n\n');

        % Loop principale
        fprintf(fid_orca, 'for i in `seq 0 $(( $total_clocks - 1 ))`;\n');
        fprintf(fid_orca, 'do\n');
        fprintf(fid_orca, '    for j in `seq 0 $(( $total_drivers - 1 ))`;\n');
        fprintf(fid_orca, '    do\n');
        fprintf(fid_orca, '        echo "Launching simulation charges: ${D1[j]} ${D2[j]} Clock: ${CLK1[i]} ${CLK2[i]} (${CKVOLTAGE[i]})"\n\n');

        fprintf(fid_orca, '        # Pointcharge file\n');
        fprintf(fid_orca, '        cp pointchargesTEMPLATE.pc pointcharges.pc\n');
        fprintf(fid_orca, '        sed -i "s/PCD1/${D1[j]}/g" pointcharges.pc\n');
        fprintf(fid_orca, '        sed -i "s/PCD2/${D2[j]}/g" pointcharges.pc\n');
        fprintf(fid_orca, '        sed -i "s/PCLK1/${CLK1[i]}/g" pointcharges.pc\n');
        fprintf(fid_orca, '        sed -i "s/PCLK2/${CLK2[i]}/g" pointcharges.pc\n\n');

        fprintf(fid_orca, '        # Name of files\n');
        fprintf(fid_orca, '        infile="%s_Cf%dtc_${D1[j]}_${D2[j]}_ck${CKVOLTAGE[i]}.inp"\n',moleculeName, conformers_number);
        fprintf(fid_orca, '        outfile="%s_Cf%dtc_${D1[j]}_${D2[j]}_ck${CKVOLTAGE[i]}.out"\n\n', moleculeName, conformers_number);

        fprintf(fid_orca, '        # Copy pointcharge file for debug purpose\n');
        fprintf(fid_orca, '        pcfile="%s_Cf%dtc_${D1[j]}_${D2[j]}_ck${CKVOLTAGE[i]}.pc"\n', moleculeName, conformers_number);
        fprintf(fid_orca, '        cp pointcharges.pc $pcfile\n\n');

        fprintf(fid_orca, '        # Check if simulation was already done in a previous launch\n');
        fprintf(fid_orca, '        if [[ -f "$outfile" ]]; then\n');
        fprintf(fid_orca, '            echo "$outfile already exists, skipping simulation."\n');
        fprintf(fid_orca, '        else\n');
        fprintf(fid_orca, '            # Create input file\n');
        fprintf(fid_orca, '            cp %s_Cf%dTEMPLATE.inp $infile\n\n', moleculeName, conformers_number);
        fprintf(fid_orca, '            # Run simulation\n');
        fprintf(fid_orca, '            /software/rapids/r23.04/ORCA/5.0.3-gompi-2021b/bin/orca $infile > $outfile\n');
        fprintf(fid_orca, '        fi\n');
        fprintf(fid_orca, '    done  \n');
        fprintf(fid_orca, 'done\n');
    else
        % write SP job
    end

    fclose(fid_orca);
end