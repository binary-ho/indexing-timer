# Indexing Timer Commands
# Easy-to-use commands for measuring ctags and AST generation times

# Show available commands
default:
    @echo "📋 Available commands:"
    @echo ""
    @echo "🛠️  Setup:"
    @echo "   just setup                   - Install required dependencies (universal-ctags, tree-sitter)"
    @echo ""
    @echo "🏷️  Ctags commands:"
    @echo "   just ctag [PROJECT_PATH]     - Measure ctags generation time"
    @echo "   just ctag-here               - Measure ctags for current directory"
    @echo "   just ctag-interactive        - Interactive ctag measurement"
    @echo ""
    @echo "🌳 AST commands:"
    @echo "   just ast [FILE_PATH]         - Measure AST generation time for single file"
    @echo "   just ast-multi [FILES...]    - Measure AST generation time for multiple files"
    @echo "   just ast-interactive         - Interactive AST measurement"
    @echo ""
    @echo "📊 Batch commands:"
    @echo "   just measure-all [PROJECT]   - Run both ctag and common file AST measurements"
    @echo ""
    @echo "💡 Examples:"
    @echo "   just setup                   # First time setup"
    @echo "   just ctag /path/to/project"
    @echo "   just ast src/main.py"
    @echo "   just ast-multi src/*.py"

# Install required dependencies
setup:
    #!/usr/bin/env bash
    echo "🛠️  Installing required dependencies..."
    echo ""
    
    # Check if brew is installed
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew is not installed. Please install Homebrew first:"
        echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    
    # Install universal-ctags
    echo "📦 Installing universal-ctags..."
    if brew list universal-ctags &> /dev/null; then
        echo "✅ universal-ctags is already installed"
    else
        brew install universal-ctags
        if [ $? -eq 0 ]; then
            echo "✅ universal-ctags installed successfully"
        else
            echo "❌ Failed to install universal-ctags"
            exit 1
        fi
    fi
    
    # Install tree-sitter
    echo "📦 Installing tree-sitter..."
    if command -v tree-sitter &> /dev/null; then
        echo "✅ tree-sitter is already installed"
    else
        # Try npm first, then brew as fallback
        if command -v npm &> /dev/null; then
            echo "📦 Installing tree-sitter via npm..."
            npm install -g tree-sitter-cli
            if [ $? -eq 0 ]; then
                echo "✅ tree-sitter installed successfully via npm"
            else
                echo "⚠️  npm installation failed, trying brew..."
                brew install tree-sitter
                if [ $? -eq 0 ]; then
                    echo "✅ tree-sitter installed successfully via brew"
                else
                    echo "❌ Failed to install tree-sitter"
                    exit 1
                fi
            fi
        else
            echo "📦 Installing tree-sitter via brew..."
            brew install tree-sitter
            if [ $? -eq 0 ]; then
                echo "✅ tree-sitter installed successfully via brew"
            else
                echo "❌ Failed to install tree-sitter"
                exit 1
            fi
        fi
    fi
    
    echo ""
    echo "🎉 Setup completed successfully!"
    echo "💡 You can now use all indexing timer commands."
    echo "   Run 'just' to see available commands."

# Measure ctags generation time for a project
ctag PROJECT_PATH="":
    #!/usr/bin/env bash
    if [ -z "{{PROJECT_PATH}}" ]; then
        echo "🏷️  Enter project path for ctags measurement:"
        read -r project_path
        if [ -z "$project_path" ]; then
            echo "❌ No project path provided"
            exit 1
        fi
    else
        project_path="{{PROJECT_PATH}}"
    fi
    
    echo "🏷️  Measuring ctags generation time for: $project_path"
    python3 ctag.py "$project_path"

# Measure ctags for current directory
ctag-here:
    @echo "🏷️  Measuring ctags generation time for current directory..."
    python3 ctag.py .

