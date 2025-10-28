# init.py
"""teacherkit init command: Initialize new teaching project"""

from pathlib import Path
from typing import Optional

import typer
from rich.console import Console
from rich.panel import Panel
from rich.text import Text
from rich.align import Align

from ..utils.git import check_git_installed, init_repository
from ..utils.template import copy_templates_to_project, copy_prompts_to_project, copy_scripts_to_project
from ..utils.progress import track_steps, print_success, print_error, print_warning, confirm


console = Console(legacy_windows=True)  # Enable Windows PowerShell compatibility


def _print_logo():
    """Print TeacherKit ASCII logo"""
    logo = r"""
    ╔════════════════════════════════════════════════════╗
    ║                                                    ║
    ║   ████████╗███████╗ █████╗  ██████╗██╗  ██╗       ║
    ║   ╚══██╔══╝██╔════╝██╔══██╗██╔════╝██║  ██║       ║
    ║      ██║   █████╗  ███████║██║     ███████║       ║
    ║      ██║   ██╔══╝  ██╔══██║██║     ██╔══██║       ║
    ║      ██║   ███████╗██║  ██║╚██████╗██║  ██║       ║
    ║      ╚═╝   ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝       ║
    ║                                                    ║
    ║   ██╗  ██╗██╗████████╗                            ║
    ║   ██║ ██╔╝██║╚══██╔══╝                            ║
    ║   █████╔╝ ██║   ██║                               ║
    ║   ██╔═██╗ ██║   ██║                               ║
    ║   ██║  ██╗██║   ██║                               ║
    ║   ╚═╝  ╚═╝╚═╝   ╚═╝                               ║
    ║                                                    ║
    ║        AI-Powered Socratic Teaching System        ║
    ║                   Version 0.1.0                   ║
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
    )
):
    """
    Initialize a new TeacherKit teaching project
    
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
    
    try:
        # Step 1: Create directory structure
        console.print("  [bold blue]📁 Creating directories...[/bold blue]", end=" ")
        _create_directory_structure(target_dir)
        console.print("[green]✓[/green]")
        
        # Step 2: Copy templates
        console.print("  [bold blue]📄 Copying templates...[/bold blue]", end=" ")
        if not copy_templates_to_project(target_dir):
            raise Exception("Failed to copy templates")
        console.print("[green]✓[/green] [dim](4 files)[/dim]")
        
        # Step 3: Copy VS Code prompts
        console.print("  [bold blue]💬 Copying prompts...[/bold blue]", end=" ")
        if not copy_prompts_to_project(target_dir):
            raise Exception("Failed to copy prompts")
        console.print("[green]✓[/green] [dim](5 files)[/dim]")
        
        # Step 4: Copy PowerShell scripts
        console.print("  [bold blue]⚙️  Copying automation scripts...[/bold blue]", end=" ")
        if not copy_scripts_to_project(target_dir):
            raise Exception("Failed to copy scripts")
        console.print("[green]✓[/green] [dim](6 files)[/dim]")
        
        # Step 5: Create data directories
        console.print("  [bold blue]🗂️  Setting up data storage...[/bold blue]", end=" ")
        _create_data_directories(target_dir)
        console.print("[green]✓[/green]")
        
        # Step 6: Create config file
        console.print("  [bold blue]⚙️  Creating configuration...[/bold blue]", end=" ")
        _create_config_file(target_dir)
        console.print("[green]✓[/green]")
        
        # Step 7: Initialize Git (optional)
        if not no_git:
            console.print("  [bold blue]🔧 Initializing Git repository...[/bold blue]", end=" ")
            _init_git_repository(target_dir)
        else:
            console.print("  [dim]⏭️  Skipping Git initialization[/dim]")
        
        console.print()  # Empty line
        
        # Success banner
        success_banner = """
    ╔═══════════════════════════════════════╗
    ║  ✨  Setup Complete Successfully!  ✨  ║
    ╚═══════════════════════════════════════╝
        """
        console.print(success_banner, style="bold green")
        console.print()  # Empty line
        _print_next_steps(target_dir)
    
    except Exception as e:
        print_error(f"Initialization failed: {e}")
        raise typer.Exit(1)


def _create_directory_structure(project_dir: Path):
    """Create core project directories"""
    directories = [
        ".specify/scripts/powershell",
        ".specify/templates",
        ".github/prompts",
        "data/outlines",
        "data/chapters",
        "data/exercises",
        "data/progress",
        "logs"
    ]
    
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


def _create_config_file(project_dir: Path):
    """Create default configuration file"""
    config_path = project_dir / ".specify" / "config.yaml"
    
    if config_path.exists():
        return  # Don't overwrite existing config
    
    default_config = """# TeacherKit Configuration

# AI Model Settings
model:
  provider: openai  # or: azure, anthropic, local
  name: gpt-4  # Model name
  temperature: 0.7  # Response creativity (0.0-1.0)
  max_tokens: 2000  # Maximum response length

# Teaching Style
teaching:
  style: socratic  # Question-driven teaching approach
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
  file: logs/teacherkit.log
"""
    
    config_path.write_text(default_config, encoding="utf-8")


def _init_git_repository(project_dir: Path):
    """Initialize Git repository with initial commit"""
    if not check_git_installed():
        console.print("[yellow]✗[/yellow] [dim](Git not found)[/dim]")
        return
    
    repo = init_repository(project_dir, initial_commit=False)
    
    if repo:
        # Stage all created files
        repo.index.add([".specify", ".github", "data", "logs"])
        
        # Create initial commit
        repo.index.commit("chore: initialize TeacherKit project\n\nCreated by `teacherkit init`")
        console.print("[green]✓[/green]")
    else:
        console.print("[yellow]✗[/yellow] [dim](failed)[/dim]")


def _print_next_steps(project_dir: Path):
    """Print next steps for user"""
    project_name = project_dir.name
    is_current_dir = project_dir.resolve() == Path.cwd().resolve()
    
    console.print("[bold cyan]📚 Next Steps:[/bold cyan]\n")
    
    if not is_current_dir:
        console.print("  [bold]1.[/bold] Navigate to project:")
        console.print(f"     [cyan]cd {project_name}[/cyan]\n")
        step_num = 2
    else:
        step_num = 1
    
    console.print(f"  [bold]{step_num}.[/bold] Open in VS Code:")
    console.print(f"     [cyan]code .[/cyan]\n")
    
    console.print(f"  [bold]{step_num + 1}.[/bold] Start learning workflow:")
    console.print("     [cyan]Open Copilot Chat → /teacherkit.outline[/cyan]\n")
    
    console.print(f"  [bold]{step_num + 2}.[/bold] Try the complete flow:")
    console.print("     [dim]/teacherkit.outline → /teacherkit.prepare → /teacherkit.practice → /teacherkit.lesson[/dim]\n")
    
    console.print("[dim]📖 Need help? Check README.md for detailed guide[/dim]\n")
