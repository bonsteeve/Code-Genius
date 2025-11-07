import os;

include utils;
include agents;

node supervisor {
    has repo_url: str = "";
    has output_dir: str = "./output";
    has repo_path: str = "";
    has file_tree: dict = {};
    has readme_summary: str = "";
    has code_graph: dict = {};
    has documentation: str = "";
    has output_file: str = "";
    
    can execute with codegenius entry {
        std.out("=" * 50);
        std.out("Codebase Genius - Supervisor Agent");
        std.out("=" * 50);
        std.out("");
        
        if self.repo_url == "" {
            std.err("Repository URL is required");
            disengage;
        }
        
        std.out("Repository URL: " + self.repo_url);
        std.out("Output Directory: " + self.output_dir);
        std.out("");
        
        std.out("Phase 1: Repository Mapping");
        std.out("-" * 50);
        visit [-->(`?repo_mapper)] else {
            repo_mapper_node = here ++> repo_mapper(repo_url=self.repo_url);
            visit repo_mapper_node;
        }
        repo_mapper_nodes = [here --> (`?repo_mapper)];
        if repo_mapper_nodes {
            self.file_tree = repo_mapper_nodes[0].file_tree;
            self.readme_summary = repo_mapper_nodes[0].readme_summary;
            self.repo_path = repo_mapper_nodes[0].repo_path;
        }
        
        if self.repo_path == "" {
            std.err("Failed to clone repository");
            disengage;
        }
        
        std.out("");
        
        std.out("Phase 2: Code Analysis");
        std.out("-" * 50);
        visit [-->(`?code_analyzer)] else {
            code_analyzer_node = here ++> code_analyzer(repo_path=self.repo_path);
            visit code_analyzer_node;
        }
        code_analyzer_nodes = [here --> (`?code_analyzer)];
        if code_analyzer_nodes {
            self.code_graph = code_analyzer_nodes[0].code_graph;
        }
        
        if self.code_graph == {} {
            std.err("Failed to analyze code");
            disengage;
        }
        
        std.out("");
        
        std.out("Phase 3: Documentation Generation");
        std.out("-" * 50);
        visit [-->(`?docgenie)] else {
            docgenie_node = here ++> docgenie(
                repo_url=self.repo_url,
                file_tree=self.file_tree,
                readme_summary=self.readme_summary,
                code_graph=self.code_graph
            );
            visit docgenie_node;
        }
        docgenie_nodes = [here --> (`?docgenie)];
        if docgenie_nodes {
            self.documentation = docgenie_nodes[0].documentation;
        }
        
        if self.documentation == "" {
            std.err("Failed to generate documentation");
            disengage;
        }
        
        std.out("");
        
        std.out("Phase 4: Saving Documentation");
        std.out("-" * 50);
        
        if not std.file_exists(self.output_dir) {
            std.file_mkdir(self.output_dir);
        }
        
        repo_name = utils.git_utils.get_repository_name(self.repo_url);
        output_file = self.output_dir + "/" + repo_name + "_documentation.md";
        
        std.file_write(output_file, self.documentation);
        std.out("Documentation saved to: " + output_file);
        
        if self.repo_path != "" {
            std.out("Cleaning up temporary files...");
            utils.git_utils.cleanup_temp_directory(self.repo_path);
        }
        
        std.out("");
        std.out("=" * 50);
        std.out("Documentation generation completed successfully!");
        std.out("=" * 50);
        
        self.output_file = output_file;
        
        report {
            "documentation": self.documentation,
            "output_file": self.output_file
        };
    }
}
