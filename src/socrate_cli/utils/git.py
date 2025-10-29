# git.py
"""Git operations wrapper using gitpython"""

import subprocess
from pathlib import Path
from typing import Optional

from git import Repo, InvalidGitRepositoryError
from git.exc import GitCommandError


def check_git_installed() -> bool:
    """Check if Git is installed and accessible"""
    try:
        subprocess.run(
            ["git", "--version"],
            capture_output=True,
            check=True,
            text=True
        )
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False


def init_repository(project_dir: Path, initial_commit: bool = True) -> Optional[Repo]:
    """
    Initialize Git repository in project directory
    
    Args:
        project_dir: Project root directory
        initial_commit: Whether to create initial commit
        
    Returns:
        Repo object if successful, None otherwise
    """
    try:
        # Check if already a git repo
        try:
            repo = Repo(project_dir)
            return repo
        except InvalidGitRepositoryError:
            pass
        
        # Initialize new repo
        repo = Repo.init(project_dir)
        
        if initial_commit:
            # Add .gitignore first
            gitignore_path = project_dir / ".gitignore"
            if gitignore_path.exists():
                repo.index.add([".gitignore"])
            
            # Create initial commit
            repo.index.commit("chore: initialize Socrate project")
        
        return repo
    
    except GitCommandError as e:
        print(f"Git error: {e}")
        return None
    except Exception as e:
        print(f"Failed to initialize repository: {e}")
        return None


def is_git_repository(path: Path) -> bool:
    """Check if path is inside a Git repository"""
    try:
        Repo(path, search_parent_directories=True)
        return True
    except InvalidGitRepositoryError:
        return False


def get_repository(path: Path) -> Optional[Repo]:
    """Get Repo object for path"""
    try:
        return Repo(path, search_parent_directories=True)
    except InvalidGitRepositoryError:
        return None
