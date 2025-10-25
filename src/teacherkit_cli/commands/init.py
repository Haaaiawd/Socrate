# init.py
"""teacherkit init command: Initialize new teaching project"""

from pathlib import Path
from typing import Optional

import typer
from rich.console import Console

from ..utils.git import check_git_installed, init_repository
from ..utils.template import copy_templates_to_project, copy_prompts_to_project
from ..utils.progress import track_steps, print_success, print_error, print_warning, confirm


console = Console(legacy_windows=True)  # Enable Windows PowerShell compatibility


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
    
    console.print(f"\n[bold]Initializing TeacherKit project at:[/bold] {target_dir}\n")
    
    # Check if project already exists
    specify_dir = target_dir / ".specify"
    if specify_dir.exists() and not force:
        print_error("Project already initialized!")
        print_warning(f"Found existing .specify directory at {specify_dir}")
        
        if not confirm("Overwrite existing project?", default=False):
            console.print("\n[yellow]Initialization cancelled.[/yellow]")
            raise typer.Exit(1)
    
    try:
        with track_steps(7, "Setting up project") as tracker:
            # Step 1: Create directory structure
            tracker.update("Creating directories")
            _create_directory_structure(target_dir)
            
            # Step 2: Copy templates
            tracker.update("Copying templates")
            if not copy_templates_to_project(target_dir):
                raise Exception("Failed to copy templates")
            
            # Step 3: Copy VS Code prompts
            tracker.update("Copying prompts")
            if not copy_prompts_to_project(target_dir):
                raise Exception("Failed to copy prompts")
            
            # Step 4: Create data directories
            tracker.update("Setting up data storage")
            _create_data_directories(target_dir)
            
            # Step 5: Create config file
            tracker.update("Creating configuration")
            _create_config_file(target_dir)
            
            # Step 6: Initialize Git (optional)
            if not no_git:
                tracker.update("Initializing Git repository")
                _init_git_repository(target_dir)
            else:
                tracker.update("Skipping Git initialization")
            
            # Step 7: Create welcome message
            tracker.update("Finalizing setup")
        
        # Success message
        console.print("\n[bold green]✓ Project initialized successfully![/bold green]\n")
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
        "data/textbooks",
        "data/outlines",
        "data/chapters",
        "data/progress",
        "logs"
    ]
    
    for dir_path in directories:
        full_path = project_dir / dir_path
        full_path.mkdir(parents=True, exist_ok=True)


def _create_data_directories(project_dir: Path):
    """Create data storage directories with README files"""
    data_dirs = {
        "data/textbooks": "Place textbook source files (.md or .txt) here",
        "data/outlines": "Generated outlines will be saved here",
        "data/chapters": "Prepared chapter materials will be saved here",
        "data/progress": "Student learning progress files will be saved here"
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
        print_warning("Git not found - skipping repository initialization")
        return
    
    repo = init_repository(project_dir, initial_commit=False)
    
    if repo:
        # Stage all created files
        repo.index.add([".specify", ".github", "data", "logs"])
        
        # Create initial commit
        repo.index.commit("chore: initialize TeacherKit project\n\nCreated by `teacherkit init`")
        print_success("Git repository initialized")
    else:
        print_warning("Git initialization failed")


def _print_next_steps(project_dir: Path):
    """Print next steps for user"""
    project_name = project_dir.name
    is_current_dir = project_dir.resolve() == Path.cwd().resolve()
    
    console.print("[bold]Next steps:[/bold]\n")
    
    if not is_current_dir:
        console.print(f"1. Navigate to project:")
        console.print(f"   [cyan]cd {project_name}[/cyan]\n")
        step_num = 2
    else:
        step_num = 1
    
    console.print(f"{step_num}. Add a textbook:")
    console.print(f"   [cyan]Copy your textbook file to data/textbooks/[/cyan]\n")
    console.print(f"{step_num + 1}. Register the textbook:")
    console.print("   [cyan]teacherkit config add-textbook data/textbooks/your-textbook.md[/cyan]\n")
    console.print(f"{step_num + 2}. Parse the textbook (in VS Code):")
    console.print("   [cyan]Open Command Palette and run: /teacherkit.parse[/cyan]\n")
    console.print(f"{step_num + 3}. Start teaching:")
    console.print("   [cyan]Open Command Palette and run: /teacherkit.lesson[/cyan]\n")
