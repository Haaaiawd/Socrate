# init.py
"""socrate init command: Initialize new learning project"""

from pathlib import Path
from typing import Optional

import typer
import questionary
from rich.console import Console
from rich.panel import Panel
from rich.text import Text
from rich.align import Align

from ..utils.git import check_git_installed, init_repository
from ..utils.template import (
    copy_templates_to_project, 
    copy_prompts_to_project, 
    copy_scripts_to_project,
    copy_claude_commands_to_project
)
from ..utils.progress import track_steps, print_success, print_error, print_warning, confirm


console = Console(legacy_windows=True)  # Enable Windows PowerShell compatibility


def _select_ai_type() -> str:
    """Interactive AI assistant selection with arrow keys"""
    console.print("\n[bold cyan]Select AI Assistant:[/bold cyan]\n")
    
    choice = questionary.select(
        "Choose your AI assistant:",
        choices=[
            questionary.Choice("GitHub Copilot", value="copilot"),
            questionary.Choice("Claude Code", value="claude")
        ],
        style=questionary.Style([
            ('selected', 'fg:cyan bold'),
            ('pointer', 'fg:cyan bold'),
            ('highlighted', 'fg:cyan'),
        ])
    ).ask()
    
    if choice is None:  # User cancelled (Ctrl+C)
        console.print("\n[yellow]Cancelled.[/yellow]")
        raise typer.Exit(0)
    
    return choice


def _print_step(step: int, total: int, message: str, status: str = "progress", details: str = ""):
    """Print a step in the initialization process with consistent formatting
    
    Args:
        step: Current step number
        total: Total number of steps
        message: Step description
        status: 'progress', 'success', 'skip', 'error'
        details: Additional details like file count
    """
    # Format step counter
    counter = f"[ {step:2d}/{total} ]"
    
    # Status symbols
    symbols = {
        "progress": "",
        "success": "✓",
        "skip": "⏭",
        "error": "✗"
    }
    
    # Status colors
    colors = {
        "progress": "blue",
        "success": "green",
        "skip": "dim",
        "error": "red"
    }
    
    symbol = symbols.get(status, "")
    color = colors.get(status, "blue")
    
    # Build output
    if status == "progress":
        console.print(f"  [bold {color}]{counter} {message}...[/bold {color}]", end=" ")
    else:
        suffix = f" [dim]({details})[/dim]" if details else ""
        console.print(f"[{color}]{symbol}[/{color}]{suffix}")


def _print_logo():
    """Print Socrate ASCII logo (no emoji)"""
    logo = r"""
    ╔════════════════════════════════════════════════════╗
    ║                                                    ║
    ║   ███████╗ ██████╗  ██████╗██████╗  █████╗ ████████╗███████╗ ║
    ║   ██╔════╝██╔═══██╗██╔════╝██╔══██╗██╔══██╗╚══██╔══╝██╔════╝ ║
    ║   ███████╗██║   ██║██║     ██████╔╝███████║   ██║   █████╗   ║
    ║   ╚════██║██║   ██║██║     ██╔══██╗██╔══██║   ██║   ██╔══╝   ║
    ║   ███████║╚██████╔╝╚██████╗██║  ██║██║  ██║   ██║   ███████╗ ║
    ║   ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝ ║
    ║                                                    ║
    ║          Learn Like Socrates Taught                ║
    ║           Wisdom Through Questions                 ║
    ║                 Version 0.2.0                      ║
    ║                                                    ║
    ╚════════════════════════════════════════════════════╝
    """
    console.print(logo, style="bold cyan", highlight=False)


