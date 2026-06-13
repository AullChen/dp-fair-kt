$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$required = @(
    "README.md",
    "LICENSE",
    "requirements.txt",
    "environment.yml",
    "notebooks/fairness_dp_knowledge_tracing.ipynb",
    "results/metrics/all_metrics.csv"
)

foreach ($relativePath in $required) {
    $path = Join-Path $root $relativePath
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing required repository file: $relativePath"
    }
}

$notebookPath = Join-Path $root "notebooks/fairness_dp_knowledge_tracing.ipynb"
$notebook = Get-Content -LiteralPath $notebookPath -Raw -Encoding UTF8 | ConvertFrom-Json
if ($notebook.nbformat -ne 4) {
    throw "Unexpected notebook format: $($notebook.nbformat)"
}

$codeCells = @($notebook.cells | Where-Object { $_.cell_type -eq "code" })
$outputCount = @($codeCells | ForEach-Object { $_.outputs }).Count
$executionCount = @($codeCells | Where-Object { $null -ne $_.execution_count }).Count
if ($outputCount -ne 0 -or $executionCount -ne 0) {
    throw "Notebook outputs or execution counters were not cleared."
}

$figureCount = @(Get-ChildItem -LiteralPath (Join-Path $root "figures") -File -Filter "*.png").Count
$tableCount = @(Get-ChildItem -LiteralPath (Join-Path $root "results/tables") -File).Count
if ($figureCount -ne 8) {
    throw "Expected 8 paper figures, found $figureCount."
}
if ($tableCount -ne 30) {
    throw "Expected 30 paper table files, found $tableCount."
}

$forbidden = Get-ChildItem -Recurse -File -LiteralPath $root | Where-Object {
    $_.Name -match "(_all_predictions|_test_predictions)\.csv$" -or
    $_.Extension -in @(".pkl", ".pt", ".pth")
}
if ($forbidden) {
    $names = ($forbidden.FullName -join [Environment]::NewLine)
    throw "Forbidden large or learner-level artifacts found:`n$names"
}

$oversized = Get-ChildItem -Recurse -File -LiteralPath $root | Where-Object { $_.Length -gt 10MB }
if ($oversized) {
    $names = ($oversized.FullName -join [Environment]::NewLine)
    throw "Files larger than 10 MB found:`n$names"
}

Write-Output "Repository validation passed."
