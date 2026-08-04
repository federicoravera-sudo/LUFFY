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

---

---

# STEP 10 — Single-point molecular analysis

Besides VACT extraction, LUFFY can also perform a detailed analysis of the optimized equilibrium geometry.

Enable

```
Run single SP analysis
```

LUFFY automatically imports the optimized molecular structure and extracts several molecular descriptors, including

- molecular dipole moment;
- dipole components;
- molecular polarizability;
- electrostatic potential;
- atomic charges;
- aggregated-charge representation.

These quantities are primarily intended for molecular screening, database construction and comparison between different molecular candidates.

Unlike the VACT workflow, this analysis only requires the optimized equilibrium geometry and does not require a complete Vin–Eck characterization.

---

# STEP 11 — Boltzmann averaging

Many molecular candidates exhibit multiple thermally accessible conformations.

LUFFY therefore provides an automatic Boltzmann-averaging procedure to construct ensemble-averaged molecular properties.

Enable

```
Generate Boltzmann
```

For every conformer, LUFFY automatically

- imports the optimized energies;
- computes the relative conformational energies;
- evaluates the Boltzmann populations;
- constructs ensemble-averaged molecular descriptors.

The Boltzmann population of conformer \(i\) is computed as

$$
w_i=
\frac{
\exp\left(-\frac{\Delta E_i}{k_{\mathrm B}T}\right)
}{
\sum_{j=1}^{N_{\mathrm{conf}}}
\exp\left(-\frac{\Delta E_j}{k_{\mathrm B}T}\right)
}
$$

where

- \(w_i\) is the Boltzmann population of conformer \(i\);
- \(\Delta E_i = E_i-E_{\min}\) is the energy difference between conformer \(i\) and the lowest-energy conformer;
- \(k_{\mathrm B}\) is the Boltzmann constant;
- \(T\) is the temperature;
- \(N_{\mathrm{conf}}\) is the total number of conformers.

The ensemble average of a generic conformer-dependent property \(A\) is then computed as

$$
\langle A\rangle=
\sum_{i=1}^{N_{\mathrm{conf}}}
w_iA_i.
$$

For example, LUFFY computes Boltzmann-averaged

- molecular dipole moments;
- polarizabilities;
- aggregated charges;
- Voltage-to-Aggregated-Charge Transcharacteristics (VACTs);
- other conformer-dependent molecular descriptors.

For conformationally flexible molecular systems, these ensemble averages generally provide a more representative description than the lowest-energy conformer alone.

---

# STEP 12 — AIMD validation (optional)

LUFFY also provides an optional validation workflow based on **Ab Initio Molecular Dynamics (AIMD)** simulations.

Enable

```
Check MD analysis
```

The module requires

- an AIMD trajectory (`.xyz`);
- the corresponding ORCA output containing CHELPG atomic charges.

LUFFY automatically

- reconstructs the molecular dipole at every AIMD frame;
- computes the complete dipole evolution as a function of time;
- evaluates the corresponding time-averaged dipole components;
- compares the AIMD averages with both the lowest-energy-conformer and ensemble-averaged VACT predictions.

This comparison provides a practical criterion for assessing whether the molecular dynamics remain localized around the equilibrium geometry or whether multiple conformers significantly contribute to the electrostatic response.

The extracted quantities can therefore be used to determine the most physically representative molecular model for subsequent MolFCN simulations.

---

# Generated files

The following table summarizes the main outputs generated during the LUFFY workflow.

| Stage | Main outputs |
|--------|--------------|
| Extract conformers | `Conformer1.txt ... ConformerN.txt` |
| Geometry optimization | `Opt.inp`, `OrcaJob.sh` |
| ORCA optimization | `Opt.xyz`, `Opt.out` |
| Electrostatic characterization | `TEMPLATE.inp`, `pointcharges.pc`, `OrcaJob.sh` |
| ORCA characterization | Complete Vin–Eck ORCA outputs |
| LUFFY Analysis | Perturbation-based VACTs |
| Single SP analysis | Molecular descriptors |
| Boltzmann averaging | Ensemble-averaged descriptors |
| AIMD validation | Dipole evolution and validation plots |

---

# Input → Output workflow

