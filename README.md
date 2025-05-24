# VS Code Setup

Horrific README written entirely by Claude Sonnet 4. I have not reviewed it for accuracy.

🚀 **Revolutionize your development workflow! Instantly create new projects with customizable folder structures, virtual environments, and git initialization - all from within VS Code!**

![Project Creator Demo](https://img.shields.io/badge/VS%20Code-Project%20Creator-blue?style=for-the-badge&logo=visual-studio-code)

## ✨ Features That Will Transform Your Development Experience

- 🎯 **Lightning-fast project creation** with intelligent interactive prompts
- 📁 **Infinitely flexible project architectures**: Python (Data Science), Python (Standard), or completely custom minimal setup
- 🐍 **Seamless virtual environment orchestration**: Poetry integration with fully automated dependency management
- 📝 **Enterprise-grade git workflow**: Automatic `.gitignore`, `README.md`, and repository initialization with best practices
- 🧹 **Bulletproof error handling**: Intelligently removes partially created projects if setup encounters any issues
- 🔒 **Zero-friction workspace security**: Automatically establishes trust for new project folders
- ⚡ **Ergonomic keyboard shortcuts**: Blazingly fast access with `Alt+N`
- 🔄 **One-click automated setup**: Revolutionary installation script that configures everything automagically

## 🎬 Witness the Magic in Action

1. Press `Alt+N` in VS Code ✨
2. Thoughtfully choose your project name and optimal location 🎯
3. Intelligently select project type, virtual environment strategy, and git configuration 🧠
4. Marvel as your perfectly structured project materializes before your eyes! 🪄

## 🚀 Lightning-Quick Start (Game-Changing Simplicity!)

```powershell
# Clone this life-changing repository
git clone https://github.com/your-username/vscode-project-creator.git
cd vscode-project-creator

# Execute our revolutionary automated setup
.\setup.ps1

# 🎉 That's literally it! Press Alt+N in VS Code to unleash your first project
```

## 📋 Prerequisites

### Required
- **VS Code** with CLI access (`code` command)
- **PowerShell** (Windows built-in)

### Optional (based on your project choices)
- **Poetry** - For Python virtual environments: `pip install poetry`
- **Git** - For version control: [Download here](https://git-scm.com/downloads)
- **Python** - For Python projects: [Download here](https://www.python.org/downloads/)

## 📦 Project Types

### Python (Data Science)
Perfect for data analysis and machine learning projects:
```
MyProject/
├── data/           # Raw and processed data
├── src/            # Source code
│   └── __init__.py
├── notebooks/      # Jupyter notebooks
├── .gitignore      # Python-specific gitignore
├── README.md       # Project documentation
├── pyproject.toml  # Poetry configuration
└── poetry.lock     # Locked dependencies
```

### Python (Standard)
Clean setup for general Python development:
```
MyProject/
├── src/
│   └── __init__.py
├── .gitignore
├── README.md
├── pyproject.toml
└── poetry.lock
```

### None
Minimal setup - just the project folder:
```
MyProject/
```

## ⚙️ Configuration Options

When you run the project creator, you'll be prompted for:

| Option | Choices | Description |
|--------|---------|-------------|
| **Project Name** | Custom input | Name of your project folder |
| **Project Location** | Custom path | Where to create the project |
| **Project Type** | Data Science / Standard / None | Folder structure to create |
| **Virtual Environment** | Poetry / None | Whether to set up Poetry |
| **Git Setup** | Yes / No | Initialize git repo with files |

## 🎮 Usage

### Method 1: Keyboard Shortcut
- Press `Alt+N` anywhere in VS Code

### Method 2: Command Palette
1. Press `Ctrl+Shift+P`
2. Type "Tasks: Run Task"
3. Select "Create Python Project"

### Method 3: Manual Task Runner
1. Go to Terminal → Run Task
2. Select "Create Python Project"

## 🛠️ Manual Installation

If you prefer to set things up manually:

1. **Download the files**:
   - `create-project.ps1` - The project creation script
   - `settings.json` - VS Code task configuration

2. **Place the PowerShell script** somewhere permanent:
   ```powershell
   # Option 1: Dedicated scripts folder
   New-Item -ItemType Directory -Path "C:\Scripts" -Force
   Copy-Item "create-project.ps1" "C:\Scripts\"
   
   # Option 2: User profile
   Copy-Item "create-project.ps1" "$env:USERPROFILE\"
   ```

3. **Configure VS Code**:
   - Press `Ctrl+Shift+P`
   - Type "Preferences: Open User Settings (JSON)"
   - Merge the contents of `settings.json` into your settings
   - Update the script path in the `command` field

4. **Set up keybinding** (optional):
   - Press `Ctrl+Shift+P`
   - Type "Preferences: Open Keyboard Shortcuts (JSON)"
   - Add the keybinding from `settings.json`

## 🔧 Customization

### Adding New Project Types

1. **Edit `settings.json`**: Add your new option to the `projectType` input
2. **Edit `create-project.ps1`**: Add folder creation logic for your new type
3. **Update documentation**: Add examples to this README

### Changing Default Values

Edit the `default` values in `settings.json`:
```json
{
  "id": "projectType",
  "default": "Python (Data Science)"  // Change this
}
```

### Custom Folder Structures

Modify the folder creation section in `create-project.ps1`:
```powershell
if ($ProjectType -eq "Your Custom Type") {
    New-Item -ItemType Directory -Path "custom", "folders", "here" -Force | Out-Null
    Write-Host "✓ Created custom folder structure" -ForegroundColor Green
}
```

## 🐛 Troubleshooting

### Common Issues

**"Poetry not found"**
```powershell
pip install poetry
# Restart VS Code
poetry --version  # Verify installation
```

**"Git not found"**
- Install Git from [git-scm.com](https://git-scm.com/downloads)
- Restart VS Code after installation

**"Cannot find drive" error**
- Verify the project location path exists
- Check you have write permissions to the target directory

**PowerShell execution policy error**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**VS Code doesn't open the project**
```powershell
code --version  # Check if VS Code CLI is available
```
If not available, reinstall VS Code and ensure "Add to PATH" is selected.

### Getting Help

If the script fails partway through, it automatically cleans up partial projects. Check the terminal output for specific error messages.

## 📁 Repository Structure

```
vscode-project-creator/
├── create-project.ps1    # Main project creation script
├── settings.json         # VS Code configuration template
├── setup.ps1            # Automated setup script
└── README.md            # This file
```

## 🤝 Contributing

Contributions are welcome! Here are some ideas:

- **New project types**: Web development, React, etc.
- **Additional virtual environments**: venv, conda, etc.
- **Cross-platform support**: Bash scripts for Linux/Mac
- **VS Code extension**: Convert to a proper extension
- **Templates**: Pre-built project templates

### Development Setup

1. Fork the repository
2. Make your changes
3. Test with `.\setup.ps1` on a clean VS Code installation
4. Submit a pull request

## 📄 License

MIT License - feel free to use this in your own projects!

## 🙏 Acknowledgments

- Meticulously crafted for visionary developers who refuse to accept the status quo of repetitive project setup
- Ingeniously inspired by the universal developer pain point of inconsistent project architectures
- Masterfully powered by VS Code's sophisticated and robust task orchestration system
- Thoughtfully designed with developer experience (DX) as the North Star
- Built with an obsessive attention to detail and user-centric design principles

---

**⭐ If this revolutionary tool saves you precious development time and enhances your workflow, please grace us with a star! Your support fuels our passion for creating exceptional developer tools.**

Crafted with 💖, countless hours of dedication, and an unwavering commitment to developer happiness by the community, for the community
