"""
Socrate CLI - AI-powered Socratic teaching system

Entry point for the socrate command-line interface.
"""

from typing import Optional

import typer
from rich.console import Console
from rich.panel import Panel

from .commands import config, init, update

app = typer.Typer(
    name="socrate",
    help="AI-powered Socratic teaching system for interactive learning",
    add_completion=False,
    rich_markup_mode="rich",
)

# Register commands
app.command(name="init")(init.init_command)
app.command(name="update")(update.update_command)
app.add_typer(config.app, name="config")

console = Console(legacy_windows=True)  # Enable Windows PowerShell compatibility

__version__ = "0.2.0"


def version_callback(value: bool) -> None:
    """Display version and exit."""
    if value:
        console.print(f"[bold cyan]Socrate[/bold cyan] version [bold]{__version__}[/bold]")
        raise typer.Exit()


@app.callback()
def main(
    version: Optional[bool] = typer.Option(
        None,
        "--version",
        "-V",
        help="Show version and exit",
        callback=version_callback,
        is_eager=True,
    ),
) -> None:
    """
    Socrate - AI-powered Socratic teaching system

    Initialize learning repositories and guide students through
    interactive AI-powered Socratic dialogues.
    """
    pass


def cli_main() -> None:
    """Main entry point for the CLI."""
    try:
        app()
    except KeyboardInterrupt:
        console.print("\n[yellow]Operation cancelled by user[/yellow]")
        raise typer.Exit(130)
    except Exception as e:
        console.print(f"[bold red]Error:[/bold red] {str(e)}")
        raise typer.Exit(1)


if __name__ == "__main__":
    cli_main()
