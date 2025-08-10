#!/bin/bash

# Swarm Dashboard Manager
# Handles starting and stopping the Kanban dashboard with the swarm

SWARM_HOME="$(cd "$(dirname "$0")/.." && pwd)"
KANBAN_DIR="$SWARM_HOME/kanban"
PROJECT_PATH="$1"
ACTION="${2:-start}"

# Function to start dashboard
start_dashboard() {
    echo "📊 Starting Swarm Kanban Dashboard..."
    
    cd "$KANBAN_DIR"
    
    # Check if Node.js is available for Electron app
    if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
        echo "🖥️  Launching Electron dashboard..."
        
        # Install dependencies if needed
        if [ ! -d "node_modules" ]; then
            echo "Installing dashboard dependencies..."
            npm install --silent
        fi
        
        # Start Electron app in background
        npm start > /dev/null 2>&1 &
        DASHBOARD_PID=$!
        
        # Save PID for cleanup
        echo $DASHBOARD_PID > "$PROJECT_PATH/.dashboard.pid"
        
        echo "✅ Dashboard launched (Electron app)"
        echo "   The dashboard window should open automatically"
        
    else
        echo "🌐 Node.js not found, using browser dashboard..."
        
        # Fallback to Python/Flask server
        if [ ! -d "venv" ]; then
            python3 -m venv venv
        fi
        
        source venv/bin/activate
        pip install -q -r requirements.txt
        
        # Start Flask server with project path
        python server.py "$PROJECT_PATH" > /dev/null 2>&1 &
        SERVER_PID=$!
        
        # Save PID for cleanup
        echo $SERVER_PID > "$PROJECT_PATH/.kanban.pid"
        
        deactivate
        
        sleep 2
        echo "✅ Dashboard running at http://localhost:5555"
        
        # Open in browser based on OS
        case "$OSTYPE" in
            darwin*)  open "http://localhost:5555" ;;
            linux*)   xdg-open "http://localhost:5555" 2>/dev/null || echo "   Please open http://localhost:5555 in your browser" ;;
            msys*|cygwin*)    start "http://localhost:5555" ;;
            *)        echo "   Please open http://localhost:5555 in your browser" ;;
        esac
    fi
}

# Function to stop dashboard
stop_dashboard() {
    echo "🛑 Stopping Swarm Kanban Dashboard..."
    
    # Stop Electron app if running
    if [ -f "$PROJECT_PATH/.dashboard.pid" ]; then
        DASHBOARD_PID=$(cat "$PROJECT_PATH/.dashboard.pid")
        if ps -p $DASHBOARD_PID > /dev/null 2>&1; then
            kill $DASHBOARD_PID 2>/dev/null
            sleep 1
            # Force kill if needed
            if ps -p $DASHBOARD_PID > /dev/null 2>&1; then
                kill -9 $DASHBOARD_PID 2>/dev/null
            fi
        fi
        rm -f "$PROJECT_PATH/.dashboard.pid"
    fi
    
    # Stop Flask server if running
    if [ -f "$PROJECT_PATH/.kanban.pid" ]; then
        SERVER_PID=$(cat "$PROJECT_PATH/.kanban.pid")
        if ps -p $SERVER_PID > /dev/null 2>&1; then
            kill $SERVER_PID 2>/dev/null
        fi
        rm -f "$PROJECT_PATH/.kanban.pid"
    fi
    
    # Clean up any orphaned processes
    pkill -f "electron.*swarm-kanban" 2>/dev/null
    pkill -f "python.*server.py.*$PROJECT_PATH" 2>/dev/null
    
    # Clean up Electron PID file if exists
    rm -f "$KANBAN_DIR/.electron.pid" 2>/dev/null
    
    echo "✅ Dashboard stopped"
}

# Main execution
case "$ACTION" in
    start)
        start_dashboard
        ;;
    stop)
        stop_dashboard
        ;;
    restart)
        stop_dashboard
        sleep 2
        start_dashboard
        ;;
    *)
        echo "Usage: $0 <project_path> {start|stop|restart}"
        exit 1
        ;;
esac