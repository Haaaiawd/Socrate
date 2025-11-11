# config.py
"""socrate config command: Manage project configuration"""

from pathlib import Path
from typing import Optional

import typer
import yaml
from rich.console import Console
from rich.table import Table

from ..utils.progress import print_error, print_info, print_success, print_warning

console = Console()
app = typer.Typer(help="Manage Socrate configuration")


@app.command("show")
def show_config(
    project_dir: Optional[str] = typer.Option(
        None,
        "--dir",
        "-d",
        help="Project directory (default: current directory)"
    )
):
    """Display current configuration"""
    target_dir = Path(project_dir) if project_dir else Path.cwd()
    config_path = target_dir / ".specify" / "config.yaml"

    if not config_path.exists():
        print_error(f"Configuration not found at {config_path}")
        print_info("Run 'socrate init' to initialize project")
        raise typer.Exit(1)

    try:
        with open(config_path, encoding="utf-8") as f:
            config = yaml.safe_load(f)

        console.print(f"\n[bold]Configuration:[/bold] {config_path}\n")

        # Display config sections
        _display_config_section("Model Settings", config.get("model", {}))
        _display_config_section("Teaching Settings", config.get("teaching", {}))
        _display_config_section("Data Paths", config.get("paths", {}))
        _display_config_section("Logging", config.get("logging", {}))

    except Exception as e:
        print_error(f"Failed to read configuration: {e}")
        raise typer.Exit(1)


@app.command("set")
def set_config_value(
    key: str = typer.Argument(..., help="Configuration key (e.g., model.name)"),
    value: str = typer.Argument(..., help="Value to set"),
    project_dir: Optional[str] = typer.Option(
        None,
        "--dir",
        "-d",
        help="Project directory"
    )
):
    """Set a configuration value"""
    target_dir = Path(project_dir) if project_dir else Path.cwd()
    config_path = target_dir / ".specify" / "config.yaml"

    if not config_path.exists():
        print_error("Configuration not found")
        raise typer.Exit(1)

    try:
        with open(config_path, encoding="utf-8") as f:
            config = yaml.safe_load(f) or {}

        # Parse nested key (e.g., "model.name" -> ["model", "name"])
        keys = key.split(".")

        # Navigate to nested dict
        current = config
        for k in keys[:-1]:
            if k not in current:
                current[k] = {}
            current = current[k]

        # Convert value type
        typed_value = _convert_value_type(value)

        # Set value
        current[keys[-1]] = typed_value

        # Write back
        with open(config_path, "w", encoding="utf-8") as f:
            yaml.dump(config, f, default_flow_style=False, allow_unicode=True)

        print_success(f"Set {key} = {typed_value}")

    except Exception as e:
        print_error(f"Failed to set configuration: {e}")
        raise typer.Exit(1)


@app.command("add-textbook")
def add_textbook(
    textbook_path: str = typer.Argument(..., help="Path to textbook file"),
    name: Optional[str] = typer.Option(
        None,
        "--name",
        "-n",
        help="Textbook display name (default: filename)"
    ),
    project_dir: Optional[str] = typer.Option(
        None,
        "--dir",
        "-d",
        help="Project directory"
    )
):
    """Register a textbook for teaching"""
    target_dir = Path(project_dir) if project_dir else Path.cwd()
    config_path = target_dir / ".specify" / "config.yaml"

    if not config_path.exists():
        print_error("Configuration not found")
        raise typer.Exit(1)

    # Validate textbook path
    textbook_file = Path(textbook_path)
    if not textbook_file.exists():
        print_error(f"Textbook file not found: {textbook_path}")
        raise typer.Exit(1)

    # Get relative path from project root
    try:
        relative_path = textbook_file.relative_to(target_dir)
    except ValueError:
        # File is outside project, use absolute path
        relative_path = textbook_file.absolute()

    try:
        with open(config_path, encoding="utf-8") as f:
            config = yaml.safe_load(f) or {}

        # Ensure textbooks section exists
        if "textbooks" not in config:
            config["textbooks"] = []

        # Create textbook entry
        textbook_name = name or textbook_file.stem
        textbook_entry = {
            "name": textbook_name,
            "path": str(relative_path),
            "registered_at": _get_current_timestamp()
        }

        # Check if already registered
        existing = next(
            (tb for tb in config["textbooks"] if tb["path"] == str(relative_path)),
            None
        )

        if existing:
            print_warning(f"Textbook already registered as '{existing['name']}'")
            raise typer.Exit(0)

        # Add textbook
        config["textbooks"].append(textbook_entry)

        # Write back
        with open(config_path, "w", encoding="utf-8") as f:
            yaml.dump(config, f, default_flow_style=False, allow_unicode=True)

        print_success(f"Registered textbook: {textbook_name}")
        print_info(f"Path: {relative_path}")

    except Exception as e:
        print_error(f"Failed to register textbook: {e}")
        raise typer.Exit(1)


@app.command("list-textbooks")
def list_textbooks(
    project_dir: Optional[str] = typer.Option(
        None,
        "--dir",
        "-d",
        help="Project directory"
    )
):
    """List all registered textbooks"""
    target_dir = Path(project_dir) if project_dir else Path.cwd()
    config_path = target_dir / ".specify" / "config.yaml"

    if not config_path.exists():
        print_error("Configuration not found")
        raise typer.Exit(1)

    try:
        with open(config_path, encoding="utf-8") as f:
            config = yaml.safe_load(f) or {}

        textbooks = config.get("textbooks", [])

        if not textbooks:
            print_warning("No textbooks registered")
            print_info("Use 'socrate config add-textbook' to register a textbook")
            return

        # Create table
        table = Table(title="Registered Textbooks")
        table.add_column("Name", style="cyan")
        table.add_column("Path", style="green")
        table.add_column("Registered", style="yellow")

        for tb in textbooks:
            table.add_row(
                tb.get("name", ""),
                tb.get("path", ""),
                tb.get("registered_at", "")
            )

        console.print()
        console.print(table)
        console.print()

    except Exception as e:
        print_error(f"Failed to list textbooks: {e}")
        raise typer.Exit(1)


def _display_config_section(title: str, data: dict) -> None:
    """Display a configuration section"""
    console.print(f"[bold]{title}:[/bold]")
    for key, value in data.items():
        console.print(f"  {key}: [cyan]{value}[/cyan]")
    console.print()


def _convert_value_type(value: str):
    """Convert string value to appropriate type"""
    # Boolean
    if value.lower() in ("true", "yes"):
        return True
    if value.lower() in ("false", "no"):
        return False

    # Number
    try:
        if "." in value:
            return float(value)
        return int(value)
    except ValueError:
        pass

    # String (default)
    return value


def _get_current_timestamp() -> str:
    """Get current timestamp in ISO format"""
    from datetime import datetime
    return datetime.now().isoformat(timespec="seconds")