def init_command(
    project_name: Optional[str] = typer.Argument(
        None,
        help="Project name/directory to create (default: current directory)"
    ),
    no_git: bool = typer.Option(
        False,
        "--no-git",
        help="Skip Git repository initialization"
    ),
    force: bool = typer.Option(
        False,
        "--force",
        "-f",
        help="Overwrite existing project"
    ),
    ai_type: Optional[str] = typer.Option(
        None,
        "--ai-type",
        help="AI assistant type: copilot, claude, or both (interactive if not specified)"
    )
):
    """
    Initialize a new Socrate learning project
    
    Creates project structure with templates and configuration files.
    Optionally initializes Git repository.
    """
    # Determine project directory
    if project_name:
        target_dir = Path(project_name).resolve()
    else:
        target_dir = Path.cwd()
    
    # Show ASCII Logo
    _print_logo()
    
    # Show target directory
    console.print(f"[dim]Initializing at:[/dim] [bold cyan]{target_dir}[/bold cyan]\n")
    
    # Check if project already exists
    specify_dir = target_dir / ".specify"
    if specify_dir.exists() and not force:
        print_error("Project already initialized!")
        print_warning(f"Found existing .specify directory at {specify_dir}")
        
        if not confirm("Overwrite existing project?", default=False):
            console.print("\n[yellow]Initialization cancelled.[/yellow]")
            raise typer.Exit(1)
    
    # Select AI type (interactive or from parameter)
    if ai_type:
        ai_type_lower = ai_type.lower()
        if ai_type_lower not in ["copilot", "claude", "both"]:
            print_error(f"Invalid AI type: {ai_type}. Must be 'copilot', 'claude', or 'both'")
            raise typer.Exit(1)
    else:
        ai_type_lower = _select_ai_type()
    
    # Show selection
    ai_names = {
        "copilot": "GitHub Copilot",
        "claude": "Claude Code"
    }
    console.print(f"\n[green]✓[/green] Selected: [bold]{ai_names[ai_type_lower]}[/bold]\n")
    
    # Calculate total steps dynamically (both installs both AI, so +1 step)
    total_steps = 8  # Base steps
    if ai_type_lower == "both":
        total_steps += 1  # Extra step for second AI (CLI parameter only)
    if not no_git:
        total_steps += 1  # Git initialization
    
    try:
        step = 1
        
        # Step 1: Create directory structure
        _print_step(step, total_steps, "Creating directories", "progress")
        _create_directory_structure(target_dir, ai_type_lower)
        _print_step(step, total_steps, "Creating directories", "success")
        step += 1
        
        # Step 2: Copy templates
        _print_step(step, total_steps, "Copying templates", "progress")
        if not copy_templates_to_project(target_dir):
            raise Exception("Failed to copy templates")
        _print_step(step, total_steps, "Copying templates", "success", "4 files")
        step += 1
        
        # Step 3: Copy AI prompts/commands based on selection
        if ai_type_lower == "copilot" or ai_type_lower == "both":
            _print_step(step, total_steps, "Copying GitHub Copilot prompts", "progress")
            if not copy_prompts_to_project(target_dir):
                raise Exception("Failed to copy prompts")
            _print_step(step, total_steps, "Copying GitHub Copilot prompts", "success", "5 files")
            step += 1
        
        if ai_type_lower == "claude" or ai_type_lower == "both":
            _print_step(step, total_steps, "Copying Claude Code commands", "progress")
            if not _copy_claude_commands(target_dir):
                raise Exception("Failed to copy Claude commands")
            _print_step(step, total_steps, "Copying Claude Code commands", "success", "5 files")
            step += 1
        
        # Step 4: Copy PowerShell scripts
        _print_step(step, total_steps, "Copying automation scripts", "progress")
        if not copy_scripts_to_project(target_dir):
            raise Exception("Failed to copy scripts")
        _print_step(step, total_steps, "Copying automation scripts", "success", "6 files")
        step += 1
        
        # Step 5: Create data directories
        _print_step(step, total_steps, "Setting up data storage", "progress")
        _create_data_directories(target_dir)
        _print_step(step, total_steps, "Setting up data storage", "success")
        step += 1
        
        # Step 6: Create config file
        _print_step(step, total_steps, "Creating configuration", "progress")
        _create_config_file(target_dir)
        _print_step(step, total_steps, "Creating configuration", "success")
        step += 1
        
        # Step 7: Create VS Code settings
        _print_step(step, total_steps, "Configuring VS Code", "progress")
        _create_vscode_settings(target_dir)
        _print_step(step, total_steps, "Configuring VS Code", "success")
        step += 1
        
        # Step 8: Create .gitignore
        _print_step(step, total_steps, "Creating .gitignore", "progress")
        _create_gitignore(target_dir)
        _print_step(step, total_steps, "Creating .gitignore", "success")
        step += 1
        
        # Step 9 (optional): Initialize Git
        if not no_git:
            _print_step(step, total_steps, "Initializing Git repository", "progress")
            _init_git_repository(target_dir, ai_type_lower)
            _print_step(step, total_steps, "Initializing Git repository", "success")
            step += 1
        
        console.print()  # Empty line
        
        # Success banner
        console.print("    ╔═══════════════════════════════════════╗", style="bold green")
        console.print("    ║   Setup Complete Successfully!        ║", style="bold green")
        console.print("    ╚═══════════════════════════════════════╝", style="bold green")
        console.print()
        
        _print_next_steps(target_dir, ai_type_lower)
    
    except Exception as e:
        print_error(f"Initialization failed: {e}")
        raise typer.Exit(1)