| Input | LUFFY operation | Output |
|--------|-----------------|--------|
| `crest_conformers.xyz` | Extract conformers | Individual conformers |
| Individual conformers | Generate optimization inputs | ORCA optimization inputs |
| Optimized geometries | Generate characterization inputs | ORCA characterization inputs |
| Characterization outputs | LUFFY Analysis | VACTs |
| Optimized geometries | Single SP analysis | Molecular descriptors |
| Multiple conformers | Generate Boltzmann | Ensemble-averaged descriptors |
| AIMD trajectory + ORCA output | AIMD validation | Time-dependent and time-averaged dipoles |

---

# GUI reference

The following table summarizes the available options in the LUFFY graphical interface.

| GUI option | Description |
|------------|-------------|
| **Extract conformers** | Splits the CREST trajectory into individual conformers. This operation is only required after a new conformational search. |
| **LUFFY Simulation** | Generates ORCA calculations. |
| **Optimization** | Generates geometry optimization calculations. |
| **Single Point** | Generates equilibrium single-point calculations. |
| **VACT Analysis** | Generates the Vin–Eck electrostatic characterization. |
| **LUFFY Load** | Imports completed calculations into the LUFFY database (primarily intended for external/HPC calculations). |
| **LUFFY Analysis** | Executes the LUFFY post-processing workflow. |
| **Run VACT extraction** | Performs perturbation-based grouped-charge optimization and constructs the final VACTs. |
| **Run single SP analysis** | Extracts equilibrium molecular descriptors. |
| **Generate Boltzmann** | Computes Boltzmann populations and ensemble-averaged descriptors. |
| **Check MD analysis** | Performs AIMD-based validation of the extracted molecular response. |

---

# Complete workflow

```
Molecular geometry
        │
        ▼
CREST conformational search
        │
        ▼
crest_conformers.xyz
        │
        ▼
Extract conformers
        │
        ▼
Generate ORCA optimization inputs
        │
        ▼
Run ORCA optimization
        │
        ▼
Generate ORCA characterization inputs
        │
        ▼
Run ORCA characterization
        │
        ▼
LUFFY Analysis
        │
        ├── Perturbation grouping
        ├── VACT extraction
        ├── Single-point analysis
        ├── Boltzmann averaging
        └── AIMD validation (optional)
        │
        ▼
SCERPA-ready VACTs
        │
        ▼
SCERPA / MoSQuiTo
        │
        ▼
Circuit-level MolFCN simulations
```

---

# Troubleshooting

| Problem | Possible cause |
|----------|----------------|
| LUFFY cannot locate the molecule | The folder name does not match the **Molecule short name** specified in the GUI. |
| No conformers are extracted | `crest_conformers.xyz` is missing or the number of atoms is incorrect. |
| Geometry optimization cannot start | ORCA input files have not been generated or ORCA is unavailable. |
| LUFFY Analysis fails | Geometry optimization or electrostatic characterization calculations are incomplete. |
| VACT extraction fails | ORCA characterization outputs are missing or incomplete. |
| Boltzmann averaging cannot be performed | At least one conformer is missing the optimized energy. |
| AIMD validation fails | The AIMD trajectory or the corresponding ORCA output containing CHELPG charges is unavailable. |

---

# Please note

- LUFFY **does not execute** CREST, xTB or ORCA. It generates the required input files, organizes the workflow and post-processes completed calculations.
- All quantum-chemical calculations must therefore be executed externally by the user (locally or on an HPC cluster).
- The folder name inside `DatabaseMol` **must exactly match** the **Molecule short name** entered in the GUI.
- Automatically generated folders (e.g. `Cf*`, `DB`, `isolated_characterization`, `Geom*`, `geometry.txt`) should **never** be manually modified.
- Each workflow stage depends on the successful completion of the previous one. In particular, LUFFY Analysis requires completed optimization and characterization calculations.
- The electrostatic response depends on the molecular reference frame. The optimized geometry should therefore always be inspected before generating characterization calculations.
- Perturbation-based grouped-charge optimization is performed automatically during VACT extraction.
- The recommended workflow for a new molecular candidate is

```
CREST
   ↓
Extract conformers
   ↓
Generate optimization inputs
   ↓
Run ORCA optimization
   ↓
Generate characterization inputs
   ↓
Run ORCA characterization
   ↓
LUFFY Analysis
   ↓
Single SP analysis
   ↓
Boltzmann averaging
   ↓
(Optional) AIMD validation
   ↓
SCERPA
```

Following this sequence guarantees that all intermediate files required by LUFFY are available before each subsequent stage.

---

# Citation

If you use LUFFY in your research, please cite

(The complete citation will be added after publication.)



