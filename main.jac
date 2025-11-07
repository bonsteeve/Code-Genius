import from dotenv { load_dotenv }
import from utils.git_utils { validate_github_url }

import os;

include agents.supervisor;
include agents.repo_mapper;
include agents.code_analyzer; 
include agents.docgenie;

walker codegenius {
    has repo_url: str = "";
    has output_dir: str = "./output";
    
    can execute with `root entry {
        print("Codebase Genius - Documentation Generator");
        print("==========================================\n");
        
        if self.repo_url == "" {
            repo_url_env = os.getenv("REPO_URL");
            if repo_url_env != "" {
                self.repo_url = repo_url_env;
            }
        }
        
        output_dir_env = os.getenv("OUTPUT_DIR");
        if output_dir_env != "" {
            self.output_dir = output_dir_env;
        }
        
        if self.repo_url == "" {
            print("Error: Repository URL is required");
            print("Usage: REPO_URL=https://github.com/user/repo jac run main.jac");
            print("  or: export REPO_URL=https://github.com/user/repo && jac run main.jac");
            disengage;
        }
        
        if not validate_github_url(self.repo_url) {
            print("Error: Invalid GitHub repository URL");
            print("Please provide a valid GitHub URL (e.g., https://github.com/user/repo)");
            disengage;
        }
        
        print("Starting documentation generation...");
        print("Repository: " + self.repo_url);
        print("Output Directory: " + self.output_dir);
        print("");
        
        supervisor_node = here ++> supervisor(repo_url=self.repo_url, output_dir=self.output_dir);
        print("Created supervisor node, visiting...");
        visit supervisor_node;
        print("Supervisor visit completed.");
        
        supervisor_nodes = [here --> (`?supervisor)];
        print("Found " + str(len(supervisor_nodes)) + " supervisor nodes");
        if supervisor_nodes and supervisor_nodes[0].documentation != "" {
            print("\n✓ Documentation generated successfully!");
            print("Output file: " + supervisor_nodes[0].output_file);
        } else {
            print("\n✗ Failed to generate documentation");
            if supervisor_nodes {
                print("Supervisor node exists but documentation is empty: '" + supervisor_nodes[0].documentation + "'");
            } else {
                print("No supervisor nodes found");
            }
        }
    }
}

with entry {
    load_dotenv();
    root spawn codegenius();
}
