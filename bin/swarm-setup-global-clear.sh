#!/bin/bash

# Swarm System - Clear, Intuitive Global Commands Setup

SWARM_HOME="$(cd "$(dirname "$0")/.." && pwd)"
SHELL_RC=""

# Detect shell configuration file
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
    echo "Detected ZSH shell"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
    echo "Detected Bash shell"
else
    SHELL_RC="$HOME/.profile"
    echo "Using default profile"
fi

echo "========================================="
echo "  Swarm System - Clear Commands Setup"
echo "========================================="
echo ""
echo "Installing intuitive commands to: $SHELL_RC"
echo "Swarm home: $SWARM_HOME"
echo ""

# Create the commands section with clear, descriptive names
SWARM_COMMANDS='
# ============================================
# Swarm System - Clear, Intuitive Commands
# ============================================

# Core Swarm Commands
export SWARM_HOME="'$SWARM_HOME'"
export PATH="$PATH:$SWARM_HOME/bin"

# Main command
alias swarm="$SWARM_HOME/bin/swarm-manager.sh"

# Clear, descriptive commands
alias swarm-setup="$SWARM_HOME/bin/swarm-setup-global-clear.sh"
alias swarm-new="swarm init"                       # Create new project
alias swarm-start="swarm start"                    # Start swarm in current directory
alias swarm-kanban="swarm kanban"                  # Launch Kanban monitor
alias swarm-resume="swarm resume"                  # Resume previous project
alias swarm-status="swarm status"                  # Show all projects status
alias swarm-existing="swarm import"                # Import existing project
alias swarm-change="swarm change"                  # Request changes to current project
alias swarm-clean="swarm clean"                    # Clean temporary files

# Project templates with clear names
alias swarm-new-webapp="swarm template webapp"     # Create web application
alias swarm-new-api="swarm template api"           # Create API project
alias swarm-new-cli="swarm template cli"           # Create CLI tool
alias swarm-new-ml="swarm template ml"             # Create ML project
alias swarm-new-mobile="swarm template mobile"     # Create mobile app
alias swarm-new-game="swarm template game"         # Create game project

# Navigation commands
alias swarm-home="cd $SWARM_HOME"                  # Go to swarm home
alias swarm-projects="cd $SWARM_HOME/projects"     # Go to projects directory
alias swarm-list="ls -la $SWARM_HOME/projects"     # List all projects

# Quick test commands
alias swarm-demo="swarm init demo-todo \"Build a simple todo app with React\" && cd $SWARM_HOME/projects/demo-todo && swarm start"
alias swarm-test="cd $SWARM_HOME/projects/swarm-enhancement 2>/dev/null && swarm start || echo \"No test project found. Run swarm-demo first.\""

# Helper functions with clear names
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
    echo "  swarm-quick-test                - Run quick test script"
    echo ""
    echo "MONITORING:"
    echo "  swarm-kanban [project]          - Launch web-based Kanban board"
    echo ""
    echo "INFORMATION:"
    echo "  swarm-help                      - Show this help"
    echo "  swarm-info                      - Show current project info"
    echo "  swarm help                      - Show detailed swarm help"
}

# Go to a specific project
swarm-go() {
    if [ -z "$1" ]; then
        echo "Usage: swarm-go <project-name>"
        echo ""
        echo "Available projects:"
        ls "$SWARM_HOME/projects" 2>/dev/null || echo "No projects found"
        return 1
    fi
    
    if [ -d "$SWARM_HOME/projects/$1" ]; then
        cd "$SWARM_HOME/projects/$1"
        echo "Switched to project: $1"
        echo "Use '\''swarm-start'\'' to launch the swarm"
    else
        echo "Project not found: $1"
        echo ""
        echo "Available projects:"
        ls "$SWARM_HOME/projects" 2>/dev/null || echo "No projects found"
    fi
}

# Show current project info
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
with open('\''coordination/phase-status.json'\'', '\''r'\'') as f:
    data = json.load(f)
    phase = data.get('\''current_phase'\'', 1)
    print(f'\''Current Phase: {phase}/4'\'')
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

# Quick test function
swarm-quick-test() {
    if [ -f "$SWARM_HOME/bin/quick-test.sh" ]; then
        "$SWARM_HOME/bin/quick-test.sh"
    else
        echo "Quick test script not found"
        echo "Try: swarm-demo"
    fi
}

# Create and immediately start a project
swarm-create-and-start() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: swarm-create-and-start <name> \"<description>\""
        echo "Example: swarm-create-and-start myapp \"Build a chat application\""
        return 1
    fi
    
    swarm-new "$1" "$2"
    swarm-go "$1"
    echo ""
    echo "Starting swarm in 3 seconds..."
    echo "Press Ctrl+C to cancel"
    sleep 3
    swarm-start
}

echo "Swarm System ready! Type '\''swarm-help'\'' for available commands."
'

# Check if commands already exist and remove old version
if grep -q "Swarm System - Global Commands" "$SHELL_RC" 2>/dev/null; then
    echo "Removing old swarm commands..."
    # Create backup
    cp "$SHELL_RC" "$SHELL_RC.backup.$(date +%s)"
    # Remove old section
    sed -i.tmp '/# ============================================/,/^$/d' "$SHELL_RC" 2>/dev/null || \
    sed -i '' '/# ============================================/,/^$/d' "$SHELL_RC"
fi

# Add new commands
echo "$SWARM_COMMANDS" >> "$SHELL_RC"
echo "✓ Commands added to $SHELL_RC"

echo ""
echo "========================================="
echo "  Installation Complete!"
echo "========================================="
echo ""
echo "To activate the commands, run:"
echo "  source $SHELL_RC"
echo ""
echo "Main Commands (clear and descriptive):"
echo "  swarm-new <name> \"desc\"  - Create new project"
echo "  swarm-start              - Start swarm"
echo "  swarm-kanban             - Launch Kanban monitor"
echo "  swarm-resume             - Resume previous project"
echo "  swarm-existing <path>    - Import existing project"
echo "  swarm-help               - Show all commands"
echo ""
echo "Quick Test:"
echo "  swarm-demo               - Create and run demo"
echo "  swarm-test               - Run test project"
echo ""