# LUFFY

<p align="center">

**L**ayered **U**nified **F**ramework for mol**F**CN s**Y**stematic analysis

</p>

---

## Overview

**LUFFY** is an open-source MATLAB framework for the systematic characterization of molecular candidates for **Molecular Field-Coupled Nanocomputing (MolFCN)**.

Starting from molecular geometries, LUFFY automates the preparation, organization and post-processing of quantum-chemical calculations required to construct **Voltage-to-Aggregated-Charge Transcharacteristics (VACTs)**.

The generated VACTs represent reduced-order electrostatic models directly compatible with the **SCERPA** simulation engine within the **MoSQuiTo** framework, enabling circuit-level simulations of molecular logic devices.

LUFFY does **not** perform quantum-chemical calculations nor circuit simulations.

Instead, it acts as the glue between:

```
Molecular structure
        │
        ▼
CREST conformational sampling
        │
        ▼
DFT calculations (ORCA)
        │
        ▼
Electrostatic post-processing
        │
        ▼
Voltage-to-Aggregated-Charge Transcharacteristics (VACTs)
        │
        ▼
SCERPA / MoSQuiTo
        │
        ▼
MolFCN circuit simulations
```

The main objective of LUFFY is to guarantee that every molecular candidate is characterized using exactly the same workflow, ensuring reproducibility, scalability and consistency throughout the entire MolFCN design pipeline.

---

# Main features

LUFFY automates:

- generation of ORCA input files;
- management of multiple molecular conformers;
- geometry optimization workflow;
- single-point electrostatic characterization;
- perturbation-based aggregated-charge optimization;
- Voltage-to-Aggregated-Charge Transcharacteristic (VACT) extraction;
- Boltzmann averaging of conformational properties;
- AIMD validation of VACTs;
- generation of SCERPA-compatible molecular models.

The framework has been specifically developed for MolFCN research but can be extended to other electrostatic molecular computing paradigms.

---

# Software architecture

LUFFY acts as an orchestration layer.

It **does not replace** CREST, xTB or ORCA.

Instead, it automatically prepares all required calculations, parses the resulting output files and generates reduced-order molecular models.

The complete software stack is therefore

```
                 USER
                   │
                   ▼
              Molecular geometry
                   │
                   ▼
                CREST/xTB
        (external conformer search)
                   │
                   ▼
                LUFFY
        (workflow automation)
                   │
                   ▼
                 ORCA
      (DFT calculations - external)
                   │
                   ▼
                LUFFY
      (post-processing & VACTs)
                   │
                   ▼
          SCERPA / MoSQuiTo
        (circuit simulations)
```

---

# External dependencies

LUFFY requires the following external software.

| Software | Required | Purpose |
|-----------|----------|---------|
| MATLAB | ✔ | Main workflow |
| CREST | ✔ | Conformational search |
| xTB | ✔ | Backend used by CREST |
| ORCA 5.0+ | ✔ | DFT calculations |
| SCERPA | Optional | Circuit-level MolFCN simulations |

**Important**

LUFFY never launches CREST nor ORCA automatically.

The user is responsible for executing all generated calculations locally or on an HPC cluster.

---

# Repository organization

The repository is organized as

```
LUFFY/

│
├── main.m
├── LUFFY_GUI.m
├── DatabaseMol/
├── Functions/
├── README.md
│
├── S1_GenerateOptimization.m
├── S2_GenerateCharacteristics.m
├── S3_AnalyseCharacteristicsPerturbative.m
│
└── ...
```

The most important folders are

| Folder | Description |
|---------|-------------|
| DatabaseMol | Molecular database |
| Functions | Utility functions |
| Cf1, Cf2, ... | Conformer-specific working directories |
| DB | Internal LUFFY database automatically generated |

Users normally interact only with

```
DatabaseMol
```

Everything else is automatically handled by LUFFY.

---

# Before starting

Suppose we want to characterize a completely new molecular candidate called

```
ExampleMol
```

starting from a CREST conformational search.

The workflow presented below follows exactly the same sequence used throughout the LUFFY framework.

```
ExampleMol

↓

CREST

↓

ORCA

↓

LUFFY

↓

SCERPA
```

The following sections describe every step in detail.

---

# STEP 1 — Perform conformational sampling

Conformational sampling is **not performed by LUFFY**.

Instead, the user first performs a conventional CREST conformational search.

For example

```
ExampleMol.xyz

↓

CREST

↓

crest_conformers.xyz
```

At the end of this step the only file required by LUFFY is

```
crest_conformers.xyz
```

containing all thermally accessible conformers.

No additional files are necessary.

---

# STEP 2 — Prepare the molecular database

Create the following directory

```
DatabaseMol/

└── ExampleMol/

    └── conformers/

        └── crest_conformers.xyz
```

where

- **ExampleMol** is the molecule name chosen by the user;
- **crest_conformers.xyz** is the output produced by CREST.

**IMPORTANT**

The folder name

```
ExampleMol
```

**must exactly match** the value entered later inside the LUFFY GUI as

```
Molecule short name
```

LUFFY automatically builds all directory paths starting from this name.

Changing either the folder name or the GUI name independently will cause the workflow to fail because files will no longer be found.

At this stage the directory tree should contain only

```
DatabaseMol/

└── ExampleMol/

    └── conformers/

        └── crest_conformers.xyz
```

No `Cf` folders should exist yet.

These folders are created automatically by LUFFY during the workflow.

---
