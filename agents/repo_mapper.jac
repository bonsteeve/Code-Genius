import from byllm.llm { Model }

import os;

include utils;

glob llm = Model(model_name="gemini-pro", verbose=False);

node repo_mapper {
    has repo_url: str;
    has repo_path: str = "";
    has file_tree: dict = {};
    has readme_content: str = "";
    has readme_summary: str = "";
    
    def summarize_readme(content: str) -> str by llm();
    
    can execute with supervisor entry {
        std.out("Starting Repo Mapper Agent...");
        
        result = utils.git_utils.clone_repository(self.repo_url);
        repo_path = result[0];
        success = result[1];
        if not success {
            std.err("Failed to clone repository");
            disengage;
        }
        
        std.out("Repository cloned successfully to: " + repo_path);
        
        file_tree = utils.code_parser.get_file_tree(repo_path);
        std.out("File tree generated");
        
        readme_content = utils.code_parser.read_readme(repo_path);
        if readme_content != "" {
            std.out("README found, analyzing...");
            
            prompt = "Summarize the following README file in 3-4 sentences, highlighting the main purpose, key features, and important dependencies:\n\n" + readme_content;
            readme_summary = self.summarize_readme(prompt);
            std.out("README summarized");
        } else {
            std.out("No README found");
        }
        
        self.repo_path = repo_path;
        self.file_tree = file_tree;
        self.readme_content = readme_content;
        self.readme_summary = readme_summary;
        
        std.out("Repo Mapper Agent completed");
        
        report {
            "repo_path": self.repo_path,
            "file_tree": self.file_tree,
            "readme_content": self.readme_content,
            "readme_summary": self.readme_summary
        };
    }
}

sem repo_mapper.summarize_readme = "Summarize the README file in 3-4 sentences, highlighting the main purpose, key features, and important dependencies.";
