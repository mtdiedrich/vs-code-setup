#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Automatically sets up the VS Code Project Creator on this machine
.DESCRIPTION
    This script will:
    1. Find VS Code's settings.json location
    2. Backup the current settings.json
    3. Merge the project creator task into existing settings
    4. Update the PowerShell script path to the current location
.EXAMPLE
    .\setup.ps1
#>

param(
    [switch]$Force,
    [switch]$BackupOnly
)

Write-Host "=== VS Code Project Creator Setup ===" -ForegroundColor Cyan
Write-Host ""

# Get the directory where this setup script is located
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectCreatorScript = Join-Path $ScriptDir "create-project.ps1"
$SettingsTemplate = Join-Path $ScriptDir "settings.json"

Write-Host "Script directory: $ScriptDir" -ForegroundColor Gray
Write-Host "Project creator script: $ProjectCreatorScript" -ForegroundColor Gray

# Verify required files exist
if (-not (Test-Path $ProjectCreatorScript)) {
    Write-Host "Error: create-project.ps1 not found in $ScriptDir" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $SettingsTemplate)) {
    Write-Host "Error: settings.json not found in $ScriptDir" -ForegroundColor Red
    exit 1
}

# Find VS Code settings location
$VSCodeSettingsPath = $null
$PossiblePaths = @(
    "$env:APPDATA\Code\User\settings.json",           # Windows Stable
    "$env:APPDATA\Code - Insiders\User\settings.json", # Windows Insiders
    "$env:USERPROFILE\.vscode\extensions",            # Portable Windows
    "$HOME/.config/Code/User/settings.json",         # Linux
    "$HOME/Library/Application Support/Code/User/settings.json" # macOS
)

foreach ($Path in $PossiblePaths) {
    $ParentDir = Split-Path -Parent $Path
    if (Test-Path $ParentDir) {
        $VSCodeSettingsPath = $Path
        Write-Host "Found VS Code settings directory: $ParentDir" -ForegroundColor Green
        break
    }
}

if (-not $VSCodeSettingsPath) {
    Write-Host "Error: Could not find VS Code settings directory" -ForegroundColor Red
    Write-Host "Please ensure VS Code is installed and has been run at least once" -ForegroundColor Yellow
    exit 1
}

# Create settings file if it doesn't exist
if (-not (Test-Path $VSCodeSettingsPath)) {
    Write-Host "Creating new settings.json file..." -ForegroundColor Yellow
    New-Item -ItemType File -Path $VSCodeSettingsPath -Force | Out-Null
    Set-Content -Path $VSCodeSettingsPath -Value "{}"
}

# Backup current settings
$BackupPath = "$VSCodeSettingsPath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Copy-Item $VSCodeSettingsPath $BackupPath -Force
Write-Host "✓ Backed up current settings to: $BackupPath" -ForegroundColor Green

if ($BackupOnly) {
    Write-Host "Backup completed. Exiting as requested." -ForegroundColor Yellow
    exit 0
}

# Read current settings
try {
    $CurrentSettingsJson = Get-Content $VSCodeSettingsPath -Raw
    if ([string]::IsNullOrWhiteSpace($CurrentSettingsJson)) {
        $CurrentSettingsJson = "{}"
    }
    $CurrentSettings = $CurrentSettingsJson | ConvertFrom-Json
} catch {
    Write-Host "Warning: Could not parse existing settings.json. Creating new one." -ForegroundColor Yellow
    $CurrentSettings = @{}
}

# Read template settings
try {
    $TemplateSettingsJson = Get-Content $SettingsTemplate -Raw
    $TemplateSettings = $TemplateSettingsJson | ConvertFrom-Json
} catch {
    Write-Host "Error: Could not parse template settings.json" -ForegroundColor Red
    exit 1
}

# Update the PowerShell script path in template
$EscapedScriptPath = $ProjectCreatorScript -replace '\\', '\\'
Write-Host "Updating script path to: $ProjectCreatorScript" -ForegroundColor Gray

# Update the template with the correct path
if ($TemplateSettings.tasks -and $TemplateSettings.tasks.tasks) {
    foreach ($task in $TemplateSettings.tasks.tasks) {
        if ($task.label -eq "Create Python Project") {
            # Update the script path in the args array
            for ($i = 0; $i -lt $task.args.Length; $i++) {
                if ($task.args[$i] -like "*create-project.ps1") {
                    $task.args[$i] = $EscapedScriptPath
                    Write-Host "✓ Updated script path in task arguments" -ForegroundColor Green
                    break
                }
            }
        }
    }
}

