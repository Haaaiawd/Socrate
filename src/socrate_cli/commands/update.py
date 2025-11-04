# update.py
"""socrate update command: Update project prompts and scripts"""

from pathlib import Path
from typing import Optional

import typer
from rich.console import Console

from ..utils.git import check_git_installed
from ..utils.template import (
    copy_templates_to_project,
    copy_prompts_to_project,
    copy_scripts_to_project,
    copy_claude_commands_to_project
)
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
        help="Only update GitHub Copilot prompts"
    ),
    claude_only: bool = typer.Option(
        False,
        "--claude-only",
        help="Only update Claude Code commands"
    ),
    scripts_only: bool = typer.Option(
        False,
        "--scripts-only",
        help="Only update automation scripts"
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
    Update Socrate project with latest prompts and scripts
    
    Use this when Socrate is upgraded and you want to sync your
    existing project with new features.
    
    Examples:
        socrate update my-project
        socrate update --prompts-only
        socrate update --force --no-backup
    """
    # Determine target directory
    if project_path:
        target_dir = Path(project_path).resolve()
    else:
        target_dir = Path.cwd()
    
    # Validate project exists
    specify_dir = target_dir / ".specify"
    if not specify_dir.exists():
        print_error(f"Not a Socrate project: {target_dir}")
        console.print("\n[yellow]💡 Hint:[/yellow] Run [cyan]socrate init[/cyan] first.\n")
        raise typer.Exit(1)
    
    console.print(f"\n[bold cyan]🔄 Updating Socrate Project[/bold cyan]")
    console.print(f"[dim]Target:[/dim] {target_dir}\n")
    
    # Detect existing AI installations
    has_copilot = (target_dir / ".github" / "prompts").exists()
    has_claude = (target_dir / ".claude" / "commands").exists()
    
    # Validate exclusive options
    exclusive_count = sum([prompts_only, claude_only, scripts_only])
    if exclusive_count > 1:
        print_error("Cannot use --prompts-only, --claude-only, and --scripts-only together")
        raise typer.Exit(1)
    
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
        if not scripts_only and not claude_only:
            if has_copilot or prompts_only:
                console.print("  • GitHub Copilot prompts (.github/prompts/)")
        if not scripts_only and not prompts_only:
            if has_claude or claude_only:
                console.print("  • Claude Code commands (.claude/commands/)")
        if not prompts_only and not claude_only:
            console.print("  • Automation scripts (.specify/scripts/)")
            console.print("  • Templates (.specify/templates/)")
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
        
        # Update GitHub Copilot prompts
        if not scripts_only and not claude_only:
            if has_copilot or prompts_only:
                console.print("  [bold blue]� Updating GitHub Copilot prompts...[/bold blue]", end=" ")
                if copy_prompts_to_project(target_dir):
                    console.print("[green]✓[/green]")
                    updated_count += 1
                else:
                    console.print("[red]✗[/red]")
        
        # Update Claude Code commands
        if not scripts_only and not prompts_only:
            if has_claude or claude_only:
                console.print("  [bold blue]🤖 Updating Claude Code commands...[/bold blue]", end=" ")
                if copy_claude_commands_to_project(target_dir):
                    console.print("[green]✓[/green]")
                    updated_count += 1
                else:
                    console.print("[red]✗[/red]")
        
        # Update scripts and templates
        if not prompts_only and not claude_only:
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
            
            # Update VS Code settings
            console.print("  [bold blue]🔧 Updating VS Code settings...[/bold blue]", end=" ")
            if _update_vscode_settings(target_dir):
                console.print("[green]✓[/green]")
                updated_count += 1
            else:
                console.print("[yellow]⏭️[/yellow] [dim](exists)[/dim]")
        
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
            console.print("  Your outlines/ and lessons/ directories are preserved.\n")
            
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


def _update_vscode_settings(project_dir: Path) -> bool:
    """Update or create VS Code settings.json with Copilot auto-approval"""
    import json
    
    vscode_dir = project_dir / ".vscode"
    settings_path = vscode_dir / "settings.json"
    
    # Ensure .vscode directory exists
    vscode_dir.mkdir(exist_ok=True)
    
    # If settings doesn't exist, create it
    if not settings_path.exists():
        vscode_settings = {
            "chat.promptFilesRecommendations": {
                "socrate.outline": True,
                "socrate.lesson": True,
                "socrate.check": True
            },
            "chat.tools.terminal.autoApprove": {
                ".specify/scripts/bash/": True,
                ".specify/scripts/powershell/": True
            }
        }
        settings_path.write_text(json.dumps(vscode_settings, indent=4), encoding="utf-8")
        return True
    
    # If exists, merge settings
    try:
        with open(settings_path, 'r', encoding='utf-8') as f:
            existing_settings = json.load(f)
        
        # Add Socrate prompt recommendations
        if "chat.promptFilesRecommendations" not in existing_settings:
            existing_settings["chat.promptFilesRecommendations"] = {}
        
        socrate_prompts = {
            "socrate.outline": True,
            "socrate.lesson": True,
            "socrate.check": True
        }
        existing_settings["chat.promptFilesRecommendations"].update(socrate_prompts)
        
        # Add auto-approve settings
        if "chat.tools.terminal.autoApprove" not in existing_settings:
            existing_settings["chat.tools.terminal.autoApprove"] = {}
        
        existing_settings["chat.tools.terminal.autoApprove"].update({
            ".specify/scripts/bash/": True,
            ".specify/scripts/powershell/": True
        })
        
        # Write back
        with open(settings_path, 'w', encoding='utf-8') as f:
            json.dump(existing_settings, f, indent=4)
        
        return True
    except Exception as e:
        console.print(f"[yellow]Warning: Failed to update settings.json: {e}[/yellow]")
        return False


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
