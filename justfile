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
    @echo "   just ctag-browse             - Browse directories interactively for ctag measurement"
    @echo ""
    @echo "🌳 AST commands:"
    @echo "   just ast [FILE_PATH]         - Measure AST generation time for single file"
    @echo "   just ast-multi [FILES...]    - Measure AST generation time for multiple files"
    @echo "   just ast-interactive         - Interactive AST measurement"
    @echo "   just ast-browse              - Browse directories/files interactively for AST measurement"
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

# Browse directories interactively for ctag measurement
ctag-browse:
    #!/usr/bin/env bash
    current_dir="$(pwd)"
    
    while true; do
        clear
        echo "🏷️  Interactive Directory Browser for Ctags"
        echo "📁 Current directory: $current_dir"
        echo ""
        
        # Show parent directory option
        echo "0) 📁 .. (Parent directory)"
        echo "1) 🎯 [SELECT THIS DIRECTORY]"
        echo ""
        
        # List directories with numbers
        counter=2
        declare -a dirs
        dirs[1]="."
        
        if [ -d "$current_dir" ]; then
            while IFS= read -r -d '' dir; do
                if [ -d "$dir" ] && [ "$(basename "$dir")" != "." ] && [ "$(basename "$dir")" != ".." ]; then
                    dirs[$counter]="$dir"
                    echo "$counter) 📁 $(basename "$dir")"
                    ((counter++))
                fi
            done < <(find "$current_dir" -maxdepth 1 -type d -print0 | sort -z)
        fi
        
        echo ""
        echo "Enter your choice (0 for parent, 1 to select current, 2+ for subdirectory, q to quit):"
        read -r choice
        
        case $choice in
            0)
                # Go to parent directory
                current_dir="$(dirname "$current_dir")"
                ;;
            1)
                # Select current directory
                echo ""
                echo "🏷️  Selected directory: $current_dir"
                echo "🏷️  Measuring ctags generation time..."
                python3 ctag.py "$current_dir"
                break
                ;;
            q|Q)
                echo "❌ Cancelled"
                break
                ;;
            *)
                # Check if it's a valid directory choice
                if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 2 ] && [ "$choice" -lt "$counter" ]; then
                    selected_dir="${dirs[$choice]}"
                    if [ -d "$selected_dir" ]; then
                        current_dir="$selected_dir"
                    else
                        echo "❌ Invalid directory"
                        sleep 1
                    fi
                else
                    echo "❌ Invalid choice"
                    sleep 1
                fi
                ;;
        esac
    done

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

# Browse directories/files interactively for AST measurement
ast-browse:
    #!/usr/bin/env bash
    current_dir="$(pwd)"
    
    while true; do
        clear
        echo "🌳 Interactive File Browser for AST Measurement"
        echo "📁 Current directory: $current_dir"
        echo ""
        
        # Show parent directory option
        echo "0) 📁 .. (Parent directory)"
        echo ""
        
        # List directories and files with numbers
        counter=1
        declare -a items
        declare -a item_types
        
        if [ -d "$current_dir" ]; then
            # First, list directories
            while IFS= read -r -d '' dir; do
                if [ -d "$dir" ] && [ "$(basename "$dir")" != "." ] && [ "$(basename "$dir")" != ".." ]; then
                    items[$counter]="$dir"
                    item_types[$counter]="dir"
                    echo "$counter) 📁 $(basename "$dir")/"
                    ((counter++))
                fi
            done < <(find "$current_dir" -maxdepth 1 -type d -print0 | sort -z)
            
            # Then, list common source files
            while IFS= read -r -d '' file; do
                if [ -f "$file" ]; then
                    filename="$(basename "$file")"
                    # Show common source file extensions
                    if [[ "$filename" =~ \.(py|js|ts|java|cpp|c|go|rs|kt|swift|php|rb|cs|scala|clj|hs|ml|fs|elm|dart|lua|r|m|mm|h|hpp|cc|cxx)$ ]]; then
                        items[$counter]="$file"
                        item_types[$counter]="file"
                        echo "$counter) 📄 $filename"
                        ((counter++))
                    fi
                fi
            done < <(find "$current_dir" -maxdepth 1 -type f -print0 | sort -z)
        fi
        
        echo ""
        echo "Enter your choice (0 for parent, 1+ for directory/file, m for multiple files, q to quit):"
        read -r choice
        
        case $choice in
            0)
                # Go to parent directory
                current_dir="$(dirname "$current_dir")"
                ;;
            m|M)
                # Multiple file selection mode
                echo ""
                echo "🌳 Multiple File Selection Mode"
                echo "Enter file numbers separated by spaces (e.g., 2 5 7):"
                read -r file_choices
                
                selected_files=()
                for choice_num in $file_choices; do
                    if [[ "$choice_num" =~ ^[0-9]+$ ]] && [ "$choice_num" -ge 1 ] && [ "$choice_num" -lt "$counter" ]; then
                        if [ "${item_types[$choice_num]}" = "file" ]; then
                            selected_files+=("${items[$choice_num]}")
                        fi
                    fi
                done
                
                if [ ${#selected_files[@]} -gt 0 ]; then
                    echo ""
                    echo "🌳 Selected files:"
                    for file in "${selected_files[@]}"; do
                        echo "   📄 $(basename "$file")"
                    done
                    echo ""
                    echo "🌳 Measuring AST generation time for multiple files..."
                    python3 ast.py "${selected_files[@]}"
                    break
                else
                    echo "❌ No valid files selected"
                    sleep 2
                fi
                ;;
            q|Q)
                echo "❌ Cancelled"
                break
                ;;
            *)
                # Check if it's a valid choice
                if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -lt "$counter" ]; then
                    selected_item="${items[$choice]}"
                    item_type="${item_types[$choice]}"
                    
                    if [ "$item_type" = "dir" ] && [ -d "$selected_item" ]; then
                        current_dir="$selected_item"
                    elif [ "$item_type" = "file" ] && [ -f "$selected_item" ]; then
                        echo ""
                        echo "🌳 Selected file: $(basename "$selected_item")"
                        echo "🌳 Measuring AST generation time..."
                        python3 ast.py "$selected_item"
                        break
                    else
                        echo "❌ Invalid selection"
                        sleep 1
                    fi
                else
                    echo "❌ Invalid choice"
                    sleep 1
                fi
                ;;
        esac
    done

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