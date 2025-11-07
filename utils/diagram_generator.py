"""
Diagram generation utilities for creating Mermaid diagrams.
"""

from typing import Dict, List


def generate_file_tree_diagram(file_tree: List[Dict], max_depth: int = 3) -> str:
    """
    Generate a Mermaid diagram for file tree structure.
    
    Args:
        file_tree: File tree structure from code_parser
        max_depth: Maximum depth to include in diagram
        
    Returns:
        Mermaid diagram code as string
    """
    diagram = "```mermaid\n"
    diagram += "graph TD\n"
    
    def add_nodes(items: List[Dict], parent_id: str = "root", depth: int = 0):
        if depth >= max_depth:
            return
        
        for idx, item in enumerate(items[:20]):  # Limit to 20 items per level
            node_id = f"{parent_id}_{idx}"
            node_label = item['name']
            
            if item['type'] == 'directory':
                node_label = f"📁 {node_label}"
            else:
                node_label = f"📄 {node_label}"
            
            diagram += f'    {node_id}["{node_label}"]\n'
            diagram += f'    {parent_id} --> {node_id}\n'
            
            if item['type'] == 'directory' and item.get('children'):
                add_nodes(item['children'], node_id, depth + 1)
    
    add_nodes(file_tree)
    diagram += "```\n"
    
    return diagram


def generate_class_hierarchy_diagram(classes: List[Dict]) -> str:
    """
    Generate a Mermaid diagram for class hierarchy.
    
    Args:
        classes: List of class information dictionaries
        
    Returns:
        Mermaid diagram code as string
    """
    diagram = "```mermaid\n"
    diagram += "classDiagram\n"
    
    for cls in classes[:30]:  # Limit to 30 classes
        class_name = cls.get('name', 'Unknown')
        diagram += f'    class {class_name} {{\n'
        
        # Extract methods from class code (simplified)
        if 'code' in cls:
            code = cls['code']
            # Simple extraction of method names
            methods = []
            lines = code.split('\n')
            for line in lines:
                if 'def ' in line and '(' in line:
                    method_name = line.split('def ')[1].split('(')[0].strip()
                    if method_name and not method_name.startswith('_'):
                        methods.append(method_name)
            
            for method in methods[:5]:  # Limit to 5 methods per class
                diagram += f'        +{method}()\n'
        
        diagram += '    }\n'
    
    diagram += "```\n"
    
    return diagram


def generate_function_call_diagram(functions: List[Dict]) -> str:
    """
    Generate a Mermaid flowchart for function calls.
    
    Args:
        functions: List of function information dictionaries
        
    Returns:
        Mermaid diagram code as string
    """
    diagram = "```mermaid\n"
    diagram += "flowchart TD\n"
    
    for func in functions[:20]:  # Limit to 20 functions
        func_name = func.get('name', 'Unknown')
        func_id = func_name.replace(' ', '_').replace('-', '_')
        diagram += f'    {func_id}["{func_name}"]\n'
    
    diagram += "```\n"
    
    return diagram


def generate_architecture_diagram(modules: List[str]) -> str:
    """
    Generate a Mermaid diagram for system architecture.
    
    Args:
        modules: List of module names
        
    Returns:
        Mermaid diagram code as string
    """
    diagram = "```mermaid\n"
    diagram += "graph LR\n"
    
    for idx, module in enumerate(modules[:10]):  # Limit to 10 modules
        module_id = f"module_{idx}"
        diagram += f'    {module_id}["{module}"]\n'
        
        # Add connections (simplified - can be enhanced)
        if idx > 0:
            prev_id = f"module_{idx-1}"
            diagram += f'    {prev_id} --> {module_id}\n'
    
    diagram += "```\n"
    
    return diagram

