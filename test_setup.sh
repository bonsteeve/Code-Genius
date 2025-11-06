#!/bin/bash

# Test script for Codebase Genius
# This script validates the setup and runs basic tests

echo "🧪 Testing Codebase Genius Setup..."
echo "=================================="

# Check if jac is installed
echo "1. Checking Jac installation..."
if command -v jac &> /dev/null; then
    echo "✅ Jac is installed: $(jac --version)"
else
    echo "❌ Jac is not installed. Please run: pip install jaclang"
    exit 1
fi

# Check if required Python packages are installed
echo "2. Checking Python dependencies..."
python -c "import git; print('✅ GitPython is available')" 2>/dev/null || echo "❌ GitPython not found. Please run: pip install GitPython"

# Check if .env file exists
echo "3. Checking environment configuration..."
if [ -f ".env" ]; then
    echo "✅ .env file found"
else
    echo "⚠️ .env file not found. Please copy .env.template to .env and configure your API keys"
fi

# Test Jac syntax
echo "4. Validating Jac syntax..."
if jac check codebase_genius.jac; then
    echo "✅ Jac syntax is valid"
else
    echo "❌ Jac syntax errors found"
    exit 1
fi

echo ""
echo "🎉 Setup validation complete!"
echo ""
echo "To test the system, run:"
echo "jac run codebase_genius.jac --repo-url https://github.com/username/repository.git"