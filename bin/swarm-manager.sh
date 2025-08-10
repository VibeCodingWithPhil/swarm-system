#!/bin/bash

# Swarm Manager - Universal Project Development System
# Can be used for any project to coordinate 5 AI terminals

set -e

SWARM_HOME="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_CMD="$HOME/.claude/local/claude"
PROJECT_NAME=""
PROJECT_PATH=""
PROJECT_PROMPT=""

# Colors for output (disabled in terminal for compatibility)
if [[ -t 1 ]]; then
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    NC=''
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    NC=''
fi

show_help() {
    cat << EOF
========================================
  Swarm Manager - AI Development System
========================================

Usage: swarm [COMMAND] [OPTIONS]

Commands:
  init <project-name>     Initialize a new swarm project
  start                   Start swarm for current project
  resume                  Resume a previous project
  change "<description>"  Request changes to current project
  import <path> <name>    Import existing project
  enhance "<prompt>"      Enhance a project prompt
  status                  Show current swarm status
  kanban [project-name]   Launch real-time Kanban monitor
  clean                   Clean up all temporary files
  template <name>         Use a predefined template
  help                    Show this help message

Examples:
  swarm init my-app "Build a React dashboard with auth"
  swarm start
  swarm status
  swarm clean

Templates:
  webapp      - Full-stack web application
  api         - REST API with database
  cli         - Command-line tool
  ml          - Machine learning project
  mobile      - Mobile application
  blockchain  - Web3/blockchain project
  game        - Game development
  devops      - Infrastructure/DevOps

EOF
}

init_project() {
    local project_name="$1"
    local project_prompt="$2"
    
    if [ -z "$project_name" ]; then
        echo "Error: Project name required"
        echo "Usage: swarm init <project-name> \"<description>\""
        exit 1
    fi
    
    if [ -z "$project_prompt" ]; then
        echo "Error: Project description required"
        echo "Usage: swarm init <project-name> \"<description>\""
        exit 1
    fi
    
    echo "Initializing swarm project: $project_name"
    
    # Create project directory
    PROJECT_PATH="$SWARM_HOME/projects/$project_name"
    mkdir -p "$PROJECT_PATH"/{todo,coordination,logs,prompts,phases,workspace}
    
    # Generate project configuration
    cat > "$PROJECT_PATH/swarm.config" << EOF
PROJECT_NAME="$project_name"
PROJECT_PROMPT="$project_prompt"
CREATED_AT="$(date)"
TERMINALS=5
PHASES=4
STATUS="INITIALIZED"
EOF
    
    # Enhance prompt first
    enhanced_prompt=$(python3 "$SWARM_HOME/bin/prompt-enhancer.py" "$project_prompt" 2>/dev/null | grep -A 100 "ENHANCED PROMPT" | tail -n +3 || echo "$project_prompt")
    
    # Analyze project and create todos with enhanced prompt
    python3 "$SWARM_HOME/bin/analyze-project.py" "$project_name" "$enhanced_prompt" "$PROJECT_PATH"
    
    # Generate phase prompts
    python3 "$SWARM_HOME/bin/phase-prompter.py" "$PROJECT_PATH"
    
    echo "✓ Project initialized at: $PROJECT_PATH"
    echo ""
    echo "Next steps:"
    echo "  cd $PROJECT_PATH"
    echo "  swarm start"
}

start_swarm() {
    # Find project config in current directory or parent directories
    local current_dir="$(pwd)"
    local config_found=false
    
    while [ "$current_dir" != "/" ]; do
        if [ -f "$current_dir/swarm.config" ]; then
            source "$current_dir/swarm.config"
            PROJECT_PATH="$current_dir"
            config_found=true
            break
        fi
        current_dir="$(dirname "$current_dir")"
    done
    
    if [ "$config_found" = false ]; then
        echo "Error: No swarm project found in current directory"
        echo "Run 'swarm init' first to create a project"
        exit 1
    fi
    
    echo "Starting swarm for: $PROJECT_NAME"
    
    # Check existing code first
    python3 "$SWARM_HOME/bin/code-checker.py" "$PROJECT_PATH"
    
    # Update project history
    mkdir -p "$SWARM_HOME/config"
    python3 -c "
import json
from datetime import datetime
history_file = '$SWARM_HOME/config/project-history.json'
try:
    with open(history_file, 'r') as f:
        history = json.load(f)
except:
    history = []

entry = {
    'name': '$PROJECT_NAME',
    'path': '$PROJECT_PATH',
    'prompt': '$PROJECT_PROMPT',
    'created': datetime.now().isoformat(),
    'last_accessed': datetime.now().isoformat(),
    'completion': 0
}

# Update or add
found = False
for h in history:
    if h['path'] == '$PROJECT_PATH':
        h['last_accessed'] = datetime.now().isoformat()
        found = True
        break
if not found:
    history.insert(0, entry)

history = history[:20]  # Keep last 20

with open(history_file, 'w') as f:
    json.dump(history, f, indent=2)
" 2>/dev/null
    
    # Launch the final swarm system with all features
    bash "$SWARM_HOME/bin/launch-swarm-final.sh" "$PROJECT_PATH" "$PROJECT_NAME"
}

