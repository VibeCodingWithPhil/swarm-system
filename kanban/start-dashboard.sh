#!/bin/bash

# Swarm Kanban Dashboard Launcher
# Detects OS and launches the appropriate dashboard

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install npm packages if needed
install_deps() {
    if [ ! -d "node_modules" ]; then
        echo "Installing dashboard dependencies..."
        npm install
    fi
}

# Function to start Electron dashboard
start_electron() {
    echo "Starting Swarm Kanban Dashboard..."
    
    # Install dependencies if needed
    install_deps
    
    # Start Electron app
    npm start &
    ELECTRON_PID=$!
    echo $ELECTRON_PID > "$SCRIPT_DIR/.electron.pid"
    
    echo "Dashboard started with PID: $ELECTRON_PID"
    
    # Return the PID for the parent process to track
    echo $ELECTRON_PID
}

# Function to stop the dashboard
stop_dashboard() {
    echo "Stopping Swarm Kanban Dashboard..."
    
    # Read PID from file if it exists
    if [ -f "$SCRIPT_DIR/.electron.pid" ]; then
        ELECTRON_PID=$(cat "$SCRIPT_DIR/.electron.pid")
        
        # Check if process is still running
        if ps -p $ELECTRON_PID > /dev/null 2>&1; then
            kill $ELECTRON_PID 2>/dev/null
            
            # Wait for graceful shutdown
            sleep 2
            
            # Force kill if still running
            if ps -p $ELECTRON_PID > /dev/null 2>&1; then
                kill -9 $ELECTRON_PID 2>/dev/null
            fi
        fi
        
        rm -f "$SCRIPT_DIR/.electron.pid"
    fi
    
    # Also kill any orphaned node processes
    pkill -f "electron.*swarm-kanban" 2>/dev/null
    
    # Kill Flask server if running
    pkill -f "python.*server.py" 2>/dev/null
}

# Detect OS and check requirements
detect_os() {
    case "$(uname -s)" in
        Darwin*)
            OS="macOS"
            ;;
        Linux*)
            OS="Linux"
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            OS="Windows"
            ;;
        *)
            OS="Unknown"
            ;;
    esac
    
    echo "Detected OS: $OS"
}

# Check Node.js and npm
check_requirements() {
    if ! command_exists node; then
        echo "Error: Node.js is not installed. Please install Node.js first."
        echo "Visit: https://nodejs.org/"
        exit 1
    fi
    
    if ! command_exists npm; then
        echo "Error: npm is not installed. Please install npm first."
        exit 1
    fi
    
    echo "Node.js version: $(node --version)"
    echo "npm version: $(npm --version)"
}

# Main execution
main() {
    case "$1" in
        start)
            detect_os
            check_requirements
            start_electron
            ;;
        stop)
            stop_dashboard
            ;;
        restart)
            stop_dashboard
            sleep 2
            detect_os
            check_requirements
            start_electron
            ;;
        *)
            echo "Usage: $0 {start|stop|restart}"
            exit 1
            ;;
    esac
}

# Handle script termination
trap stop_dashboard EXIT SIGINT SIGTERM

main "$@"