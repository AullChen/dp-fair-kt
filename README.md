# Differential Privacy Fairness in Educational Knowledge Tracing

Code and summarized experimental artifacts for studying metric-dependent fairness effects of DP-SGD in educational knowledge tracing. The experiments use OULAD socioeconomic groups derived from the Index of Multiple Deprivation (IMD), with DKT and SAKT as the main model families.

## Repository Structure

```text
.
|-- notebooks/
|   `-- fairness_dp_knowledge_tracing.ipynb
|-- results/
|   |-- metrics/       # Aggregate experiment metrics
|   `-- tables/        # Paper-ready CSV and LaTeX tables
|-- figures/           # Paper figures generated from the experiments
|-- scripts/
|   `-- validate_repository.ps1
|-- requirements.txt
|-- environment.yml
|-- LICENSE
`-- .gitignore
```

Large caches, per-interaction prediction files, raw OULAD data, checkpoints, and temporary notebook outputs are intentionally excluded.

## Setup

Python 3.10 or 3.11 and a CUDA-capable PyTorch installation are recommended for full training.

```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

For Conda:

```bash
conda env create -f environment.yml
conda activate dp-kt-fairness
```

## Dataset

Download the Open University Learning Analytics Dataset (OULAD) separately. The code expects at least:

- `studentInfo.csv`
- `studentAssessment.csv`
- `assessments.csv`

Point the notebook to the extracted directory with `OULAD_DIR`:

```bash
export OULAD_DIR=/path/to/oulad
```

PowerShell:

```powershell
$env:OULAD_DIR = "C:\path\to\oulad"
```

The raw dataset is not redistributed in this repository. OULAD is described by Kuzilek et al. (2017), *Scientific Data*, 4, 170171.

## Running the Notebook

The notebook supports three execution profiles through the `EXECUTION_PROFILE` environment variable:

- `tables_only`: default; reconstructs paper-ready tables and figures from embedded aggregate results without loading OULAD.
- `core`: loads and preprocesses OULAD but does not run the full experiment suite.
- `full`: trains all configured DKT/SAKT and mitigation experiments from scratch.

```bash
export EXECUTION_PROFILE=tables_only
jupyter lab notebooks/fairness_dp_knowledge_tracing.ipynb
```

Full reproduction is computationally expensive because it covers three seeds, multiple privacy budgets, two architectures, and mitigation ablations:

```bash
export EXECUTION_PROFILE=full
export OULAD_DIR=/path/to/oulad
jupyter lab notebooks/fairness_dp_knowledge_tracing.ipynb
```

Generated caches and outputs are written to `artifacts/` by default. Override this with `OUTPUT_DIR`.

Run the repository checks locally with:

```powershell
.\scripts\validate_repository.ps1
```

## Main Experimental Stages

| Stage | Purpose |
|---|---|
| D8 | Main DKT privacy, utility, calibration, and fairness effects |
| D9 | Bootstrap and imbalance-controlled robustness checks |
| D10 | Loss, gradient norm, and clipping diagnostics |
| D11 | Static group reweighting baselines |
| D12 | SAKT architecture robustness |
| D13-D14 | Pairwise ranking and clipping-aware mitigation probes |
| D15 | LIRE mitigation at epsilon 10 |
| D16 | Stronger-privacy confirmation and SAKT transfer test |

## Reproducibility Configuration

- Seeds: `42`, `43`, `44`
- Student-level split seed: `2026`
- Maximum sequence length: `100`
- DKT batch size: `1024`
- SAKT batch size: `512`
- Hidden/model dimension: `64`
- Epochs: `8`
- Learning rate: `1e-3`
- Default clipping norm: `1.0`
- Privacy budgets: `epsilon in {10, 1, 0.5}`
- Target delta: `1e-5`

## Result Scope

The repository contains aggregate outputs needed to audit the reported findings. Per-student and per-interaction prediction files are excluded to keep the public package compact and avoid redistributing derived learner-level records.

## License

This repository is released under the [MIT License](LICENSE).