def _create_directory_structure(project_dir: Path, ai_type: str = "copilot"):
    """Create core project directories based on AI type selection"""
    directories = [
        ".specify/scripts/powershell",
        ".specify/templates",
        ".vscode",
        "data/outlines",
        "data/chapters",
        "data/exercises",
        "data/progress",
        "logs"
    ]
    
    # Add AI-specific directories
    if ai_type == "copilot" or ai_type == "both":
        directories.append(".github/prompts")
    if ai_type == "claude" or ai_type == "both":
        directories.append(".claude/commands")
    
    for dir_path in directories:
        full_path = project_dir / dir_path
        full_path.mkdir(parents=True, exist_ok=True)


def _create_data_directories(project_dir: Path):
    """Create data storage directories with README files"""
    data_dirs = {
        "data/outlines": "Generated learning outlines will be saved here",
        "data/chapters": "Individual knowledge point files will be saved here",
        "data/exercises": "Practice exercises (Jupyter Notebooks) will be saved here",
        "data/progress": "Student learning progress will be tracked here"
    }
    
    for dir_path, description in data_dirs.items():
        full_path = project_dir / dir_path
        readme_path = full_path / "README.md"
        
        if not readme_path.exists():
            readme_path.write_text(
                f"# {full_path.name.title()}\n\n{description}\n",
                encoding="utf-8"
            )


def _copy_claude_commands(target_dir: Path) -> bool:
    """Copy Claude Code command files to project"""
    return copy_claude_commands_to_project(target_dir)


def _create_config_file(project_dir: Path):
    """Create default configuration file"""
    config_path = project_dir / ".specify" / "config.yaml"
    
    if config_path.exists():
        return  # Don't overwrite existing config
    
    default_config = """# Socrate Configuration

# AI Model Settings
model:
  provider: openai  # or: azure, anthropic, local
  name: gpt-4  # Model name
  temperature: 0.7  # Response creativity (0.0-1.0)
  max_tokens: 2000  # Maximum response length

# Teaching Style
teaching:
  style: socratic  # Question-driven dialogue approach
  patience_level: high  # How many hints before revealing answers
  difficulty_auto_adjust: true  # Adjust difficulty based on student progress

# Data Paths (relative to project root)
paths:
  textbooks: data/textbooks
  outlines: data/outlines
  chapters: data/chapters
  progress: data/progress
  templates: .specify/templates

# Logging
logging:
  level: INFO  # DEBUG, INFO, WARN, ERROR
  file: logs/socrate.log
"""
    
    config_path.write_text(default_config, encoding="utf-8")


