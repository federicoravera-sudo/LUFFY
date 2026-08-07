# LUFFY

**LUFFY** (**L**ayered **U**nified **F**ramework for molFCN systematic anal**Y**sis) is a unified workflow for the rational design, screening, and validation of molecular candidates for **Molecular Field-Coupled Nanocomputing (MolFCN)**.

LUFFY bridges **molecular-scale chemistry** and **device-level functionality** by combining conformational sampling, first-principles electrostatic analysis, reduced-order modeling through **VACTs**, dynamical validation, and circuit-level propagation analysis.

The framework is designed to support the identification of molecular species able to operate in MolFCN architectures, where binary information is encoded and propagated **electrostatically**, without charge transport, enabling a possible route toward **ultra-low-power computation beyond CMOS**.

---

## Why LUFFY?

As CMOS technology approaches its fundamental limits in switching speed and power density, alternative paradigms that avoid current-based logic are being actively explored. Among them, **Molecular Field-Coupled Nanocomputing (MolFCN)** aims to encode and propagate information through **field-induced charge redistribution** inside molecules rather than through electron flow.

A major challenge in this field is the lack of a **realistic and scalable methodology** for identifying molecules that are actually suitable for device operation.

Previous analyses often relied on:
- single optimized geometries,
- static electrostatic assumptions,
- simplified bistable models,
- or circuit-level simulations that neglect detailed molecular electrostatics.

LUFFY was developed to overcome these limitations by introducing a **physically grounded, modular, and transferable workflow** that explicitly accounts for:
- conformational diversity,
- field-induced molecular response,
- reduced electrostatic models compatible with circuit simulation,
- and dynamical validation under time-dependent fields.

---

## What LUFFY does

LUFFY provides a complete workflow to evaluate whether a molecule is a viable MolFCN candidate.

Starting from a molecular structure, the framework:

1. **samples the conformational landscape**, identifying low-energy geometries;
2. **optimizes the relevant conformers** at the DFT level;
3. **evaluates their electrostatic response** under external clock and input fields;
4. **extracts reduced transcharacteristics** compatible with MolFCN circuit simulation;
5. **validates the static/semi-static response dynamically** via AIMD;
6. **tests information propagation at circuit level** through SCERPA.

This makes LUFFY a bridge between:
- **molecular design**
- **electrostatic modeling**
- **functional information propagation**

---

## Conceptual background

In MolFCN, binary information is encoded through **charge localization** over molecular subunits (“dots”). External vertical electric fields, usually referred to as **clock fields** (`E_ck`), are used to stabilize either:
- a **Hold** configuration, where logic is preserved,
- or a **Null** configuration, where the molecule is reset.

To operate properly in a realistic device platform, candidate molecules should combine:
- robust anchoring to the substrate/electrode environment,
- controlled orientation,
- suitable separation between charge-localization sites,
- low unwanted intrinsic logical bias,
- strong polarizability,
- chemical and structural stability.

LUFFY was built to evaluate these requirements systematically.

---

## Workflow

### 1. Molecular design and dataset definition
Candidate molecules are defined according to a modular architecture tailored for MolFCN. In our reference implementation, the molecules are built from three functional blocks:

- **AG**: anchoring group  
- **SP**: spacer  
- **PG**: polarizable or redox-active group  

This enables systematic exploration of structure–property trends across chemically accessible families.

---

### 2. Conformational sampling
Low-energy conformers are explored using **CREST** with **GFN2-xTB**, including solvent effects when appropriate.

This step is essential because molecular electrostatics in MolFCN are strongly influenced by:
- conformational variability,
- relative branch orientation,
- intramolecular symmetry,
- and field-sensitive geometrical rearrangements.

Rather than relying on a single minimum-energy geometry, LUFFY retains an ensemble of relevant conformers within a chosen energy window.

---

### 3. DFT optimization and electrostatic characterization
Selected conformers are refined using **DFT** and analyzed in different charge states, typically including:
- **neutral**
- **oxidized**

For each conformer, LUFFY evaluates:
- total dipole moment,
- dipole components,
- isotropic polarizability,
- geometry/symmetry descriptors,
- field-induced electrostatic response.

This step allows the identification of trends linking molecular structure to MolFCN-relevant functionality.

---

