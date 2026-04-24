# LUFFY

**LUFFY** (*Layered Unified Framework for molFCN systematic analysis*) is a computational workflow designed to extract **Voltage-to-Aggregated-Charge Transcharacteristics (VACTs)** from molecular structures for **Molecular Field-Coupled Nanocomputing (MolFCN)**.

LUFFY bridges:
- molecular structure,
- ab initio electrostatic response,
- reduced-order models compatible with circuit simulation.

The framework **does not perform circuit-level simulations**. Instead, it generates **VACTs to be used as input for SCERPA** within the **MoSQuiTo** environment.

LUFFY **automates and orchestrates the full workflow for MolFCN molecule research** based on open-source tools.

The repository provides:

- ⚙️ automated generation of input files for **CREST** and **ORCA**  
- 📊 structured parsing and post-processing of simulation outputs  
- ⚡ construction of **VACTs (core output)** through energy-averaged perturbation-based grouping mechanisms  
- 📦 generation of **aggregated-charge model files** compatible with SCERPA  

All quantum chemical calculations are performed using external open-source or academic software, while LUFFY ensures **consistency, reproducibility, and scalability** of the analysis pipeline.

---

## Workflow 🔬

LUFFY follows a sequential pipeline:

### 1. Conformational sampling
- Tool: **CREST**
- Level of theory: **GFN2-xTB**

Explores the conformational landscape and identifies low-energy structures.

---

### 2. DFT geometry optimization
- Method: **DFT**
- Tool: **ORCA 5.0**
- Functional: **CAM-B3LYP-D4**
- Basis set: **def2-TZVP**

Refines selected conformers at ab initio level (neutral and, when relevant, oxidized states).

---

### 3. Single-point electrostatic calculations
- Method: **DFT (same level: CAM-B3LYP-D4 / def2-TZVP)**
- Tool: **ORCA 5.0**

Extracted quantities:
- dipole moment components
- polarizability
- field-dependent electrostatic response (charge distribution)

---

### 4. VACT extraction ⚡
- Tool: **ORCA 5.0**
- Method: **DFT (same level: CAM-B3LYP-D4 / def2-TZVP)**

Reduces the molecular response into a compact electrostatic model:

Evaluates molecular response under external fields:
- input bias (**Vin**)
- clock field (**Eck**)
- mapping charge distribution onto **three aggregated charges (ACs)**
- construction of **VACTs**

Supported methods:
- spatial grouping
- perturbation-based grouping (higher accuracy)

---

## Role in the MolFCN pipeline 🧩

LUFFY acts as the molecular front-end:
- 🧠 LUFFY: extracts reduced electrostatic descriptors (VACT)
- 🔁 SCERPA: performs circuit-level propagation  
