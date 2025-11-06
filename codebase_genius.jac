"""
Codebase Genius - An Agentic Code-Documentation System
Built using the Jac Programming Language

This system operates by building a comprehensive Graph as a shared knowledge base,
which is navigated and modified by specialized Walkers (Agents).
"""

import:py from git, Repo;
import:py tempfile, shutil, os;
import:py sys;

# Graph Schema - The Data Model

node Repo {
    has url: str;
    has name: str;
    has local_path: str;
}

node File {
    has path: str;
    has content: str;
}

node Concept {
    has name: str;
    has summary: str;
    has chapter_order: int;
}

edge contains;
edge relates_to;

# Python helper functions for repository management
::py::
import tempfile
import shutil
import os
from git import Repo

def clone_repo_and_return_path(url: str) -> str:
    """Clone repository to temporary directory"""
    temp_dir = tempfile.mkdtemp(prefix="codebase_genius_repo_")
    try:
        Repo.clone_from(url, temp_dir)
        return temp_dir
    except Exception as e:
        # Clean up on failure
        if os.path.exists(temp_dir):
            shutil.rmtree(temp_dir)
        raise e

def cleanup_repo_path(repo_path: str):
    """Clean up the cloned repository"""
    if os.path.exists(repo_path):
        shutil.rmtree(repo_path)

def get_repo_url_from_args():
    """Extract repository URL from command line arguments"""
    import sys
    for i, arg in enumerate(sys.argv):
        if arg == "--repo-url" and i + 1 < len(sys.argv):
            return sys.argv[i + 1]
    raise ValueError("Repository URL not provided. Use --repo-url [GITHUB_URL]")

def read_file_content(file_path: str) -> str:
    """Read content from a file"""
    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            return f.read()
    except Exception:
        return ""

def list_source_files(repo_path: str) -> list:
    """List all source code files in the repository"""
    source_extensions = {'.py', '.js', '.ts', '.java', '.cpp', '.c', '.cs', '.go', '.rs', '.php', '.rb', '.swift', '.kt'}
    source_files = []
    
    for root, dirs, files in os.walk(repo_path):
        # Skip common non-source directories
        dirs[:] = [d for d in dirs if d not in {'.git', 'node_modules', '__pycache__', '.venv', 'venv', 'dist', 'build'}]
        
        for file in files:
            if any(file.endswith(ext) for ext in source_extensions):
                full_path = os.path.join(root, file)
                relative_path = os.path.relpath(full_path, repo_path)
                source_files.append(relative_path)
    
    return source_files
::

# Walker Definitions

walker RepoMapper {
    """
    Phase 1: Repository Mapping Agent
    Responsible for cloning repository and creating initial graph structure
    """
    
    can clone_and_map with Repo entry {
        print("🗺️ RepoMapper: Starting repository ingestion...");
        
        # Clone repository to temporary directory
        try {
            here.local_path = ::py::clone_repo_and_return_path(here.url);
            print(f"Repository cloned to: {here.local_path}");
            
            # Get list of source files
            source_files = ::py::list_source_files(here.local_path);
            print(f"Found {len(source_files)} source files");
            
            # Create File nodes and contains edges
            for file_path in source_files {
                full_path = os.path.join(here.local_path, file_path);
                file_content = ::py::read_file_content(full_path);
                
                file_node = here ++> File(
                    path=file_path,
                    content=file_content
                );
                here ++> contains ++> file_node;
            }
            
            print("✅ Repository mapping completed");
            
        } except Exception as e {
            print(f"❌ Error during repository mapping: {e}");
            raise;
        }
    }
}

walker CodeAnalyzer {
    """
    Phase 2: Code Analysis Agent
    Responsible for analyzing code and identifying concepts
    """
    
    can analyze_code with Repo entry {
        print("🧠 CodeAnalyzer: Starting deep code analysis...");
        
        # Get all file nodes
        file_nodes = [n for n in here <--> contains if n.__class__.__name__ == "File"];
        print(f"Analyzing {len(file_nodes)} files...");
        
        concepts = [];
        concept_counter = 0;
        
        # Analyze each file for concepts
        for file_node in file_nodes {
            if len(file_node.content.strip()) < 50 {  # Skip very small files
                continue;
            }
            
            # Use LLM to identify concepts
            analysis_prompt = f"""
            Analyze this source code file and identify the main technical or business concepts it represents.
            Focus on high-level abstractions like services, modules, utilities, etc.
            
            File: {file_node.path}
            Content:
            {file_node.content[:2000]}  # Limit content for LLM
            
            Please identify:
            1. The primary concept/purpose of this file
            2. A brief summary (2-3 sentences)
            
            Respond in format:
            CONCEPT: [concept name]
            SUMMARY: [brief summary]
            """;
            
            try {
                response = here |> llm(analysis_prompt);
                
                # Parse LLM response
                lines = response.split('\n');
                concept_name = "";
                concept_summary = "";
                
                for line in lines {
                    if line.startswith("CONCEPT:") {
                        concept_name = line.replace("CONCEPT:", "").strip();
                    } elif line.startswith("SUMMARY:") {
                        concept_summary = line.replace("SUMMARY:", "").strip();
                    }
                }
                
                if concept_name and concept_summary {
                    # Create concept node
                    concept_node = here ++> Concept(
                        name=concept_name,
                        summary=concept_summary,
                        chapter_order=concept_counter
                    );
                    
                    # Link to source file
                    file_node ++> relates_to ++> concept_node;
                    concepts.append(concept_node);
                    concept_counter += 1;
                    
                    print(f"📝 Identified concept: {concept_name}");
                }
                
            } except Exception as e {
                print(f"⚠️ Error analyzing {file_node.path}: {e}");
                continue;
            }
        }
        
        print(f"✅ Code analysis completed. Found {len(concepts)} concepts");
    }
}