# Interactive ctag measurement
ctag-interactive:
    #!/usr/bin/env bash
    echo "🏷️  Interactive Ctags Measurement"
    echo "Enter the project path (or press Enter for current directory):"
    read -r project_path
    
    if [ -z "$project_path" ]; then
        project_path="."
    fi
    
    echo "🏷️  Measuring ctags generation time for: $project_path"
    python3 ctag.py "$project_path"

# Measure AST generation time for a single file
ast FILE_PATH="":
    #!/usr/bin/env bash
    if [ -z "{{FILE_PATH}}" ]; then
        echo "🌳 Enter file path for AST measurement:"
        read -r file_path
        if [ -z "$file_path" ]; then
            echo "❌ No file path provided"
            exit 1
        fi
    else
        file_path="{{FILE_PATH}}"
    fi
    
    echo "🌳 Measuring AST generation time for: $file_path"
    python3 ast.py "$file_path"

# Measure AST generation time for multiple files
ast-multi +FILES:
    @echo "🌳 Measuring AST generation time for multiple files..."
    python3 ast.py {{FILES}}

# Interactive AST measurement
ast-interactive:
    #!/usr/bin/env bash
    echo "🌳 Interactive AST Measurement"
    echo "Choose measurement type:"
    echo "1) Single file"
    echo "2) Multiple files"
    read -r choice
    
    case $choice in
        1)
            echo "Enter file path:"
            read -r file_path
            if [ -n "$file_path" ]; then
                echo "🌳 Measuring AST generation time for: $file_path"
                python3 ast.py "$file_path"
            else
                echo "❌ No file path provided"
            fi
            ;;
        2)
            echo "Enter file paths (space-separated):"
            read -r file_paths
            if [ -n "$file_paths" ]; then
                echo "🌳 Measuring AST generation time for multiple files..."
                python3 ast.py $file_paths
            else
                echo "❌ No file paths provided"
            fi
            ;;
        *)
            echo "❌ Invalid choice"
            ;;
    esac

# Run both ctag and AST measurements for common files in a project
measure-all PROJECT_PATH="":
    #!/usr/bin/env bash
    if [ -z "{{PROJECT_PATH}}" ]; then
        echo "📊 Enter project path for comprehensive measurement:"
        read -r project_path
        if [ -z "$project_path" ]; then
            project_path="."
        fi
    else
        project_path="{{PROJECT_PATH}}"
    fi
    
    echo "📊 Running comprehensive measurements for: $project_path"
    echo ""
    
    # Run ctags measurement
    echo "🏷️  === CTAGS MEASUREMENT ==="
    python3 ctag.py "$project_path"
    echo ""
    
    # Find common source files and measure AST
    echo "🌳 === AST MEASUREMENT ==="
    echo "Looking for source files in $project_path..."
    
    # Find common source file extensions
    files=$(find "$project_path" -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.java" -o -name "*.cpp" -o -name "*.c" -o -name "*.go" -o -name "*.rs" \) | head -10)
    
    if [ -n "$files" ]; then
        echo "Found source files, measuring AST generation time..."
        python3 ast.py $files
    else
        echo "No common source files found for AST measurement"
    fi

# Quick commands for common scenarios
# Measure ctags for common project directories
ctag-src:
    @just ctag src

ctag-lib:
    @just ctag lib

# Measure AST for common file patterns
ast-py PATTERN="*.py":
    #!/usr/bin/env bash
    files=$(find . -name "{{PATTERN}}" -type f | head -5)
    if [ -n "$files" ]; then
        just ast-multi $files
    else
        echo "❌ No files found matching pattern: {{PATTERN}}"
    fi

ast-js PATTERN="*.js":
    #!/usr/bin/env bash
    files=$(find . -name "{{PATTERN}}" -type f | head -5)
    if [ -n "$files" ]; then
        just ast-multi $files
    else
        echo "❌ No files found matching pattern: {{PATTERN}}"
    fi

# Help command
help:
    @just default