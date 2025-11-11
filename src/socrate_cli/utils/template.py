# template.py
"""Template management: download from GitHub and copy to project"""

import shutil
from pathlib import Path
from typing import Optional


def get_bundled_templates_path() -> Path:
    """Get path to bundled templates in package"""
    # Templates are bundled with the package at .specify/templates/
    package_root = Path(__file__).parent.parent.parent.parent
    templates_dir = package_root / ".specify" / "templates"
    return templates_dir


def copy_templates_to_project(project_dir: Path) -> bool:
    """
    Copy template files to project .specify/templates/ directory

    Only copies user-facing templates, excludes spec-kit workflow templates.

    Args:
        project_dir: Project root directory

    Returns:
        True if successful
    """
    try:
        source_dir = get_bundled_templates_path()
        target_dir = project_dir / ".specify" / "templates"

        # Create target directory
        target_dir.mkdir(parents=True, exist_ok=True)

        # Whitelist: only copy user project templates
        allowed_templates = {
            "chapter-template.md",  # legacy
            "outline-template.md",
            "progress-template.md",
            "ipynb-template.ipynb"  # legacy practice template
        }

        # Copy filtered template files
        if source_dir.exists():
            for template_file in source_dir.iterdir():
                if template_file.name in allowed_templates:
                    target_file = target_dir / template_file.name
                    shutil.copy2(template_file, target_file)
        else:
            print(f"Warning: Template directory not found at {source_dir}")
            return False

        return True

    except Exception as e:
        print(f"Error copying templates: {e}")
        return False


def get_template_path(project_dir: Path, template_name: str) -> Optional[Path]:
    """
    Get path to a specific template file

    Args:
        project_dir: Project root directory
        template_name: Template filename (e.g., "outline-template.md")

    Returns:
        Path to template file if exists, None otherwise
    """
    template_path = project_dir / ".specify" / "templates" / template_name
    return template_path if template_path.exists() else None


def list_templates(project_dir: Path) -> list[str]:
    """List all available template files in project"""
    templates_dir = project_dir / ".specify" / "templates"

    if not templates_dir.exists():
        return []

    return [f.name for f in templates_dir.glob("*.md")]


def ensure_templates_exist(project_dir: Path) -> bool:
    """
    Ensure templates directory exists and has required templates

    Args:
        project_dir: Project root directory

    Returns:
        True if templates are available
    """
    required_templates = [
        "outline-template.md",
        "chapter-template.md",
        "progress-template.md",
        "teaching-prompt-template.md"
    ]

    templates_dir = project_dir / ".specify" / "templates"

    if not templates_dir.exists():
        return copy_templates_to_project(project_dir)

    # Check if all required templates exist
    missing = [t for t in required_templates if not (templates_dir / t).exists()]

    if missing:
        print(f"Missing templates: {', '.join(missing)}")
        return copy_templates_to_project(project_dir)

    return True


def copy_prompts_to_project(project_dir: Path) -> bool:
    """
    Copy Socrate prompt files to project .github/prompts/ directory

    Args:
        project_dir: Project root directory

    Returns:
        True if successful
    """
    try:
        # Source prompts from package .github/prompts/ (development repo)
        package_root = Path(__file__).parent.parent.parent.parent
        source_dir = package_root / ".github" / "prompts"
        target_dir = project_dir / ".github" / "prompts"

        # Create target directory
        target_dir.mkdir(parents=True, exist_ok=True)

        # Copy Socrate prompt files
        if source_dir.exists():
            for prompt_file in source_dir.glob("socrate.*.prompt.md"):
                target_file = target_dir / prompt_file.name
                shutil.copy2(prompt_file, target_file)
        else:
            print(f"Warning: Prompts directory not found at {source_dir}")
            return False

        return True

    except Exception as e:
        print(f"Error copying prompts: {e}")
        return False


def copy_scripts_to_project(project_dir: Path) -> bool:
    """
    Copy PowerShell automation scripts to project .specify/scripts/powershell/ directory

    Args:
        project_dir: Project root directory

    Returns:
        True if successful
    """
    try:
        # Source scripts from package .specify/scripts/powershell/
        package_root = Path(__file__).parent.parent.parent.parent
        source_dir = package_root / ".specify" / "scripts" / "powershell"
        target_dir = project_dir / ".specify" / "scripts" / "powershell"

        # Create target directory
        target_dir.mkdir(parents=True, exist_ok=True)

        # Core automation scripts that AI uses
        required_scripts = [
            "Generate-Outline.ps1",
            "Prepare-Lessons.ps1",  # UbD scaffold
            "Prepare-Chapters.ps1",  # legacy (deprecated)
            "Generate-Practice.ps1",  # deprecated
            "Copy-Chapter-Template.ps1",  # deprecated
            "Update-Progress.ps1"
        ]

        # Copy scripts
        if source_dir.exists():
            for script_name in required_scripts:
                source_file = source_dir / script_name
                if source_file.exists():
                    target_file = target_dir / script_name
                    shutil.copy2(source_file, target_file)
        else:
            print(f"Warning: Scripts directory not found at {source_dir}")
            return False

        return True

    except Exception as e:
        print(f"Error copying scripts: {e}")
        return False


def copy_claude_commands_to_project(project_dir: Path) -> bool:
    """
    Copy Claude Code command files to project .claude/commands/ directory

    Args:
        project_dir: Project root directory

    Returns:
        True if successful
    """
    try:
        # Source commands from package .claude/commands/
        package_root = Path(__file__).parent.parent.parent.parent
        source_dir = package_root / ".claude" / "commands"
        target_dir = project_dir / ".claude" / "commands"

        # Create target directory
        target_dir.mkdir(parents=True, exist_ok=True)

        # Copy Socrate command files
        if source_dir.exists():
            for command_file in source_dir.glob("socrate.*.md"):
                target_file = target_dir / command_file.name
                shutil.copy2(command_file, target_file)
        else:
            print(f"Warning: Claude commands directory not found at {source_dir}")
            return False

        return True

    except Exception as e:
        print(f"Error copying Claude commands: {e}")
        return False
