#!/bin/bash

# Swarm System - Clean Installation Script
# Properly handles paths with spaces

set -e

# Get the real path of swarm-system (handles spaces correctly)
SCRIPT_PATH="${BASH_SOURCE[0]}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
SWARM_HOME="$(cd "$SCRIPT_DIR/.." && pwd)"

# Detect shell
if [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
    SHELL_TYPE="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
    SHELL_TYPE="bash"
else
    SHELL_CONFIG="$HOME/.profile"
    SHELL_TYPE="sh"
fi

echo "==========================================="
echo "   Swarm System Installation"
echo "==========================================="
echo ""
echo "Installing to: $SHELL_CONFIG"
echo "Swarm location: $SWARM_HOME"
echo ""

# Clean up old installations
echo "Cleaning up old installations..."
# Remove old swarm sections from shell config
if [ -f "$SHELL_CONFIG" ]; then
    cp "$SHELL_CONFIG" "$SHELL_CONFIG.backup.$(date +%s)"
    # Remove all old swarm-related configurations
    grep -v "Swarm System" "$SHELL_CONFIG" | grep -v "swarm-" | grep -v "SWARM_HOME" > "$SHELL_CONFIG.tmp" || true
    mv "$SHELL_CONFIG.tmp" "$SHELL_CONFIG"
fi

# Also clean bashrc if using zsh
if [ "$SHELL_TYPE" = "zsh" ] && [ -f "$HOME/.bashrc" ]; then
    grep -v "Swarm System" "$HOME/.bashrc" | grep -v "swarm-" | grep -v "SWARM_HOME" > "$HOME/.bashrc.tmp" || true
    mv "$HOME/.bashrc.tmp" "$HOME/.bashrc"
fi

# Write new configuration
echo "" >> "$SHELL_CONFIG"
echo "# ============================================" >> "$SHELL_CONFIG"
echo "# Swarm System Commands" >> "$SHELL_CONFIG"
echo "# Installed: $(date)" >> "$SHELL_CONFIG"
echo "# ============================================" >> "$SHELL_CONFIG"
echo "" >> "$SHELL_CONFIG"

# Export SWARM_HOME with proper quoting
echo "export SWARM_HOME=\"$SWARM_HOME\"" >> "$SHELL_CONFIG"
echo "" >> "$SHELL_CONFIG"

# Create functions instead of aliases (more reliable with spaces)
cat >> "$SHELL_CONFIG" << 'COMMANDS'
# Main swarm command
swarm() {
    "$SWARM_HOME/bin/swarm-manager.sh" "$@"
}

# Project management
swarm-new() {
    "$SWARM_HOME/bin/swarm-manager.sh" init "$@"
}

swarm-start() {
    "$SWARM_HOME/bin/swarm-manager.sh" start "$@"
}

swarm-kanban() {
    "$SWARM_HOME/bin/swarm-manager.sh" kanban "$@"
}

swarm-resume() {
    "$SWARM_HOME/bin/swarm-manager.sh" resume "$@"
}

swarm-status() {
    "$SWARM_HOME/bin/swarm-manager.sh" status "$@"
}

swarm-existing() {
    "$SWARM_HOME/bin/swarm-manager.sh" import "$@"
}

swarm-change() {
    "$SWARM_HOME/bin/swarm-manager.sh" change "$@"
}

swarm-clean() {
    "$SWARM_HOME/bin/swarm-manager.sh" clean "$@"
}

# Templates
swarm-new-webapp() {
    "$SWARM_HOME/bin/swarm-manager.sh" template webapp "$@"
}

swarm-new-api() {
    "$SWARM_HOME/bin/swarm-manager.sh" template api "$@"
}

swarm-new-cli() {
    "$SWARM_HOME/bin/swarm-manager.sh" template cli "$@"
}

swarm-new-ml() {
    "$SWARM_HOME/bin/swarm-manager.sh" template ml "$@"
}

swarm-new-mobile() {
    "$SWARM_HOME/bin/swarm-manager.sh" template mobile "$@"
}

swarm-new-game() {
    "$SWARM_HOME/bin/swarm-manager.sh" template game "$@"
}

# Navigation
swarm-home() {
    cd "$SWARM_HOME"
}

swarm-projects() {
    cd "$SWARM_HOME/projects"
}

swarm-list() {
    if [ -d "$SWARM_HOME/projects" ]; then
        ls -la "$SWARM_HOME/projects"
    else
        echo "No projects directory found"
    fi
}

swarm-go() {
    if [ -z "$1" ]; then
        echo "Usage: swarm-go <project-name>"
        echo "Available projects:"
        swarm-list
        return 1
    fi
    
    if [ -d "$SWARM_HOME/projects/$1" ]; then
        cd "$SWARM_HOME/projects/$1"
        echo "Switched to project: $1"
        echo "Run 'swarm-start' to launch"
    else
        echo "Project not found: $1"
        swarm-list
    fi
}

# Quick tests
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
        echo "Test project not found. Run swarm-demo first."
    fi
}

swarm-quick-test() {
    "$SWARM_HOME/bin/quick-test.sh"
}

# Info
swarm-info() {
    if [ -f "swarm.config" ]; then
        echo "Current Swarm Project"
        echo "===================="
        cat swarm.config
    else
        echo "Not in a swarm project directory"
        echo "Use 'swarm-go <project>' to navigate"
    fi
}

swarm-help() {
    echo "Swarm System Commands"
    echo "===================="
    echo ""
    echo "PROJECT MANAGEMENT:"
    echo "  swarm-new <name> \"desc\"     - Create new project"
    echo "  swarm-start                 - Start swarm"
    echo "  swarm-kanban                - Launch Kanban monitor"
    echo "  swarm-resume                - Resume previous work"
    echo "  swarm-status                - Show all projects"
    echo "  swarm-existing <path> <name> - Import existing code"
    echo "  swarm-change \"desc\"         - Request changes"
    echo "  swarm-clean                 - Clean temp files"
    echo ""
    echo "TEMPLATES:"
    echo "  swarm-new-webapp <name>     - Web application"
    echo "  swarm-new-api <name>        - REST API"
    echo "  swarm-new-cli <name>        - CLI tool"
    echo "  swarm-new-ml <name>         - ML project"
    echo ""
    echo "NAVIGATION:"
    echo "  swarm-home                  - Go to swarm home"
    echo "  swarm-projects              - Go to projects"
    echo "  swarm-list                  - List projects"
    echo "  swarm-go <name>             - Go to project"
    echo ""
    echo "TESTING:"
    echo "  swarm-demo                  - Quick demo"
    echo "  swarm-test                  - Run test"
    echo "  swarm-quick-test            - Interactive test"
    echo ""
    echo "INFO:"
    echo "  swarm-help                  - This help"
    echo "  swarm-info                  - Project info"
    echo ""
    echo "Location: $SWARM_HOME"
}

COMMANDS

echo ""
echo "✅ Installation Complete!"
echo ""
echo "==========================================="
echo "   Next Steps"
echo "==========================================="
echo ""
echo "1. Reload your shell:"
echo "   source $SHELL_CONFIG"
echo ""
echo "   Or open a new terminal window"
echo ""
echo "2. Test installation:"
echo "   swarm-help"
echo ""
echo "3. Run demo:"
echo "   swarm-demo"
echo ""
echo "All commands now work correctly with spaces in paths!"