walker DocGenie {
    """
    Phase 3: Documentation Generation Agent
    Responsible for synthesizing concepts into structured documentation
    """
    
    can generate_documentation with Repo entry {
        print("✍️ DocGenie: Starting documentation synthesis...");
        
        # Get all concept nodes
        concept_nodes = [n for n in here <--> relates_to if n.__class__.__name__ == "Concept"];
        
        if not concept_nodes {
            print("❌ No concepts found to document");
            return;
        }
        
        # Sort concepts by chapter order
        concept_nodes.sort(key=lambda x: x.chapter_order);
        
        print(f"Generating documentation for {len(concept_nodes)} concepts...");
        
        # Create comprehensive documentation prompt
        concepts_text = "";
        for concept in concept_nodes {
            concepts_text += f"## {concept.name}\n{concept.summary}\n\n";
        }
        
        doc_prompt = f"""
        Create comprehensive technical documentation for this codebase based on the identified concepts.
        
        Repository: {here.name}
        URL: {here.url}
        
        Identified Concepts:
        {concepts_text}
        
        Please create a well-structured markdown document that includes:
        1. Project Overview
        2. Architecture Overview
        3. Key Components (based on the concepts)
        4. Technical Implementation Details
        5. Usage Instructions
        
        Make it professional and comprehensive.
        """;
        
        try {
            documentation = here |> llm(doc_prompt);
            
            # Save documentation to file
            doc_filename = f"{here.name}_documentation.md";
            with open(doc_filename, 'w') as f:
                f.write(documentation);
            
            print(f"✅ Documentation generated: {doc_filename}");
            print("\n" + "="*50);
            print("📄 GENERATED DOCUMENTATION:");
            print("="*50);
            print(documentation[:1000] + "..." if len(documentation) > 1000 else documentation);
            
        } except Exception as e {
            print(f"❌ Error generating documentation: {e}");
        }
    }
}

walker CodebaseWalker {
    """
    Main orchestrator walker that coordinates the three-phase pipeline
    """
    has local_repo_path: str = "";
    
    can run_pipeline(url: str) with `root entry {
        print(f"🚀 Starting Codebase Genius pipeline for: {url}");
        
        # Extract repository name from URL
        repo_name = url.split('/')[-1].replace('.git', '');
        
        # Create repository node
        repo_node = `root ++> Repo(
            url=url,
            name=repo_name,
            local_path=""
        );
        
        try {
            # Phase 1: Repository Mapping
            print("\n" + "="*50);
            print("PHASE 1: Repository Mapping");
            print("="*50);
            visit repo_node with RepoMapper;
            self.local_repo_path = repo_node.local_path;
            
            # Phase 2: Code Analysis
            print("\n" + "="*50);
            print("PHASE 2: Code Analysis");
            print("="*50);
            visit repo_node with CodeAnalyzer;
            
            # Phase 3: Documentation Generation
            print("\n" + "="*50);
            print("PHASE 3: Documentation Generation");
            print("="*50);
            visit repo_node with DocGenie;
            
            print("\n🎉 Pipeline completed successfully!");
            
        } except Exception as e {
            print(f"❌ Pipeline failed: {e}");
        } finally {
            # Guaranteed cleanup
            if self.local_repo_path {
                print(f"🧹 Cleaning up temporary directory: {self.local_repo_path}");
                ::py::cleanup_repo_path(self.local_repo_path);
            }
        }
    }
}

# Entry Point
with entry {
    # Get the repository URL argument
    try {
        TARGET_URL = ::py::get_repo_url_from_args();
        print(f"Target Repository: {TARGET_URL}");
        
        # Start the pipeline
        root spawn CodebaseWalker.run_pipeline(url=TARGET_URL);
        
    } except Exception as e {
        print(f"Error: {e}");
        print("Usage: jac run codebase_genius.jac --repo-url [GITHUB_URL]");
    }
}