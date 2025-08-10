#!/bin/bash

# Swarm Kanban Launcher

KANBAN_DIR="$(cd "$(dirname "$0")" && pwd)"
SWARM_HOME="$(cd "$KANBAN_DIR/.." && pwd)"

echo "========================================" 
echo "  Starting Swarm Kanban Monitor"
echo "========================================"
echo ""

# Check if virtual environment exists
if [ ! -d "$KANBAN_DIR/venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv "$KANBAN_DIR/venv"
fi

# Activate virtual environment
source "$KANBAN_DIR/venv/bin/activate"

# Install requirements
echo "Installing dependencies..."
pip install -q -r "$KANBAN_DIR/requirements.txt"

# Find project to monitor
PROJECT_PATH=""

# Check if running from a project directory
if [ -f "swarm.config" ]; then
    PROJECT_PATH="$(pwd)"
elif [ -n "$1" ]; then
    # Project name provided
    PROJECT_PATH="$SWARM_HOME/projects/$1"
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "Error: Project '$1' not found"
        exit 1
    fi
fi

echo ""
echo "Kanban server starting..."
echo "Open your browser at: http://localhost:5555"
echo ""
echo "Press Ctrl+C to stop the server"
echo "========================================"
echo ""

# Start the server
if [ -n "$PROJECT_PATH" ]; then
    python "$KANBAN_DIR/server.py" "$PROJECT_PATH"
else
    python "$KANBAN_DIR/server.py"
fi