# 🧬 LUFFY: a Layered Unified Framework for molFCN systematic analYsis

This repository provides a **complete framework for the systematic analysis of molecules** used in **Molecular Field-Coupled Nanocomputing (MFCN)**.  
Starting from a simple `.xyz` molecular geometry, it guides you through **conformational exploration**, **geometry optimization**, and **DFT-level characterization**, all in an HPC-ready workflow.

---

## 📚 Table of Contents
- [1. Overview](#1-overview)
- [2. Conformational Analysis](#2-conformational-analysis)
  - [2.1 Running CREST](#21-running-crest)
  - [2.2 Output Integration](#22-output-integration)
- [3. Geometry Optimization Setup](#3-geometry-optimization-setup)
  - [3.1 Automatic Input Generation](#31-automatic-input-generation)
  - [3.2 HPC Job Submission Scripts](#32-hpc-job-submission-scripts)
- [4. Folder Structure](#4-folder-structure)
- [5. Collaboration and Acknowledgments](#5-collaboration-and-acknowledgments)

---

## 1. Overview

This framework automates the workflow for MFCN molecular characterization:
1. **Conformational search** using [CREST](https://crest-lab.github.io/crest-docs/).
2. **Extraction** of all stable conformers.
3. **Generation of ORCA input files** for DFT-level geometry optimizations.
4. **HPC-ready submission scripts** for large-scale computations.

---

## 2. Conformational Analysis

### 2.1 Running CREST

To perform the conformational search, run the [CREST](https://crest-lab.github.io/crest-docs/) program using the following command:

```bash
crest struc.xyz --gfn2 --gbsa h2o -T 4
```

This will generate an ensemble of stable conformations for your molecule in aqueous phase, using the **GFN2-xTB** method with implicit solvation (`GBSA`) and 4 CPU threads.

---

### 2.2 Output Integration

After the conformational search, place the CREST output into the correct project structure:

```bash
mkdir -p LUFFY/MoleculeName/conformers
mv crest_conformers LUFFY/MoleculeName/conformers/
```

Then, in your configuration or main control script, set:

```python
extract_conformers = 1
```

When this flag is active, the code will:

1. Parse the `crest_conformers` file.
2. Automatically extract and save each stable conformer as an individual `.xyz` file inside:
   ```
   LUFFY/MoleculeName/conformers/
   ```

---

## 3. Geometry Optimization Setup

### 3.1 Automatic Input Generation

Once all conformers are available, the framework automatically generates one subfolder per conformer:

```bash
LUFFY/MoleculeName/conformers/Cf1/
LUFFY/MoleculeName/conformers/Cf2/
...
```

Each `CfX` directory contains a subfolder for geometry optimization:

```
CfX/
└── 01_optimization_folder/
    ├── MoleculeName_CfX.inp
    └── OrcaJob.sh
```

The `.inp` file defines the DFT-level optimization using **CAM-B3LYP / UKS / def2-TZVP / D4**, and looks like this (example):

```bash
! UKS CAM-B3LYP D4 def2-TZVP Opt TightSCF
%maxcore 4000
%pal nprocs 4 end
* xyzfile 0 1 MoleculeName_CfX.xyz
```

---

### 3.2 HPC Job Submission Scripts

Each optimization folder also contains a pre-configured **SLURM submission script** for HPC systems:

```bash
#!/bin/bash
#SBATCH --job-name=MoleculeName_CfX
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=3900MB
#SBATCH --time=24:00:00
#SBATCH --output=output.log

module purge
module load GCC/11.3.0 OpenMPI/4.1.4 ORCA/5.0.3

orca MoleculeName_CfX.inp > MoleculeName_CfX.out
```

To submit the job:

```bash
cd LUFFY/MoleculeName/conformers/CfX/01_optimization_folder/
sbatch OrcaJob.sh
```

---

## 4. Folder Structure

Below is the standard project directory layout:

```
LUFFY/
└── MoleculeName/
    └── conformers/
        ├── crest_conformers
        ├── Cf1/
        │   └── 01_optimization_folder/
        │       ├── MoleculeName_Cf1.inp
        │       └── OrcaJob.sh
        ├── Cf2/
        │   └── 01_optimization_folder/
        │       ├── MoleculeName_Cf2.inp
        │       └── OrcaJob.sh
        └── ...
```

---

## 5. Collaboration and Acknowledgments

This work has been carried out in collaboration with the  
**Zentrum für Informationsdienste und Hochleistungsrechnen (ZIH)**,  
**Technische Universität Dresden**, Germany.

The computational framework, automation scripts, and workflow organization were developed as part of the **Molecular Field-Coupled Nanocomputing** research activities.

---
