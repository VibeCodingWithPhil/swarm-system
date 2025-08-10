#!/bin/bash

# Swarm System - Universal Setup Script
# Works with any path and properly handles spaces

# Get the actual swarm home directory (handles spaces properly)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SWARM_HOME="$(cd "$SCRIPT_DIR/.." && pwd)"

# Detect user's shell
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
    SHELL_NAME="ZSH"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
    SHELL_NAME="Bash"
else
    SHELL_RC="$HOME/.profile"
    SHELL_NAME="Shell"
fi

echo "========================================="
echo "  Swarm System - Universal Setup"
echo "========================================="
echo ""
echo "Detected: $SHELL_NAME"
echo "Config file: $SHELL_RC"
echo "Swarm location: $SWARM_HOME"
echo ""

# Function to properly escape paths for shell commands
escape_path() {
    printf '%q' "$1"
}

# Escape the swarm home path
ESCAPED_SWARM_HOME=$(escape_path "$SWARM_HOME")

# Remove old swarm commands if they exist
if grep -q "Swarm System" "$SHELL_RC" 2>/dev/null; then
    echo "Removing old swarm commands..."
    cp "$SHELL_RC" "$SHELL_RC.backup.$(date +%s)"
    
    # Remove old sections (multiple patterns to catch all versions)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS sed syntax
        sed -i '' '/# ====.*Swarm System/,/^$/d' "$SHELL_RC" 2>/dev/null
        sed -i '' '/# Swarm System commands/,/^$/d' "$SHELL_RC" 2>/dev/null
    else
        # Linux sed syntax
        sed -i '/# ====.*Swarm System/,/^$/d' "$SHELL_RC" 2>/dev/null
        sed -i '/# Swarm System commands/,/^$/d' "$SHELL_RC" 2>/dev/null
    fi
fi

# Create the commands with properly escaped paths
cat >> "$SHELL_RC" << EOF

# ============================================
# Swarm System - Universal Commands
# Installed: $(date)
# Location: $SWARM_HOME
# ============================================

# Set swarm home with properly escaped path
export SWARM_HOME="$SWARM_HOME"

# Add swarm bin to PATH (if not already there)
if [[ ":$PATH:" != *":$SWARM_HOME/bin:"* ]]; then
    export PATH="\$PATH:$ESCAPED_SWARM_HOME/bin"
fi

# Main swarm command (using quotes to handle spaces)
# Using alias instead of function to avoid conflicts
alias swarm='"$SWARM_HOME/bin/swarm-manager.sh"'

# Clear, descriptive commands
swarm-new() {
    swarm init "\$@"
}

swarm-start() {
    swarm start "\$@"
}

swarm-kanban() {
    swarm kanban "\$@"
}

swarm-resume() {
    swarm resume "\$@"
}

swarm-status() {
    swarm status "\$@"
}

swarm-existing() {
    swarm import "\$@"
}

swarm-change() {
    swarm change "\$@"
}

swarm-clean() {
    swarm clean "\$@"
}

# Project templates
swarm-new-webapp() {
    swarm template webapp "\$@"
}

swarm-new-api() {
    swarm template api "\$@"
}

swarm-new-cli() {
    swarm template cli "\$@"
}

swarm-new-ml() {
    swarm template ml "\$@"
}

swarm-new-mobile() {
    swarm template mobile "\$@"
}

swarm-new-game() {
    swarm template game "\$@"
}

# Navigation commands
swarm-home() {
    cd "$SWARM_HOME"
}

swarm-projects() {
    cd "$SWARM_HOME/projects"
}

swarm-list() {
    ls -la "$SWARM_HOME/projects" 2>/dev/null || echo "No projects found"
}

swarm-go() {
    if [ -z "\$1" ]; then
        echo "Usage: swarm-go <project-name>"
        echo ""
        echo "Available projects:"
        swarm-list
        return 1
    fi
    
    if [ -d "$SWARM_HOME/projects/\$1" ]; then
        cd "$SWARM_HOME/projects/\$1"
        echo "Switched to project: \$1"
        echo "Use 'swarm-start' to launch the swarm"
    else
        echo "Project not found: \$1"
        echo ""
        echo "Available projects:"
        swarm-list
    fi
}