clean_project() {
    echo "Cleaning up swarm temporary files..."
    
    # Find and clean temporary files
    find "$SWARM_HOME/projects" -name "*.tmp" -delete 2>/dev/null || true
    find "$SWARM_HOME/projects" -name "launch-term-*.sh" -delete 2>/dev/null || true
    find "$SWARM_HOME/projects" -name "start-terminal-*.sh" -delete 2>/dev/null || true
    
    # Clean old logs (keep last 5)
    for project_dir in "$SWARM_HOME/projects"/*/logs; do
        if [ -d "$project_dir" ]; then
            ls -t "$project_dir"/*.log 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null || true
        fi
    done
    
    echo "✓ Cleanup complete"
}

show_status() {
    echo "Swarm Projects Status:"
    echo "======================"
    
    for project_dir in "$SWARM_HOME/projects"/*; do
        if [ -d "$project_dir" ] && [ -f "$project_dir/swarm.config" ]; then
            source "$project_dir/swarm.config"
            echo ""
            echo "Project: $PROJECT_NAME"
            echo "Status: $STATUS"
            
            if [ -f "$project_dir/coordination/phase-status.json" ]; then
                python3 -c "
import json
with open('$project_dir/coordination/phase-status.json', 'r') as f:
    data = json.load(f)
    phase = data.get('current_phase', 1)
    print(f'Current Phase: {phase}/4')
                " 2>/dev/null || echo "Phase data unavailable"
            fi
        fi
    done
    
    echo ""
    echo "To monitor projects in real-time:"
    echo "  swarm kanban [project-name]"
}

use_template() {
    local template_name="$1"
    local project_name="$2"
    
    if [ -z "$template_name" ] || [ -z "$project_name" ]; then
        echo "Usage: swarm template <template-name> <project-name>"
        exit 1
    fi
    
    # Load template
    local template_file="$SWARM_HOME/templates/${template_name}.template"
    if [ ! -f "$template_file" ]; then
        echo "Error: Template '$template_name' not found"
        echo "Available templates: webapp, api, cli, ml, mobile, blockchain, game, devops"
        exit 1
    fi
    
    source "$template_file"
    init_project "$project_name" "$TEMPLATE_PROMPT"
}

# Main command handling
case "${1:-}" in
    init)
        shift
        init_project "$@"
        ;;
    start)
        start_swarm
        ;;
    resume)
        bash "$SWARM_HOME/bin/swarm-resume.sh" "$@"
        ;;
    change)
        shift
        if [ -z "$1" ]; then
            echo "Usage: swarm change \"<change-description>\""
            exit 1
        fi
        # Find current project
        if [ -f "swarm.config" ]; then
            python3 "$SWARM_HOME/bin/change-manager.py" "." change "$@"
        else
            echo "Error: No swarm project in current directory"
            exit 1
        fi
        ;;
    import)
        shift
        if [ $# -lt 2 ]; then
            echo "Usage: swarm import <source-path> <project-name> [description]"
            exit 1
        fi
        python3 "$SWARM_HOME/bin/change-manager.py" import "$@"
        ;;
    enhance)
        shift
        if [ -z "$1" ]; then
            echo "Usage: swarm enhance \"<project-prompt>\""
            exit 1
        fi
        python3 "$SWARM_HOME/bin/prompt-enhancer.py" "$@"
        ;;
    clean)
        clean_project
        ;;
    status)
        show_status
        ;;
    template)
        shift
        use_template "$@"
        ;;
    kanban)
        shift
        bash "$SWARM_HOME/kanban/start-kanban.sh" "$@"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        if [ -z "$1" ]; then
            show_help
        else
            echo "Unknown command: $1"
            echo "Run 'swarm help' for usage information"
            exit 1
        fi
        ;;
esac