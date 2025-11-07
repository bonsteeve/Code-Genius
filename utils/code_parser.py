"""
Code parsing utilities using Tree-sitter for Python and Jac code analysis.
"""

import os
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import tree_sitter_python as tspython
from tree_sitter import Language, Parser


# Initialize Tree-sitter parser for Python
PY_LANGUAGE = Language(tspython.language())
parser = Parser(PY_LANGUAGE)


def should_ignore_file(file_path: str) -> bool:
    """
    Check if a file should be ignored during parsing.
    
    Args:
        file_path: Path to the file
        
    Returns:
        True if file should be ignored
    """
    ignore_patterns = [
        '.git', '__pycache__', 'node_modules', '.venv', 'venv',
        '.pytest_cache', '.mypy_cache', '.idea', '.vscode',
        '*.pyc', '*.pyo', '*.pyd', '.DS_Store', 'Thumbs.db'
    ]
    
    file_path_lower = file_path.lower()
    for pattern in ignore_patterns:
        if pattern in file_path_lower:
            return True
    return False


def get_file_tree(directory: str, max_depth: int = 10, current_depth: int = 0) -> List[Dict]:
    """
    Generate a file tree structure for a directory.
    
    Args:
        directory: Root directory path
        max_depth: Maximum depth to traverse
        current_depth: Current depth level
        
    Returns:
        List of file/directory dictionaries
    """
    tree = []
    
    if current_depth >= max_depth:
        return tree
    
    try:
        for item in os.listdir(directory):
            item_path = os.path.join(directory, item)
            
            if should_ignore_file(item_path):
                continue
            
            item_info = {
                'name': item,
                'path': item_path,
                'type': 'directory' if os.path.isdir(item_path) else 'file',
                'children': []
            }
            
            if os.path.isdir(item_path):
                item_info['children'] = get_file_tree(
                    item_path, max_depth, current_depth + 1
                )
            
            tree.append(item_info)
    except PermissionError:
        pass
    
    return tree


def parse_python_file(file_path: str) -> Dict:
    """
    Parse a Python file and extract functions, classes, and imports.
    
    Args:
        file_path: Path to Python file
        
    Returns:
        Dictionary with parsed code information
    """
    result = {
        'file_path': file_path,
        'functions': [],
        'classes': [],
        'imports': [],
        'errors': []
    }
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            code = f.read()
        
        tree = parser.parse(bytes(code, 'utf8'))
        
        # Extract functions
        for node in tree.root_node.children:
            if node.type == 'function_definition':
                func_name = None
                for child in node.children:
                    if child.type == 'identifier':
                        func_name = code[child.start_byte:child.end_byte]
                        break
                
                if func_name:
                    result['functions'].append({
                        'name': func_name,
                        'line': node.start_point[0] + 1,
                        'code': code[node.start_byte:node.end_byte]
                    })
            
            elif node.type == 'class_definition':
                class_name = None
                for child in node.children:
                    if child.type == 'identifier':
                        class_name = code[child.start_byte:child.end_byte]
                        break
                
                if class_name:
                    result['classes'].append({
                        'name': class_name,
                        'line': node.start_point[0] + 1,
                        'code': code[node.start_byte:node.end_byte]
                    })
            
            elif node.type == 'import_statement' or node.type == 'import_from_statement':
                result['imports'].append({
                    'line': node.start_point[0] + 1,
                    'code': code[node.start_byte:node.end_byte]
                })
    
    except Exception as e:
        result['errors'].append(str(e))
    
    return result


def analyze_codebase(directory: str) -> Dict:
    """
    Analyze an entire codebase and extract code structure.
    
    Args:
        directory: Root directory of the codebase
        
    Returns:
        Dictionary with codebase analysis
    """
    analysis = {
        'file_tree': get_file_tree(directory),
        'python_files': [],
        'total_files': 0,
        'total_functions': 0,
        'total_classes': 0
    }
    
    for root, dirs, files in os.walk(directory):
        # Filter out ignored directories
        dirs[:] = [d for d in dirs if not should_ignore_file(os.path.join(root, d))]
        
        for file in files:
            if should_ignore_file(file):
                continue
            
            file_path = os.path.join(root, file)
            
            if file.endswith('.py'):
                parsed = parse_python_file(file_path)
                analysis['python_files'].append(parsed)
                analysis['total_functions'] += len(parsed['functions'])
                analysis['total_classes'] += len(parsed['classes'])
            
            analysis['total_files'] += 1
    
    return analysis


def read_readme(directory: str) -> Optional[str]:
    """
    Read README.md file from directory.
    
    Args:
        directory: Directory to search for README
        
    Returns:
        README content or None if not found
    """
    readme_paths = [
        os.path.join(directory, 'README.md'),
        os.path.join(directory, 'README.rst'),
        os.path.join(directory, 'readme.md'),
        os.path.join(directory, 'readme.txt')
    ]
    
    for readme_path in readme_paths:
        if os.path.exists(readme_path):
            try:
                with open(readme_path, 'r', encoding='utf-8') as f:
                    return f.read()
            except Exception:
                continue
    
    return None