# Test commands
swarm-demo() {
    swarm-new demo-todo "Build a simple todo app with React"
    swarm-go demo-todo
    swarm-start
}

swarm-test() {
    if [ -d "$SWARM_HOME/projects/swarm-enhancement" ]; then
        cd "$SWARM_HOME/projects/swarm-enhancement"
        swarm-start
    else
        echo "Test project not found. Run swarm-demo instead."
    fi
}

swarm-quick-test() {
    if [ -f "$SWARM_HOME/bin/quick-test.sh" ]; then
        "$SWARM_HOME/bin/quick-test.sh"
    else
        echo "Quick test script not found"
    fi
}

# Info commands
swarm-info() {
    if [ -f "swarm.config" ]; then
        echo "Current Swarm Project"
        echo "===================="
        cat swarm.config
        echo ""
        if [ -f "coordination/phase-status.json" ]; then
            echo "Phase Status:"
            python3 -c "
import json
with open('coordination/phase-status.json', 'r') as f:
    data = json.load(f)
    phase = data.get('current_phase', 1)
    print(f'Current Phase: {phase}/4')
            " 2>/dev/null || echo "Unable to read phase status"
        fi
        echo ""
        echo "Commands:"
        echo "  swarm-start    - Start the swarm"
        echo "  swarm-kanban   - Monitor progress"
    else
        echo "Not in a swarm project directory"
        echo ""
        echo "To see all projects: swarm-list"
        echo "To go to a project: swarm-go <project-name>"
    fi
}

swarm-help() {
    echo "Swarm System Commands"
    echo "===================="
    echo ""
    echo "CORE COMMANDS:"
    echo "  swarm-new <name> \"description\"  - Create new project"
    echo "  swarm-start                     - Start swarm in current directory"
    echo "  swarm-kanban [project]          - Launch Kanban monitor"
    echo "  swarm-resume                    - Resume previous project"
    echo "  swarm-status                    - Show all projects status"
    echo ""
    echo "PROJECT MANAGEMENT:"
    echo "  swarm-existing <path> <name>    - Import existing codebase"
    echo "  swarm-change \"description\"      - Request changes to current project"
    echo "  swarm-clean                     - Clean temporary files"
    echo ""
    echo "PROJECT TEMPLATES:"
    echo "  swarm-new-webapp <name>         - Create web application"
    echo "  swarm-new-api <name>            - Create REST API"
    echo "  swarm-new-cli <name>            - Create CLI tool"
    echo "  swarm-new-ml <name>             - Create ML project"
    echo "  swarm-new-mobile <name>         - Create mobile app"
    echo "  swarm-new-game <name>           - Create game"
    echo ""
    echo "NAVIGATION:"
    echo "  swarm-home                      - Go to swarm home directory"
    echo "  swarm-projects                  - Go to projects directory"
    echo "  swarm-list                      - List all projects"
    echo "  swarm-go <project>              - Go to specific project"
    echo ""
    echo "TESTING:"
    echo "  swarm-demo                      - Create and run demo project"
    echo "  swarm-test                      - Run test project"
    echo "  swarm-quick-test                - Run interactive test"
    echo ""
    echo "INFORMATION:"
    echo "  swarm-help                      - Show this help"
    echo "  swarm-info                      - Show current project info"
    echo ""
    echo "Swarm Location: $SWARM_HOME"
}

# Create and start helper
swarm-create-and-start() {
    if [ -z "\$1" ] || [ -z "\$2" ]; then
        echo "Usage: swarm-create-and-start <name> \"<description>\""
        return 1
    fi
    swarm-new "\$1" "\$2"
    swarm-go "\$1"
    swarm-start
}

echo "Swarm System ready! Type 'swarm-help' for commands."

# End of Swarm System Commands
EOF

echo "✅ Installation complete!"
echo ""
echo "========================================="
echo "  Next Steps"
echo "========================================="
echo ""
echo "1. Reload your shell configuration:"
echo "   source $SHELL_RC"
echo ""
echo "2. Test the installation:"
echo "   swarm-help"
echo ""
echo "3. Run a quick demo:"
echo "   swarm-demo"
echo ""
echo "Commands are now universal and will work from any directory!"
echo "All paths are properly handled, even with spaces."