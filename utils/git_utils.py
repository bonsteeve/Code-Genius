"""
Git utilities for cloning and managing GitHub repositories.
"""

import os
import shutil
import tempfile
from pathlib import Path
from typing import Optional, Tuple
from git import Repo, GitCommandError
from urllib.parse import urlparse


def validate_github_url(url: str) -> bool:
    """
    Validate if the URL is a valid GitHub repository URL.
    
    Args:
        url: Repository URL to validate
        
    Returns:
        True if valid, False otherwise
    """
    try:
        parsed = urlparse(url)
        return parsed.netloc in ['github.com', 'www.github.com'] and parsed.path.count('/') >= 2
    except Exception:
        return False


def clone_repository(repo_url: str, target_dir: Optional[str] = None) -> Tuple[str, bool]:
    """
    Clone a GitHub repository to a temporary or specified directory.
    
    Args:
        repo_url: GitHub repository URL
        target_dir: Target directory (if None, uses temp directory)
        
    Returns:
        Tuple of (directory_path, success_status)
    """
    if not validate_github_url(repo_url):
        return "", False
    
    try:
        if target_dir is None:
            # Create temporary directory
            temp_dir = tempfile.mkdtemp(prefix="codegenius_")
            target_dir = temp_dir
        
        # Clone repository
        repo = Repo.clone_from(repo_url, target_dir)
        
        return target_dir, True
    except GitCommandError as e:
        print(f"Error cloning repository: {e}")
        return "", False
    except Exception as e:
        print(f"Unexpected error: {e}")
        return "", False


def cleanup_temp_directory(directory: str) -> bool:
    """
    Remove a temporary directory.
    
    Args:
        directory: Directory path to remove
        
    Returns:
        True if successful, False otherwise
    """
    try:
        if os.path.exists(directory):
            shutil.rmtree(directory)
        return True
    except Exception as e:
        print(f"Error cleaning up directory: {e}")
        return False


def get_repository_name(repo_url: str) -> str:
    """
    Extract repository name from GitHub URL.
    
    Args:
        repo_url: GitHub repository URL
        
    Returns:
        Repository name
    """
    try:
        parsed = urlparse(repo_url)
        path_parts = parsed.path.strip('/').split('/')
        if len(path_parts) >= 2:
            return path_parts[-1].replace('.git', '')
        return "unknown"
    except Exception:
        return "unknown"

