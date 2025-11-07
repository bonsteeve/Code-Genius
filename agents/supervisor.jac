import os;

include utils;

node supervisor {
    has repo_url: str = "";
    has output_dir: str = "./output";
    has repo_path: str = "";
    has file_tree: dict = {};
    has readme_summary: str = "";
    has code_graph: dict = {};
    has documentation: str = "";
    has output_file: str = "";

    can execute with `root entry {
        print("==================================================");
        print("Codebase Genius - Supervisor Agent");
        print("==================================================");
        print("");

        if self.repo_url == "" {
            print("Repository URL is required");
            disengage;
        }

        print("Repository URL: " + self.repo_url);
        print("Output Directory: " + self.output_dir);
        print("");

        print("Phase 1: Repository Mapping");
        print("--------------------------------------------------");
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
            print("Failed to clone repository");
            disengage;
        }

        print("");

        print("Phase 2: Code Analysis");
        print("--------------------------------------------------");
        visit [-->(`?code_analyzer)] else {
            code_analyzer_node = here ++> code_analyzer(repo_path=self.repo_path);
            visit code_analyzer_node;
        }
        code_analyzer_nodes = [here --> (`?code_analyzer)];
        if code_analyzer_nodes {
            self.code_graph = code_analyzer_nodes[0].code_graph;
        }

        if self.code_graph == {} {
            print("Failed to analyze code");
            disengage;
        }

        print("");

        print("Phase 3: Documentation Generation");
        print("--------------------------------------------------");
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
            print("Failed to generate documentation");
            disengage;
        }

        print("");

        print("Phase 4: Saving Documentation");
        print("--------------------------------------------------");

        repo_name = utils.git_utils.get_repository_name(self.repo_url);
        output_file = self.output_dir + "/" + repo_name + "_documentation.md";
        
        print("Documentation saved to: " + output_file);

        if self.repo_path != "" {
            print("Cleaning up temporary files...");
            utils.git_utils.cleanup_temp_directory(self.repo_path);
        }

        print("");
        print("==================================================");
        print("Documentation generation completed successfully!");
        print("==================================================");

        self.output_file = output_file;

        report {
            "documentation": self.documentation,
            "output_file": self.output_file
        };
    }
}