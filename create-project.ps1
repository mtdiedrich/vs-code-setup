param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    [Parameter(Mandatory=$true)]
    [string]$ProjectLocation,
    [Parameter(Mandatory=$true)]
    [string]$ProjectType,
    [Parameter(Mandatory=$true)]
    [string]$VirtualEnv,
    [Parameter(Mandatory=$true)]
    [string]$GitSetup
)

$ProjectPath = Join-Path $ProjectLocation $ProjectName

# Validate inputs
if (-not $ProjectName -or $ProjectName.Trim() -eq "") {
    Write-Host "Error: Project name cannot be empty" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $ProjectLocation)) {
    Write-Host "Error: Parent directory '$ProjectLocation' does not exist" -ForegroundColor Red
    exit 1
}

if (Test-Path $ProjectPath) {
    Write-Host "Error: Project directory '$ProjectPath' already exists" -ForegroundColor Red
    exit 1
}

Write-Host "Creating $ProjectType project: $ProjectName" -ForegroundColor Green
Write-Host "Location: $ProjectPath" -ForegroundColor Green
Write-Host "Virtual Environment: $VirtualEnv" -ForegroundColor Green
Write-Host "Git Setup: $GitSetup" -ForegroundColor Green

# Set error action to stop on any error (but we'll handle Poetry separately)
$ErrorActionPreference = "Stop"