# Merge settings (template takes precedence for tasks)
$MergedSettings = @{}

# Copy all current settings
$CurrentSettings.PSObject.Properties | ForEach-Object {
    $MergedSettings[$_.Name] = $_.Value
}

# Add/overwrite with template settings (except keybindings)
$TemplateSettings.PSObject.Properties | ForEach-Object {
    if ($_.Name -ne "keybindings") {
        $MergedSettings[$_.Name] = $_.Value
        if ($_.Name -eq "tasks") {
            Write-Host "✓ Added project creator task configuration" -ForegroundColor Green
        }
    }
}

# Convert back to JSON and save
try {
    $MergedSettingsJson = $MergedSettings | ConvertTo-Json -Depth 10
    Set-Content -Path $VSCodeSettingsPath -Value $MergedSettingsJson -Encoding UTF8
    Write-Host "✓ Updated VS Code settings.json" -ForegroundColor Green
} catch {
    Write-Host "Error: Could not write updated settings.json" -ForegroundColor Red
    Write-Host "Restoring backup..." -ForegroundColor Yellow
    Copy-Item $BackupPath $VSCodeSettingsPath -Force
    exit 1
}

# Handle keybindings from template
$KeybindingsPath = Join-Path (Split-Path $VSCodeSettingsPath) "keybindings.json"

# Read existing keybindings or create new
$ExistingKeybindings = @()
if (Test-Path $KeybindingsPath) {
    try {
        $KeybindingsJson = Get-Content $KeybindingsPath -Raw
        if (-not [string]::IsNullOrWhiteSpace($KeybindingsJson)) {
            $ExistingKeybindings = $KeybindingsJson | ConvertFrom-Json
        }
    } catch {
        Write-Host "Warning: Could not parse existing keybindings.json" -ForegroundColor Yellow
    }
}

# Add template keybindings (check for duplicates)
$NewKeybindings = @()
$NewKeybindings += $ExistingKeybindings

foreach ($TemplateKeybinding in $TemplateSettings.keybindings) {
    # Check if this keybinding already exists
    $Exists = $ExistingKeybindings | Where-Object { 
        $_.key -eq $TemplateKeybinding.key -and 
        $_.command -eq $TemplateKeybinding.command 
    }
    
    if (-not $Exists) {
        $NewKeybindings += $TemplateKeybinding
        Write-Host "✓ Added keybinding: $($TemplateKeybinding.key) → $($TemplateKeybinding.command)" -ForegroundColor Green
    } else {
        Write-Host "⚠ Keybinding already exists: $($TemplateKeybinding.key)" -ForegroundColor Yellow
    }
}

# Save keybindings
try {
    $KeybindingsJson = $NewKeybindings | ConvertTo-Json -Depth 5
    Set-Content -Path $KeybindingsPath -Value $KeybindingsJson -Encoding UTF8
    Write-Host "✓ Updated keybindings.json" -ForegroundColor Green
} catch {
    Write-Host "Warning: Could not update keybindings.json" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Setup Complete! ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "The project creator is now available in VS Code:" -ForegroundColor Green
Write-Host "1. Press Ctrl+Shift+P" -ForegroundColor White
Write-Host "2. Type 'Tasks: Run Task'" -ForegroundColor White  
Write-Host "3. Select 'Create Python Project'" -ForegroundColor White

# Show keybinding info
$Keybinding = $TemplateSettings.keybindings | Where-Object { $_.command -eq "workbench.action.tasks.runTask" } | Select-Object -First 1
if ($Keybinding) {
    Write-Host "4. OR press $($Keybinding.key)" -ForegroundColor White
}

Write-Host ""
Write-Host "Files:" -ForegroundColor Yellow
Write-Host "  Script: $ProjectCreatorScript" -ForegroundColor Gray
Write-Host "  Settings: $VSCodeSettingsPath" -ForegroundColor Gray
Write-Host "  Backup: $BackupPath" -ForegroundColor Gray
Write-Host ""

Write-Host ""
Write-Host "Setup completed successfully! 🎉" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")