### 4. VACT extraction
A key output of LUFFY is the extraction of **Voltage-to-Aggregated-Charge Transcharacteristics (VACTs)**.

VACTs are reduced electrostatic descriptors that map the molecular response under:
- input bias `V_in`
- clock field `E_ck`

into an equivalent representation based on **three aggregated charges (ACs)**.

These AC models are used because they preserve the essential electrostatic behavior of the molecule while remaining computationally compatible with circuit-level simulation.

LUFFY supports:
- conventional spatial grouping,
- and a more accurate **perturbation-based grouping** that automatically refines the charge partitioning and reduces the error with respect to the underlying DFT response.

---

### 5. Semi-static and conformer-aware modeling
A central feature of LUFFY is that it does not assume molecular geometry to remain frozen under external fields.

Instead, it can incorporate:
- **static response**: fixed geometry under applied fields,
- **semi-static response**: geometry re-optimized under the applied electrostatic environment,
- **conformer-aware averaging**: energy-weighted averaging of transcharacteristics over multiple conformers.

This enables a much more realistic description of molecular behavior in device-like conditions.

---

### 6. Dynamical validation
The extracted static or semi-static descriptors are validated through **ab initio molecular dynamics (AIMD)** under time-dependent fields.

This step is used to determine whether:
- a **single conformer** is sufficient to describe the response,
- or an **ensemble-averaged VACT** is more physically appropriate.

The comparison between AIMD time-averaged dipoles and reduced-model predictions provides a practical criterion for selecting the correct representation.

---

### 7. Circuit-level propagation with SCERPA
Validated VACTs are then used as inputs to **SCERPA** (**S**elf-**C**onsistent **E**lect**R**ostatic **P**otential **A**lgorithm), integrated within the **MoSQuiTo** simulation framework.

SCERPA evaluates information propagation in MolFCN circuits by self-consistently solving intermolecular electrostatic interactions.

This final stage answers the key question:
> does the molecule only look promising at molecular level, or can it actually support logic propagation in a circuit?

---

## Main features

- Unified workflow from molecule to circuit
- Explicit treatment of conformational diversity
- DFT-based electrostatic characterization
- Reduced-order modeling through VACTs
- Automatic perturbation-based charge grouping
- Semi-static field-aware response modeling
- AIMD-based validation of molecular switching behavior
- Circuit-level information propagation analysis with SCERPA
- Framework compatible with future high-throughput and AI-assisted screening

---

## Typical outputs

Depending on the workflow stage, LUFFY can provide:

- low-energy conformer ensembles
- optimized molecular geometries
- dipole and polarizability descriptors
- geometry/symmetry metrics
- static and semi-static `V_in`–`μ` characteristics
- reduced aggregated-charge models
- conformer-averaged VACTs
- AIMD validation metrics
- SCERPA-ready molecular descriptors
- device-level propagation results

---

## Methodological philosophy

LUFFY is based on a simple principle:

> **A viable MolFCN molecule cannot be identified from molecular structure alone, nor from a single electrostatic snapshot.**

Instead, realistic candidate identification requires combining:
- chemistry,
- conformational physics,
- field-induced response,
- reduced electrostatic abstraction,
- and circuit-level validation.

This is the key motivation behind LUFFY.

---

## Current scope

LUFFY is currently designed for the analysis of candidate molecules for **clocked molecular field-coupled nanocomputing**, with particular emphasis on:
- Y-shaped molecules,
- oxidizable/redox-active systems,
- surface-compatible architectures,
- and molecules that can be represented through three-dot electrostatic models.

---

## Future directions

LUFFY is intended as a scalable framework and can be naturally extended toward:

- **substrate-aware modeling**, including molecule–surface interactions and anchored geometries;
- **substrate-aware VACTs**, for more realistic device conditions;
- **high-throughput screening** of larger molecular libraries;
- **machine-learning-assisted prediction** of electrostatic response and candidate ranking;
- **AI-guided inverse design** of MolFCN molecular building blocks;
- integration with automated chemical space exploration pipelines.

---

## Software and methods used in the reference workflow

LUFFY can include, depending on the implementation:

- **CREST**
- **GFN2-xTB**
- **ORCA**
- **CAM-B3LYP-D4 / def2-TZVP**
- **AIMD**
- **MoSQuiTo**
- **SCERPA**

---