# Create project structure
try {
    New-Item -ItemType Directory -Path $ProjectPath -Force | Out-Null
    Write-Host "✓ Created project folder: $ProjectPath" -ForegroundColor Green
    
    Set-Location $ProjectPath
    
    # Create subdirectories based on project type
    if ($ProjectType -eq "Python (Data Science)") {
        New-Item -ItemType Directory -Path "data", "src", "notebooks" -Force | Out-Null
        Write-Host "✓ Created folders: data, src, notebooks" -ForegroundColor Green
    } elseif ($ProjectType -eq "Python (Standard)") {
        New-Item -ItemType Directory -Path "src" -Force | Out-Null
        Write-Host "✓ Created folder: src" -ForegroundColor Green
    } else {
        Write-Host "✓ No additional folders created" -ForegroundColor Green
    }
    
    # Create files based on project type
    if ($ProjectType -like "Python*") {
        New-Item -ItemType File -Path "src\__init__.py" -Force | Out-Null
        Write-Host "✓ Created files: src\__init__.py" -ForegroundColor Green
    }
    
    # Create .gitignore if git is enabled
    if ($GitSetup -eq "Yes") {
        # Create .gitignore
        $gitignoreContent = @"
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*`$py.class

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
pip-wheel-metadata/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Project specific
*.log
.pytest_cache/
.coverage
htmlcov/
"@
        
        Set-Content -Path ".gitignore" -Value $gitignoreContent
        Write-Host "✓ Created .gitignore" -ForegroundColor Green
    }
    
    # Initialize virtual environment based on selection
    if ($VirtualEnv -eq "Poetry") {
        Write-Host "Initializing Poetry..." -ForegroundColor Yellow
        if (Get-Command poetry -ErrorAction SilentlyContinue) {
            Write-Host "Running: poetry init --no-interaction --name $ProjectName" -ForegroundColor Gray
            poetry init --no-interaction --name $ProjectName
            if ($LASTEXITCODE -ne 0) {
                Write-Host "Error: Poetry init failed with exit code $LASTEXITCODE" -ForegroundColor Red
                Write-Host "Cleaning up project folder..." -ForegroundColor Yellow
                Set-Location ..
                Remove-Item -Path $ProjectPath -Recurse -Force
                exit 1
            }
            Write-Host "✓ Poetry initialized" -ForegroundColor Green
            
            Write-Host "Installing dependencies..." -ForegroundColor Yellow
            Write-Host "Running: poetry install --no-root" -ForegroundColor Gray
            poetry install --no-root
            if ($LASTEXITCODE -ne 0) {
                Write-Host "Error: Poetry install failed with exit code $LASTEXITCODE" -ForegroundColor Red
                Write-Host "Cleaning up project folder..." -ForegroundColor Yellow
                Set-Location ..
                Remove-Item -Path $ProjectPath -Recurse -Force
                exit 1
            }
            Write-Host "✓ Poetry virtual environment created" -ForegroundColor Green
        } else {
            Write-Host "Error: Poetry not found - please install Poetry first" -ForegroundColor Red
            Write-Host "Cleaning up project folder..." -ForegroundColor Yellow
            Set-Location ..
            Remove-Item -Path $ProjectPath -Recurse -Force
            exit 1
        }
    } elseif ($VirtualEnv -eq "venv") {
        Write-Host "Creating venv virtual environment..." -ForegroundColor Yellow
        if (Get-Command python -ErrorAction SilentlyContinue) {
            Write-Host "Running: python -m venv venv" -ForegroundColor Gray
            python -m venv venv
            if ($LASTEXITCODE -ne 0) {
                Write-Host "Error: venv creation failed with exit code $LASTEXITCODE" -ForegroundColor Red
                Write-Host "Cleaning up project folder..." -ForegroundColor Yellow
                Set-Location ..
                Remove-Item -Path $ProjectPath -Recurse -Force
                exit 1
            }
            Write-Host "✓ venv virtual environment created" -ForegroundColor Green
            Write-Host "Note: Activate with 'venv\Scripts\activate' (Windows) or 'source venv/bin/activate' (Linux/Mac)" -ForegroundColor Cyan
        } else {
            Write-Host "Error: Python not found - please install Python first" -ForegroundColor Red
            Write-Host "Cleaning up project folder..." -ForegroundColor Yellow
            Set-Location ..
            Remove-Item -Path $ProjectPath -Recurse -Force
            exit 1
        }
    } elseif ($VirtualEnv -eq "conda") {
        Write-Host "Creating conda virtual environment..." -ForegroundColor Yellow
        if (Get-Command conda -ErrorAction SilentlyContinue) {
            Write-Host "Running: conda create --name $ProjectName python -y" -ForegroundColor Gray
            conda create --name $ProjectName python -y
            if ($LASTEXITCODE -ne 0) {
                Write-Host "Error: conda environment creation failed with exit code $LASTEXITCODE" -ForegroundColor Red
                Write-Host "Cleaning up project folder..." -ForegroundColor Yellow
                Set-Location ..
                Remove-Item -Path $ProjectPath -Recurse -Force
                exit 1
            }
            Write-Host "✓ conda virtual environment '$ProjectName' created" -ForegroundColor Green
            Write-Host "Note: Activate with 'conda activate $ProjectName'" -ForegroundColor Cyan
        } else {
            Write-Host "Error: conda not found - please install Anaconda or Miniconda first" -ForegroundColor Red
            Write-Host "Cleaning up project folder..." -ForegroundColor Yellow
            Set-Location ..
            Remove-Item -Path $ProjectPath -Recurse -Force
            exit 1
        }
    } else {
        Write-Host "✓ Skipped virtual environment setup" -ForegroundColor Green
    }
    
    # Create README content if git is enabled
    if ($GitSetup -eq "Yes") {
        $readmeContent = @"
# $ProjectName

## Setup

1. Install dependencies:
   ```powershell
   poetry install
   ```

2. Activate virtual environment:
   ```powershell
   poetry shell
   ```

## Project Structure

- data/ - Data files
- src/ - Source code  
- notebooks/ - Jupyter notebooks

"@
        
        Set-Content -Path "README.md" -Value $readmeContent
        Write-Host "✓ Created README.md with basic content" -ForegroundColor Green
        
        # Initialize git AFTER everything is created
        Write-Host "Initializing Git..." -ForegroundColor Yellow
        if (Get-Command git -ErrorAction SilentlyContinue) {
            git init 2>$null
            git add . 2>$null
            git commit -m "Initial commit: project structure" 2>$null
            Write-Host "✓ Git initialized with initial commit" -ForegroundColor Green
        } else {
            Write-Host "⚠ Git not found - skipping git init" -ForegroundColor Yellow
        }
    } else {
        Write-Host "✓ Skipped git setup" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "🎉 Project '$ProjectName' created successfully!" -ForegroundColor Cyan
    Write-Host "📁 Location: $ProjectPath" -ForegroundColor Cyan
    Write-Host ""
    
    # Wait for user input before opening VS Code
    Write-Host "Press any key to open the project in VS Code..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    # Open in VS Code
    if (Get-Command code -ErrorAction SilentlyContinue) {
        Write-Host "🚀 Opening project in VS Code..." -ForegroundColor Cyan
        code $ProjectPath --reuse-window --trust
    } else {
        Write-Host "⚠ VS Code CLI not found - please open the folder manually" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Cleaning up project folder..." -ForegroundColor Yellow
    if (Test-Path $ProjectPath) {
        Set-Location ..
        Remove-Item -Path $ProjectPath -Recurse -Force
    }
    exit 1
}