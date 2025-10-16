function writeOrcaJob(moleculeName, conformers_number,SP, analysis, opt, ck, basePath)
    % open OrcaJob.sh in the right folder
    if opt == 1
        newFolder = fullfile(basePath,moleculeName,sprintf("Cf%d",conformers_number), '01_optimization_folder');
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
        fprintf(fid_orca, 'orca %s_Cf%d_Opt.inp > %s_Cf%d_Opt.out\n', moleculeName, conformers_number, moleculeName, conformers_number);
    elseif SP==0 && analysis==0 && opt==0
        % write characteristics job
    else
        % write SP job
    end

    fclose(fid_orca);
end