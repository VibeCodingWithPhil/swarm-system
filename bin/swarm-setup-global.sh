#!/bin/bash

# Swarm System - Global Command Setup Script

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
echo "  Swarm System - Global Setup"
echo "========================================="
echo ""
echo "Installing global commands to: $SHELL_RC"
echo "Swarm home: $SWARM_HOME"
echo ""

# Create the commands section
SWARM_COMMANDS='
# ============================================
# Swarm System - Global Commands
# ============================================

# Main swarm command
alias swarm="'$SWARM_HOME'/bin/swarm-manager.sh"

# Quick commands
alias sw="swarm"                                    # Even shorter
alias sws="swarm start"                            # Start swarm in current dir
alias swk="swarm kanban"                           # Launch Kanban monitor
alias swn="swarm init"                             # New project
alias swr="swarm resume"                           # Resume project
alias swst="swarm status"                          # Show all projects
alias swc="swarm change"                           # Request changes

# Quick project creation with templates
alias sw-web="swarm template webapp"               # Create web app
alias sw-api="swarm template api"                  # Create API
alias sw-cli="swarm template cli"                  # Create CLI tool
alias sw-ml="swarm template ml"                    # Create ML project

# Testing shortcuts
alias swtest="cd '$SWARM_HOME'/projects/swarm-enhancement && swarm start"
alias swdemo="swarm init demo \"Build a simple todo app with React\" && cd '$SWARM_HOME'/projects/demo && swarm start"

# Navigation shortcuts  
alias swcd="cd '$SWARM_HOME'"                      # Go to swarm home
alias swp="cd '$SWARM_HOME'/projects"              # Go to projects
alias swls="ls -la '$SWARM_HOME'/projects"         # List projects

# Kanban shortcuts
alias kanban="'$SWARM_HOME'/kanban/start-kanban.sh"
alias kb="kanban"                                  # Even shorter

# Helper functions
swhelp() {
    echo "Swarm System - Quick Commands"
    echo "============================="
    echo ""
    echo "Project Management:"
    echo "  sw/swarm         - Main swarm command"
    echo "  swn <name> \"desc\" - Create new project"
    echo "  sws              - Start swarm (current dir)"
    echo "  swk [project]    - Launch Kanban monitor"
    echo "  swr              - Resume previous project"
    echo "  swst             - Show all projects status"
    echo "  swc \"request\"    - Request changes"
    echo ""
    echo "Quick Templates:"
    echo "  sw-web <name>    - Create web application"
    echo "  sw-api <name>    - Create REST API"
    echo "  sw-cli <name>    - Create CLI tool"
    echo "  sw-ml <name>     - Create ML project"
    echo ""
    echo "Navigation:"
    echo "  swcd             - Go to swarm home"
    echo "  swp              - Go to projects directory"
    echo "  swls             - List all projects"
    echo ""
    echo "Testing:"
    echo "  swtest           - Test with swarm-enhancement"
    echo "  swdemo           - Create and run demo project"
    echo ""
    echo "Monitoring:"
    echo "  kb/kanban [proj] - Launch Kanban interface"
    echo ""
    echo "Help:"
    echo "  swhelp           - Show this help"
    echo "  swarm help       - Show detailed help"
}

# Quick project starter - creates and starts immediately
swquick() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: swquick <name> \"<description>\""
        echo "Example: swquick myapp \"Build a chat application\""
        return 1
    fi
    
    swarm init "$1" "$2"
    cd "'$SWARM_HOME'/projects/$1"
    echo ""
    echo "Starting swarm in 3 seconds..."
    echo "Press Ctrl+C to cancel"
    sleep 3
    swarm start
}

# Go to a project directory
swgo() {
    if [ -z "$1" ]; then
        echo "Usage: swgo <project-name>"
        echo "Available projects:"
        ls "'$SWARM_HOME'/projects"
        return 1
    fi
    
    if [ -d "'$SWARM_HOME'/projects/$1" ]; then
        cd "'$SWARM_HOME'/projects/$1"
        echo "Switched to project: $1"
        echo "Run '\''sws'\'' to start the swarm"
    else
        echo "Project not found: $1"
        echo "Available projects:"
        ls "'$SWARM_HOME'/projects"
    fi
}

# Clean all temporary files
swclean() {
    echo "Cleaning swarm temporary files..."
    swarm clean
    echo "Done!"
}

# Show current project info
swinfo() {
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
    else
        echo "Not in a swarm project directory"
        echo "Use '\''swgo <project>'\'' to navigate to a project"
    fi
}

# Quick test run
swrun() {
    echo "Quick Swarm Test Run"
    echo "==================="
    echo ""
    echo "This will create a test project and start the swarm."
    echo "Press Enter to continue or Ctrl+C to cancel..."
    read
    
    TEST_NAME="test-$(date +%s)"
    swarm init "$TEST_NAME" "Build a simple calculator web app with React"
    cd "'$SWARM_HOME'/projects/$TEST_NAME"
    swarm start
}

echo "Swarm System commands loaded! Type '\''swhelp'\'' for quick help."
'

# Check if commands already exist
if grep -q "Swarm System - Global Commands" "$SHELL_RC" 2>/dev/null; then
    echo "Swarm commands already installed in $SHELL_RC"
    echo ""
    echo "To update, remove the Swarm section from $SHELL_RC and run this again."
else
    # Add to shell RC file
    echo "$SWARM_COMMANDS" >> "$SHELL_RC"
    echo "✓ Commands added to $SHELL_RC"
fi

echo ""
echo "========================================="
echo "  Installation Complete!"
echo "========================================="
echo ""
echo "To activate the commands, run:"
echo "  source $SHELL_RC"
echo ""
echo "Or open a new terminal window."
echo ""
echo "Quick Commands Available:"
echo "  sw       - Main swarm command (short)"
echo "  sws      - Start swarm in current directory"
echo "  swk      - Launch Kanban monitor"
echo "  swn      - Create new project"
echo "  swquick  - Create and immediately start project"
echo "  swgo     - Navigate to project"
echo "  swhelp   - Show all commands"
echo ""
echo "Test it with:"
echo "  swdemo   - Create and run a demo project"
echo "  swtest   - Run swarm-enhancement test"
echo ""