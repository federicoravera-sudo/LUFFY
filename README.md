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

# STEP 3 — Extract individual conformers

Launch

```
main.m
```

The LUFFY graphical user interface (GUI) will appear.

Fill in the following information:

| GUI field | Description |
|------------|-------------|
| Molecule short name | Name of the molecular database folder (e.g. ExampleMol) |
| Number of atoms | Total number of atoms in the molecule |
| Minimum conformer | First conformer to process |
| Maximum conformer | Last conformer to process |

For the first execution only, enable

```
Extract conformers
```

LUFFY reads

```
crest_conformers.xyz
```

and automatically separates every conformer into an individual geometry.

For example,

```
crest_conformers.xyz
```

becomes

```
Conformer1.txt

Conformer2.txt

Conformer3.txt

...

ConformerN.txt
```

Each conformer is then treated as an independent molecular candidate throughout the rest of the workflow.

Once the conformers have been extracted, this option no longer needs to be executed unless a new CREST calculation is performed.

---

# STEP 4 — Generate geometry optimization calculations

Disable

```
Extract conformers
```

Enable

```
LUFFY Simulation
```

and

```
Optimization
```

At this stage LUFFY **does not execute any quantum-chemical calculation**.

Instead, it automatically prepares all files required to perform geometry optimizations using ORCA.

For every conformer, LUFFY

- imports the corresponding geometry;
- generates the ORCA optimization input file;
- creates the execution script (`OrcaJob.sh`);
- builds the complete working directory.

For conformer 1, for example, LUFFY creates

```
DatabaseMol/

└── ExampleMol/

    └── Cf1/

        └── 01_optimization_folder/

            ├── Opt.inp
            ├── OrcaJob.sh
            └── ...
```

The same structure is automatically generated for every conformer between the selected minimum and maximum indices.

**Developer note**

This stage is handled internally by

```
runLUFFYsimulation()

↓

S1_GenerateOptimization()
```

which automatically constructs all ORCA input files using the parameters selected in the GUI.

---

# STEP 5 — Execute geometry optimizations

LUFFY stops here.

No calculations are performed automatically.

The generated ORCA jobs must now be executed externally.

Depending on the user's infrastructure, this can be done

- locally;
- on a workstation;
- on an HPC cluster.

Once every optimization has completed successfully, each conformer folder should contain the optimized geometry, for example

```
Opt.xyz

Opt.out
```

These files constitute the starting point for the electrostatic characterization.

**IMPORTANT**

Do not proceed to the next step until **all** optimization calculations have completed successfully.

---

# STEP 6 — Generate electrostatic characterization calculations

Disable

```
Optimization
```

Enable

```
VACT Analysis
```

while keeping

```
LUFFY Simulation
```

enabled.

LUFFY now imports every optimized molecular geometry and prepares the calculations required to construct the Voltage-to-Aggregated-Charge Transcharacteristics (VACTs).

Internally, LUFFY

- reads the optimized geometry;
- aligns the molecular reference frame;
- generates the corresponding aggregated-charge representation;
- constructs the complete Vin–Eck sampling;
- generates every ORCA input file required for electrostatic characterization;
- creates the corresponding execution script.

The resulting folder becomes

```
DatabaseMol/

└── ExampleMol/

    └── Cf1/

        └── 02_characterisation_folder_ck0/

            ├── TEMPLATE.inp
            ├── pointcharges.pc
            ├── OrcaJob.sh
            └── ...
```

where

- `pointcharges.pc` contains the external point-charge configuration used to generate the applied electric field;

- `TEMPLATE.inp` represents the ORCA template from which all Vin–Eck calculations are generated;

- `OrcaJob.sh` executes the complete characterization automatically.

Again,

**LUFFY prepares calculations.**

**ORCA performs calculations.**

---

# STEP 7 — Execute electrostatic characterization

Execute every generated ORCA job.

Each conformer is characterized over the complete set of operating conditions defined by

- input voltage (Vin);

- clock electric field (Eck).

These calculations generate the electrostatic response from which LUFFY will later extract the reduced-order molecular model.

**Developer note**

The characterization stage is generated by

```
runLUFFYsimulation()

↓

S2_GenerateCharacteristics()
```

During this stage LUFFY also prepares the internal molecular database used by the subsequent analysis.

In particular, LUFFY automatically creates

```
DB/

isolated_characterization/

Geom1_FUNCTIONAL_BASISSET/

geometry.txt
```

These folders are automatically managed by LUFFY and should **never be manually modified**.

---

# STEP 8 — Import completed calculations (optional)

LUFFY provides an additional utility called

```
LUFFY Load
```

whose purpose is to collect completed calculations into an internal upload database.

This functionality is particularly useful when calculations have been performed on an external computing cluster.

When enabled, LUFFY copies completed calculations into

```
ToUploadGeom/

ToUploadSP/

ToUploadVACT/
```

preserving the directory organization required by the framework.

For a standard local workflow this step is generally **not required**.

Most users can proceed directly to the analysis stage.

---

# STEP 9 — Run LUFFY analysis

Enable

```
LUFFY Analysis
```

and

```
Run VACT extraction
```

This stage represents the core of LUFFY.

The framework automatically parses every completed ORCA calculation and reconstructs the electrostatic response of the molecule.

For every conformer LUFFY

- imports all ORCA outputs;

- reconstructs molecular electrostatic quantities;

- computes molecular dipole moments;

- evaluates atomic electrostatic potentials;

- generates spatial aggregated-charge models;

- performs perturbation-based grouping optimization;

- minimizes the electrostatic deviation from the DFT reference;

- constructs the Voltage-to-Aggregated-Charge Transcharacteristics;

- exports SCERPA-compatible reduced-order models.

One VACT is generated for every conformer.

No user intervention is required during this stage.

**Developer note**

This analysis corresponds to

```
runAnalysis()

↓

S3_AnalyseCharacteristicsPerturbative()
```

which implements the perturbation-based grouped-charge optimization described in the accompanying publication.

No `Cf` folders should exist yet.

These folders are created automatically by LUFFY during the workflow.

---
