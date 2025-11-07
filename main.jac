import from dotenv { load_dotenv }

import os;

include utils;

include agents;

walker codegenius {
    has repo_url: str = "";
    has output_dir: str = "./output";
    
    can execute with `root entry {
        std.out("Codebase Genius - Documentation Generator");
        std.out("==========================================\n");
        
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
            std.err("Error: Repository URL is required");
            std.out("Usage: REPO_URL=https://github.com/user/repo jac run main.jac");
            std.out("   or: export REPO_URL=https://github.com/user/repo && jac run main.jac");
            disengage;
        }
        
        if not utils.git_utils.validate_github_url(self.repo_url) {
            std.err("Error: Invalid GitHub repository URL");
            std.out("Please provide a valid GitHub URL (e.g., https://github.com/user/repo)");
            disengage;
        }
        
        std.out("Starting documentation generation...");
        std.out("Repository: " + self.repo_url);
        std.out("Output Directory: " + self.output_dir);
        std.out("");
        
        visit [-->(`?supervisor)] else {
            supervisor_node = here ++> supervisor(repo_url=self.repo_url, output_dir=self.output_dir);
            visit supervisor_node;
        }
        
        supervisor_nodes = [here --> (`?supervisor)];
        if supervisor_nodes and supervisor_nodes[0].documentation != "" {
            std.out("\n✓ Documentation generated successfully!");
            std.out("Output file: " + supervisor_nodes[0].output_file);
        } else {
            std.err("\n✗ Failed to generate documentation");
        }
    }
}

with entry {
    load_dotenv();
}
