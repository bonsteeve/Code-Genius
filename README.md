# Codebase Genius 🧠

An AI-powered, multi-agent application built using the Jac Programming Language that analyzes GitHub repositories and generates comprehensive technical documentation.

## 🚀 Overview

Codebase Genius operates by building a comprehensive Graph as a shared knowledge base, which is navigated and modified by specialized Walkers (Agents). The system uses a three-phase pipeline to transform raw code into structured documentation.

## 🏗️ System Architecture

### Graph Schema (Data Model)
- **Repo Node**: Project root storing cloning metadata
- **File Node**: Represents source code files with content
- **Concept Node**: AI-generated high-level abstractions
- **Edges**: `contains` (Repo → File) and `relates_to` (File → Concept)

### Agent Pipeline
1. **RepoMapper 🗺️**: Clones repository and creates initial graph structure
2. **CodeAnalyzer 🧠**: Analyzes code to identify and define core concepts
3. **DocGenie ✍️**: Synthesizes concepts into structured documentation

## 📋 Prerequisites

- Python 3.8+
- Jac Programming Language
- Git
- LLM API access (Gemini recommended)

## 🛠️ Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/Code-Genius.git
   cd Code-Genius
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Set up environment:**
   ```bash
   cp .env.template .env
   # Edit .env and add your API keys
   ```

## 🎯 Usage

Run the system by providing a target repository URL:

```bash
jac run codebase_genius.jac --repo-url https://github.com/username/repository.git
```

### Example:
```bash
jac run codebase_genius.jac --repo-url https://github.com/facebook/react.git
```

## 📊 Output

The system generates:
- Comprehensive markdown documentation
- Identified code concepts and abstractions
- Architecture overview
- Technical implementation details
- Usage instructions

## 🔧 Development

### Branch Structure
- `main`: Production-ready code
- `develop`: Development branch for new features
- Feature branches: `feature/feature-name`

### Contributing
1. Create a feature branch from `develop`
2. Implement your changes
3. Test thoroughly
4. Submit a pull request

## 🔒 Security

- Repository cloning uses temporary directories
- Automatic cleanup of cloned repositories
- No permanent storage of analyzed code

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests to the `develop` branch.

## 📞 Support

For questions or support, please open an issue on GitHub.
