# Codebase Genius

An AI-powered, agentic system capable of autonomously generating comprehensive documentation for any given software repository from GitHub.

## Overview

Codebase Genius uses a multi-agent architecture where specialized AI agents collaborate in a pipeline to analyze and document codebases effectively. The system consists of:

- **Supervisor Agent**: Manages the entire workflow and orchestrates all worker agents
- **Repo Mapper**: Analyzes repository structure and README
- **Code Analyzer**: Parses and understands source code
- **DocGenie**: Produces documentation and diagrams

## Features

- 🔍 **Automatic Repository Analysis**: Clone and analyze any GitHub repository
- 📊 **Code Structure Mapping**: Generate file trees and understand code relationships
- 🤖 **AI-Powered Documentation**: Use LLM (Gemini) to generate comprehensive documentation
- 📈 **Visual Diagrams**: Create Mermaid diagrams for code structure and relationships
- 🐍 **Python Support**: Optimized for Python repositories (extensible to other languages)

## Prerequisites

- Python 3.8+
- Jaseci framework
- Gemini API key

## Installation

1. **Clone the repository** (if not already done):
   ```bash
   git clone <your-repo-url>
   cd Code-Genius
   ```

2. **Set up virtual environment**:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure Gemini API key**:
   - Get your API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Create a `.env` file in the project root:
     ```bash
     GEMINI_API_KEY=your_gemini_api_key_here
     OUTPUT_DIR=./output
     TEMP_DIR=./tmp
     ```

## Usage

### Basic Usage

```bash
jac run main.jac -repo_url https://github.com/user/repository
```

### With Custom Output Directory

```bash
jac run main.jac -repo_url https://github.com/user/repository -output_dir ./docs
```

### Example

```bash
jac run main.jac -repo_url https://github.com/python/cpython
```

This will:
1. Clone the repository
2. Analyze the file structure
3. Parse the code
4. Generate comprehensive documentation
5. Save the output to `./output/<repository_name>_documentation.md`

## Project Structure

```
Code-Genius/
├── agents/
│   ├── supervisor.jac      # Supervisor agent orchestrating the workflow
│   ├── repo_mapper.jac     # Repository mapping agent
│   ├── code_analyzer.jac   # Code analysis agent
│   └── docgenie.jac        # Documentation generation agent
├── utils/
│   ├── git_utils.py        # Git operations utilities
│   ├── code_parser.py      # Code parsing utilities
│   └── diagram_generator.py # Diagram generation utilities
├── output/                 # Generated documentation output
├── main.jac                # Main entry point
├── requirements.txt       # Python dependencies
└── README.md              # This file
```

## Workflow

The system follows this workflow:

1. **Clone Repository**: Fetch the source code from GitHub
2. **Map Structure**: Generate file tree and analyze README
3. **Analyze Code**: Parse source files and build code context graph
4. **Generate Documentation**: Create comprehensive markdown documentation with diagrams
5. **Save Output**: Write documentation to output directory

## Configuration

### Environment Variables

- `GEMINI_API_KEY`: Your Gemini API key (required)
- `OUTPUT_DIR`: Output directory for generated documentation (default: `./output`)
- `TEMP_DIR`: Temporary directory for cloned repositories (default: `./tmp`)

## Output

The generated documentation includes:

- **Project Overview**: Summary from README analysis
- **File Structure**: Visual file tree diagram
- **Code Analysis**: Statistics and architecture overview
- **Class Hierarchy**: Visual class relationship diagrams
- **Module Documentation**: Detailed documentation for each module
- **Summary**: AI-generated codebase summary

## Supported Languages

- **Primary**: Python, Jac
- **Extended**: Can be expanded to support additional languages

## Troubleshooting

### Common Issues

1. **API Key Error**: Make sure your `.env` file contains a valid `GEMINI_API_KEY`
2. **Repository Clone Failed**: Check your internet connection and repository URL
3. **Import Errors**: Ensure all dependencies are installed: `pip install -r requirements.txt`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[Add your license here]

## References

- [Jaseci Documentation](https://docs.jaseci.org)
- [byllm Plugin](https://github.com/jaseci-labs/jaseci/tree/main/jaseci_ai_kit/jac_misc)
- [Reference Implementation](https://github.com/jaseci-labs/Agentic-AI/tree/main/task_manager/byllm)
- [Project Requirements](https://github.com/jaseci-labs/jaseci/blob/873a0846e5aeca52dee571c858c38c8e6f9504b5/docs/docs/communityhub/fun/p2.md)

