#!/bin/bash

# Codebase Genius Setup Script

echo "Codebase Genius - Setup Script"
echo "==============================="
echo ""

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Check for .env file
if [ ! -f ".env" ]; then
    echo ""
    echo "⚠️  .env file not found!"
    echo "Please create a .env file with your Gemini API key:"
    echo ""
    echo "GEMINI_API_KEY=your_gemini_api_key_here"
    echo "OUTPUT_DIR=./output"
    echo "TEMP_DIR=./tmp"
    echo ""
    echo "Get your API key from: https://makersuite.google.com/app/apikey"
else
    echo "✓ .env file found"
fi

# Create output directory
if [ ! -d "output" ]; then
    echo "Creating output directory..."
    mkdir -p output
fi

# Create temp directory
if [ ! -d "tmp" ]; then
    echo "Creating temp directory..."
    mkdir -p tmp
fi

echo ""
echo "✓ Setup complete!"
echo ""
echo "To use Codebase Genius:"
echo "  source venv/bin/activate"
echo "  jac run main.jac -repo_url <github_url>"
echo ""