def _create_vscode_settings(project_dir: Path):
    """Create VS Code settings.json with Copilot auto-approval configuration"""
    vscode_dir = project_dir / ".vscode"
    settings_path = vscode_dir / "settings.json"
    
    if settings_path.exists():
        return  # Don't overwrite existing settings
    
    vscode_settings = """{
    "chat.promptFilesRecommendations": {
        "socrate.outline": true,
        "socrate.prepare": true,
        "socrate.check": true,
        "socrate.practice": true,
        "socrate.lesson": true
    },
    "chat.tools.terminal.autoApprove": {
        ".specify/scripts/bash/": true,
        ".specify/scripts/powershell/": true
    }
}
"""
    
    settings_path.write_text(vscode_settings, encoding="utf-8")


def _create_gitignore(project_dir: Path):
    """Create .gitignore file with Socrate-specific rules"""
    gitignore_path = project_dir / ".gitignore"
    
    if gitignore_path.exists():
        return  # Don't overwrite existing .gitignore
    
    gitignore_content = """# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
.venv/
venv/
ENV/
env/

# Testing
.pytest_cache/
.coverage
*.egg-info/
.installed.cfg
*.egg

# IDE & OS
.vscode/
!.vscode/prompts/
.idea/
*.swp
*.swo
*~
.DS_Store
Thumbs.db

# Logs
logs/
*.log

# Socrate - Backups and temporary files (DO NOT COMMIT)
.specify/backups/
*.bak
data/progress.md.bak

# Socrate - Student data (DO NOT COMMIT)
data/
!data/.gitkeep
"""
    
    gitignore_path.write_text(gitignore_content, encoding="utf-8")


def _init_git_repository(project_dir: Path, ai_type: str = "copilot"):
    """Initialize Git repository with initial commit"""
    if not check_git_installed():
        console.print("[yellow]✗[/yellow] [dim](Git not found)[/dim]")
        return
    
    repo = init_repository(project_dir, initial_commit=False)
    
    if repo:
        # Stage all created files (dynamically based on AI type)
        paths = [".gitignore", ".specify", "data", "logs"]
        if ai_type == "copilot" or ai_type == "both":
            paths.append(".github")
        if ai_type == "claude" or ai_type == "both":
            paths.append(".claude")
        repo.index.add(paths)
        
        # Create initial commit
        repo.index.commit("chore: initialize Socrate project\n\nCreated by `socrate init`")
        console.print("[green]✓[/green]")
    else:
        console.print("[yellow]✗[/yellow] [dim](failed)[/dim]")


def _print_next_steps(project_dir: Path, ai_type: str):
    """Print next steps for user based on AI selection"""
    project_name = project_dir.name
    is_current_dir = project_dir.resolve() == Path.cwd().resolve()
    
    console.print("[bold cyan]Next Steps:[/bold cyan]\n")
    
    if not is_current_dir:
        console.print("  [bold]1.[/bold] Navigate to project:")
        console.print(f"     [cyan]cd {project_name}[/cyan]\n")
        step_num = 2
    else:
        step_num = 1
    
    console.print(f"  [bold]{step_num}.[/bold] Open in VS Code:")
    console.print(f"     [cyan]code .[/cyan]\n")
    
    # AI-specific instructions
    if ai_type == "copilot":
        console.print(f"  [bold]{step_num + 1}.[/bold] Start with GitHub Copilot:")
        console.print("     [cyan]Open Copilot Chat → /socrate.outline[/cyan]\n")
    elif ai_type == "claude":
        console.print(f"  [bold]{step_num + 1}.[/bold] Start with Claude Code:")
        console.print("     [cyan]Open Command Palette → Run /socrate.outline[/cyan]\n")
    elif ai_type == "both":
        # Hidden CLI option for installing both (backward compatibility)
        console.print(f"  [bold]{step_num + 1}.[/bold] Start learning workflow:")
        console.print("     [cyan]GitHub Copilot: Copilot Chat → /socrate.outline[/cyan]")
        console.print("     [cyan]Claude Code: Command Palette → /socrate.outline[/cyan]\n")
    
    console.print(f"  [bold]{step_num + 2}.[/bold] Try the complete flow:")
    console.print("     [dim]/socrate.outline → /socrate.prepare → /socrate.practice → /socrate.lesson[/dim]\n")
    
    console.print("[dim]Need help? Check README.md for detailed guide[/dim]\n")
