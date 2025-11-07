import from byllm.llm { Model }

import os;

include utils;

glob llm = Model(model_name="gemini-pro", verbose=False);

node code_analyzer {
    has repo_path: str;
    has analysis_result: dict = {};
    has code_graph: dict = {};
    
    def analyze_relationships(code_summary: str) -> str by llm();
    
    can execute with supervisor entry {
        print("Starting Code Analyzer Agent...");
        
        if self.repo_path == "" {
            print("Repository path not provided");
            disengage;
        }
        
        analysis_result = utils.code_parser.analyze_codebase(self.repo_path);
        print("Codebase analysis completed");
        print("Found " + str(analysis_result.total_files) + " files");
        print("Found " + str(analysis_result.total_functions) + " functions");
        print("Found " + str(analysis_result.total_classes) + " classes");
        
        code_graph = {
            "files": analysis_result.python_files,
            "statistics": {
                "total_files": analysis_result.total_files,
                "total_functions": analysis_result.total_functions,
                "total_classes": analysis_result.total_classes
            }
        };
        
        if len(analysis_result.python_files) > 0 {
            print("Analyzing code relationships...");
            
            code_summary = "";
            for file in analysis_result.python_files[:10] {
                code_summary += "File: " + file.file_path + "\n";
                code_summary += "Functions: " + str(len(file.functions)) + "\n";
                code_summary += "Classes: " + str(len(file.classes)) + "\n";
                code_summary += "\n";
            }
            
            prompt = "Analyze the following code structure and identify the main components, their relationships, and the overall architecture:\n\n" + code_summary;
            relationship_analysis = self.analyze_relationships(prompt);
            
            code_graph["relationship_analysis"] = relationship_analysis;
            print("Code relationships analyzed");
        }
        
        self.analysis_result = analysis_result;
        self.code_graph = code_graph;
        
        print("Code Analyzer Agent completed");
        
        report {
            "analysis_result": self.analysis_result,
            "code_graph": self.code_graph
        };
    }
}

sem code_analyzer.analyze_relationships = "Analyze the code structure and identify the main components, their relationships, and the overall architecture.";
