# progress.py
"""Progress tracking and display for CLI operations"""

import sys
import time
from contextlib import contextmanager
from typing import Optional

from rich.console import Console
from rich.progress import Progress, SpinnerColumn, TextColumn, BarColumn, TaskProgressColumn, TaskID, TimeElapsedColumn
from rich.panel import Panel
from rich.text import Text


console = Console()


class StepTracker:
    """Track and display multi-step operation progress"""
    
    def __init__(self, total_steps: int, description: str = "Processing"):
        """
        Initialize step tracker
        
        Args:
            total_steps: Total number of steps
            description: Overall operation description
        """
        self.total_steps = total_steps
        self.current_step = 0
        self.description = description
        self.progress: Optional[Progress] = None
        self.task_id: Optional[TaskID] = None
    
    def start(self):
        """Start progress tracking"""
        self.progress = Progress(
            SpinnerColumn(spinner_name="dots"),
            TextColumn("[bold blue]{task.description}[/bold blue]"),
            BarColumn(bar_width=40, complete_style="green", finished_style="bold green"),
            TaskProgressColumn(),
            TimeElapsedColumn(),
            console=console,
            expand=False
        )
        self.progress.start()
        self.task_id = self.progress.add_task(
            self.description,
            total=self.total_steps
        )
    
    def update(self, step_description: str, increment: int = 1):
        """
        Update progress with step completion
        
        Args:
            step_description: Description of completed step
            increment: Number of steps to increment (default: 1)
        """
        if self.progress and self.task_id is not None:
            self.current_step += increment
            # Show step completion with emoji
            emoji = "✨" if self.current_step == self.total_steps else "📦"
            self.progress.update(
                self.task_id,
                advance=increment,
                description=f"{emoji} {step_description}"
            )
            time.sleep(0.1)  # Brief animation pause
    
    def complete(self, final_message: Optional[str] = None):
        """
        Complete progress tracking
        
        Args:
            final_message: Optional final message to display
        """
        if self.progress:
            if self.task_id is not None:
                self.progress.update(
                    self.task_id,
                    completed=self.total_steps,
                    description=final_message or "✅ Setup complete!"
                )
            time.sleep(0.3)  # Brief pause to show completion
            self.progress.stop()
            
            # Show completion banner
            if not final_message:
                completion_text = Text()
                completion_text.append("🎉 ", style="bold yellow")
                completion_text.append("All steps completed successfully!", style="bold green")
                console.print(Panel(completion_text, border_style="green", expand=False))
    
    def error(self, error_message: str):
        """
        Stop progress with error message
        
        Args:
            error_message: Error description
        """
        if self.progress:
            self.progress.stop()
        console.print(f"[red]✗ {error_message}[/red]")


@contextmanager
def track_steps(total_steps: int, description: str = "Processing"):
    """
    Context manager for step tracking
    
    Usage:
        with track_steps(5, "Initializing project") as tracker:
            tracker.update("Creating directories")
            # ... do work ...
            tracker.update("Copying templates")
            # ... do work ...
    
    Args:
        total_steps: Total number of steps
        description: Operation description
        
    Yields:
        StepTracker instance
    """
    tracker = StepTracker(total_steps, description)
    tracker.start()
    try:
        yield tracker
        tracker.complete()
    except Exception as e:
        tracker.error(f"Failed: {str(e)}")
        raise


def print_success(message: str):
    """Print success message with checkmark"""
    console.print(f"[green]✓[/green] {message}")


def print_error(message: str):
    """Print error message with X mark"""
    console.print(f"[red]✗[/red] {message}")


def print_warning(message: str):
    """Print warning message"""
    console.print(f"[yellow]⚠[/yellow] {message}")


def print_info(message: str):
    """Print info message"""
    console.print(f"[blue]ℹ[/blue] {message}")


def confirm(prompt: str, default: bool = True) -> bool:
    """
    Ask user for yes/no confirmation
    
    Args:
        prompt: Confirmation prompt
        default: Default value if user just presses Enter
        
    Returns:
        True if user confirmed, False otherwise
    """
    choices = "[Y/n]" if default else "[y/N]"
    console.print(f"{prompt} {choices}: ", end="")
    
    try:
        response = input().strip().lower()
    except (KeyboardInterrupt, EOFError):
        console.print()
        return False
    
    if not response:
        return default
    
    return response in ('y', 'yes')
