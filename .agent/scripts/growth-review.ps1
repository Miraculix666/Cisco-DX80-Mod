<#
.SYNOPSIS
    Repository Growth & Maturity Review Scanner
.DESCRIPTION
    Scans the repository to measure file counts, LOC, languages, and presence of tests.
    Generates a report at .agent/memory/GROWTH_REVIEW.md.
.PARAMETER Path
    The root path of the repository to scan. Defaults to the parent folder of the .agent directory.
#>
[CmdletBinding()]
param(
    [string]$Path = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
)

$ErrorActionPreference = "Stop"

Write-Verbose "Scanning repository at: $Path"

# Define exclude filters
$ExcludeDirs = @('.git', '.agent', 'venv', 'node_modules', 'WIP', 'tmp', 'tmp-test', 'logs')

# 1. Gather all files
$allFiles = Get-ChildItem -Path $Path -File -Recurse -ErrorAction SilentlyContinue | Where-Object {
    $relative = $_.FullName.Substring($Path.Length).TrimStart('\','/')
    $inExclude = $false
    foreach ($dir in $ExcludeDirs) {
        if ($relative -like "$dir*" -or $relative -like "*\$dir\*") {
            $inExclude = $true
            break
        }
    }
    -not $inExclude
}

# 2. Compute metrics
$fileCount = $allFiles.Count
$totalLoc = 0
$extensions = @{}
$largeFiles = @()

foreach ($file in $allFiles) {
    # Count extensions
    $ext = $file.Extension.ToLower()
    if (-not $ext) { $ext = ".no-extension" }
    $extensions[$ext] = ($extensions[$ext] + 1)
    
    # Calculate LOC for text files
    $isText = $file.Extension -match "ps1|py|sh|json|yaml|yml|md|txt|xml|ini|conf|cfg|csv|js|ts|html|css"
    if ($isText) {
        try {
            $lines = (Get-Content -Path $file.FullName -ErrorAction SilentlyContinue).Count
            $totalLoc += $lines
            if ($lines -gt 500) {
                $largeFiles += [PSCustomObject]@{
                    Path = $file.FullName.Substring($Path.Length).TrimStart('\','/')
                    Lines = $lines
                }
            }
        } catch {}
    }
}

# 3. Detect Tests & CI
$hasTests = Test-Path (Join-Path $Path "tests") -ErrorAction SilentlyContinue
$hasCI = Test-Path (Join-Path $Path ".github") -or (Test-Path (Join-Path $Path ".gitlab-ci.yml"))

# 4. Determine Maturity Level
$level = "L0 (Einzelscript)"
$statusDetails = "Single file script"
if ($fileCount -gt 30 -or $totalLoc -gt 5000) {
    $level = "L3 (Package / Service)"
    $statusDetails = "Multi-platform or high file counts/LOC"
} elseif ($fileCount -gt 10 -or $totalLoc -gt 1000 -or $hasTests) {
    $level = "L2 (Strukturiertes Projekt)"
    $statusDetails = "Structured project with tests/CI assets"
} elseif ($fileCount -gt 1) {
    $level = "L1 (Multi-File Tool)"
    $statusDetails = "Multi-file utility"
}

# 5. Generate Recommendations
$recommendations = @()
if ($fileCount -gt 20 -and -not (Test-Path (Join-Path $Path "src"))) {
    $recommendations += "Ordnerstruktur aufräumen und Quellcode in ein `src/` Verzeichnis verschieben."
}
if ($totalLoc -gt 500 -and -not $hasTests) {
    $recommendations += "Test-Abdeckung fehlt. Ein automatisches Test-Framework (z.B. pytest oder Pester) sollte in `tests/` etabliert werden."
}
foreach ($lf in $largeFiles) {
    $recommendations += "Die Datei `$($lf.Path)` ist mit $($lf.Lines) Zeilen sehr groß. Aufteilen in Module/Funktionen empfohlen."
}
if ($extensions.Keys.Count -gt 2) {
    $recommendations += "Mehrere Sprachen vorhanden. Build-System oder CLI-Framework evaluieren."
}
if ($recommendations.Count -eq 0) {
    $recommendations += "Keine dringenden Empfehlungen. Projektstruktur entspricht dem Reifegrad."
}

# 6. Format Report
$extString = ""
foreach ($key in $extensions.Keys) {
    $extString += "| `$key` | $($extensions[$key]) |`n"
}

$recString = ""
foreach ($rec in $recommendations) {
    $recString += "- $rec`n"
}

$largeString = ""
if ($largeFiles.Count -gt 0) {
    $largeString = "### Große Dateien (>500 LOC)`n| Pfad | Zeilen |`n|---|---|`n"
    foreach ($lf in $largeFiles) {
        $largeString += "| $($lf.Path) | $($lf.Lines) |`n"
    }
}

$report = @"
# Growth Review — $(Split-Path $Path -Leaf)

| Metrik | Aktueller Wert | Status / Schwellwert |
|---|---|---|
| **Reifegrad** | **$level** | $statusDetails |
| **Dateien gesamt** | $fileCount | Schwelle L2: >10, L3: >30 |
| **Zeilen Code (LOC)** | $totalLoc | Schwelle L2: >1000, L3: >5000 |
| **Tests vorhanden** | $(if ($hasTests) { "Ja" } else { "Nein" }) | Erforderlich für L2 / >500 LOC |
| **CI/CD vorhanden** | $(if ($hasCI) { "Ja" } else { "Nein" }) | Erforderlich für L3 |

## Sprach- / Dateitypverteilung
| Erweiterung | Anzahl |
|---|---|
$extString
$largeString
## Empfehlungen
$recString

*Review generiert am: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")*
"@

# Write Report file
$memoryDir = Join-Path $Path ".agent\memory"
if (-not (Test-Path $memoryDir)) {
    New-Item -ItemType Directory -Path $memoryDir -Force | Out-Null
}
$reportPath = Join-Path $memoryDir "GROWTH_REVIEW.md"
Set-Content -Path $reportPath -Value $report -Force

Write-Output "Growth Review Report successfully generated at $reportPath"
