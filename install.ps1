[CmdletBinding()]
param(
    [string]$Source = "$PSScriptRoot\skills",
    [string]$Destination = "$env:USERPROFILE\.claude\skills"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Source -PathType Container)) {
    throw "Skills directory not found: $Source"
}

New-Item -ItemType Directory -Path $Destination -Force | Out-Null

Get-ChildItem -LiteralPath $Source -Directory | ForEach-Object {
    $skillName = $_.Name
    $skillSource = $_.FullName
    $skillLink = Join-Path $Destination $skillName

    if (-not (Test-Path (Join-Path $skillSource "SKILL.md"))) {
        Write-Warning "Skipping '$skillName' (no SKILL.md)"
        return
    }

    if (Test-Path $skillLink) {
        $item = Get-Item $skillLink -Force

        # If it's already a junction to the right place, leave it alone.
        if ($item.LinkType -eq "Junction" -and $item.Target -eq $skillSource) {
            Write-Host "✓ $skillName already linked"
            return
        }

        Remove-Item $skillLink -Recurse -Force
    }

    New-Item `
        -ItemType Junction `
        -Path $skillLink `
        -Target $skillSource | Out-Null

    Write-Host "✓ Linked $skillName"
}