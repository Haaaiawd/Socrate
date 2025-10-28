# update.py
"""teacherkit update command: Update project prompts and scripts"""

from pathlib import Path
from typing import Optional

import typer
from rich.console import Console

from ..utils.git import check_git_installed
from ..utils.template import copy_templates_to_project, copy_prompts_to_project, copy_scripts_to_project
from ..utils.progress import print_success, print_error, print_warning, confirm


console = Console(legacy_windows=True)


def update_command(
    project_path: Optional[str] = typer.Argument(
        None,
        help="Project directory to update (default: current directory)"
    ),
    prompts_only: bool = typer.Option(
        False,
        "--prompts-only",
        help="Only update prompts, skip templates and scripts"
    ),
    scripts_only: bool = typer.Option(
        False,
        "--scripts-only",
        help="Only update scripts, skip prompts and templates"
    ),
    force: bool = typer.Option(
        False,
        "--force",
        "-f",
        help="Force update without confirmation"
    ),
    backup: bool = typer.Option(
        True,
        "--backup/--no-backup",
        help="Create backup before updating (default: yes)"
    )
):
    """
    Update teacherkit project with latest prompts and scripts
    
    Use this when teacherkit is upgraded and you want to sync your
    existing project with new features.
    
    Examples:
        teacherkit update my-project
        teacherkit update --prompts-only
        teacherkit update --force --no-backup
    """
    # Determine target directory
    if project_path:
        target_dir = Path(project_path).resolve()
    else:
        target_dir = Path.cwd()
    
    # Validate project exists
    specify_dir = target_dir / ".specify"
    if not specify_dir.exists():
        print_error(f"Not a teacherkit project: {target_dir}")
        console.print("\n[yellow]💡 Hint:[/yellow] Run [cyan]teacherkit init[/cyan] first.\n")
        raise typer.Exit(1)
    
    console.print(f"\n[bold cyan]🔄 Updating TeacherKit Project[/bold cyan]")
    console.print(f"[dim]Target:[/dim] {target_dir}\n")
    
    # Check git status (warn if uncommitted changes)
    if check_git_installed() and (target_dir / ".git").exists():
        import subprocess
        result = subprocess.run(
            ["git", "status", "--porcelain"],
            cwd=target_dir,
            capture_output=True,
            text=True
        )
        if result.stdout.strip():
            print_warning("Uncommitted changes detected in project")
            console.print("[dim]Consider committing your work before updating.[/dim]\n")
            if not force and not confirm("Continue anyway?", default=False):
                console.print("[yellow]Update cancelled.[/yellow]\n")
                raise typer.Exit(1)
    
    # Confirm update
    if not force:
        console.print("[bold]This will update:[/bold]")
        if not prompts_only and not scripts_only:
            console.print("  • Prompts (.github/prompts/)")
            console.print("  • Scripts (.specify/scripts/)")
            console.print("  • Templates (.specify/templates/)")
        elif prompts_only:
            console.print("  • Prompts (.github/prompts/)")
        elif scripts_only:
            console.print("  • Scripts (.specify/scripts/)")
        console.print()
        
        if not confirm("Proceed with update?", default=True):
            console.print("[yellow]Update cancelled.[/yellow]\n")
            raise typer.Exit(1)
    
    # Backup (if enabled)
    if backup:
        _create_backup(target_dir)
    
    # Perform update
    try:
        updated_count = 0
        
        if not scripts_only:
            # Update prompts
            console.print("  [bold blue]💬 Updating prompts...[/bold blue]", end=" ")
            if copy_prompts_to_project(target_dir):
                console.print("[green]✓[/green]")
                updated_count += 1
            else:
                console.print("[red]✗[/red]")
        
        if not prompts_only:
            # Update scripts
            console.print("  [bold blue]⚙️  Updating scripts...[/bold blue]", end=" ")
            if copy_scripts_to_project(target_dir):
                console.print("[green]✓[/green]")
                updated_count += 1
            else:
                console.print("[red]✗[/red]")
            
            # Update templates
            console.print("  [bold blue]📄 Updating templates...[/bold blue]", end=" ")
            if copy_templates_to_project(target_dir):
                console.print("[green]✓[/green]")
                updated_count += 1
            else:
                console.print("[red]✗[/red]")
        
        console.print()
        
        if updated_count > 0:
            success_banner = """
    ╔═══════════════════════════════════════╗
    ║  ✨  Update Complete Successfully!  ✨  ║
    ╚═══════════════════════════════════════╝
            """
            console.print(success_banner, style="bold green")
            
            console.print("[bold cyan]📝 What's New:[/bold cyan]\n")
            console.print("  Check the updated files for new features.")
            console.print("  Your data/ directory and progress are preserved.\n")
            
            if backup:
                console.print("[dim]💾 Backup created in .specify/backups/[/dim]\n")
        else:
            print_error("Update failed")
            raise typer.Exit(1)
    
    except Exception as e:
        print_error(f"Update failed: {e}")
        if backup:
            console.print("\n[yellow]💡 Restore from backup:[/yellow]")
            console.print("   [cyan]cd .specify/backups/[/cyan]\n")
        raise typer.Exit(1)


def _create_backup(project_dir: Path):
    """Create timestamped backup of critical files"""
    import shutil
    from datetime import datetime
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_dir = project_dir / ".specify" / "backups" / timestamp
    backup_dir.mkdir(parents=True, exist_ok=True)
    
    # Backup prompts
    prompts_src = project_dir / ".github" / "prompts"
    if prompts_src.exists():
        prompts_dst = backup_dir / "prompts"
        shutil.copytree(prompts_src, prompts_dst, dirs_exist_ok=True)
    
    # Backup scripts
    scripts_src = project_dir / ".specify" / "scripts"
    if scripts_src.exists():
        scripts_dst = backup_dir / "scripts"
        shutil.copytree(scripts_src, scripts_dst, dirs_exist_ok=True)
    
    # Backup templates
    templates_src = project_dir / ".specify" / "templates"
    if templates_src.exists():
        templates_dst = backup_dir / "templates"
        shutil.copytree(templates_src, templates_dst, dirs_exist_ok=True)
    
    console.print(f"  [dim]💾 Backup created: .specify/backups/{timestamp}/[/dim]")
