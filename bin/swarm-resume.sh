#!/bin/bash

# Swarm Resume - Continue interrupted projects

SWARM_HOME="$(cd "$(dirname "$0")/.." && pwd)"

echo "========================================"
echo "    Swarm Resume - Project Selector"
echo "========================================"
echo ""

# Create project history file if doesn't exist
HISTORY_FILE="$SWARM_HOME/config/project-history.json"
mkdir -p "$SWARM_HOME/config"

if [ ! -f "$HISTORY_FILE" ]; then
    echo "[]" > "$HISTORY_FILE"
fi

# Update project history
update_history() {
    local project_path="$1"
    local project_name="$2"
    
    python3 -c "
import json
from datetime import datetime
from pathlib import Path

history_file = '$HISTORY_FILE'
project_path = '$project_path'
project_name = '$project_name'

# Load history
try:
    with open(history_file, 'r') as f:
        history = json.load(f)
except:
    history = []

# Check if project exists
config_file = Path(project_path) / 'swarm.config'
if not config_file.exists():
    exit(1)

# Get project info
with open(config_file, 'r') as f:
    config_lines = f.readlines()
    
project_prompt = ''
for line in config_lines:
    if line.startswith('PROJECT_PROMPT='):
        project_prompt = line.split('=', 1)[1].strip().strip('\"')
        break

# Check completion
completion = 0
phase_file = Path(project_path) / 'coordination' / 'phase-status.json'
if phase_file.exists():
    with open(phase_file, 'r') as f:
        phase_data = json.load(f)
        current_phase = phase_data.get('current_phase', 1)
        completion = ((current_phase - 1) / 4) * 100

# Update or add entry
found = False
for entry in history:
    if entry['path'] == project_path:
        entry['last_accessed'] = datetime.now().isoformat()
        entry['completion'] = completion
        found = True
        break

if not found:
    history.append({
        'name': project_name,
        'path': project_path,
        'prompt': project_prompt,
        'created': datetime.now().isoformat(),
        'last_accessed': datetime.now().isoformat(),
        'completion': completion
    })

# Sort by last accessed (most recent first)
history.sort(key=lambda x: x['last_accessed'], reverse=True)

# Keep only last 20 projects
history = history[:20]

# Save
with open(history_file, 'w') as f:
    json.dump(history, f, indent=2)
"
}

# Show project list
show_projects() {
    python3 -c "
import json
from datetime import datetime

history_file = '$HISTORY_FILE'

try:
    with open(history_file, 'r') as f:
        history = json.load(f)
except:
    print('No projects found. Start a new project with: swarm init')
    exit(1)

if not history:
    print('No projects found. Start a new project with: swarm init')
    exit(1)

print('Recent Projects:')
print('=' * 60)

for i, project in enumerate(history, 1):
    # Calculate time ago
    last_accessed = datetime.fromisoformat(project['last_accessed'])
    now = datetime.now()
    delta = now - last_accessed
    
    if delta.days > 0:
        time_ago = f'{delta.days} days ago'
    elif delta.seconds > 3600:
        hours = delta.seconds // 3600
        time_ago = f'{hours} hours ago'
    elif delta.seconds > 60:
        minutes = delta.seconds // 60
        time_ago = f'{minutes} minutes ago'
    else:
        time_ago = 'just now'
    
    print(f'{i}. {project[\"name\"]} ({project[\"completion\"]:.0f}% complete) - {time_ago}')
    print(f'   {project[\"prompt\"][:60]}...')
    print(f'   Path: {project[\"path\"]}')
    print()

print('=' * 60)
"
}

# Resume specific project
resume_project() {
    local project_path="$1"
    
    if [ ! -d "$project_path" ]; then
        echo "Error: Project not found at $project_path"
        exit 1
    fi
    
    cd "$project_path"
    
    echo "Resuming project at: $project_path"
    echo ""
    
    # Check existing code
    echo "Analyzing existing code..."
    python3 "$SWARM_HOME/bin/code-checker.py" "$project_path"
    
    echo ""
    echo "Checking project status..."
    
    # Show current phase
    python3 -c "
import json
phase_file = '$project_path/coordination/phase-status.json'
try:
    with open(phase_file, 'r') as f:
        data = json.load(f)
        phase = data.get('current_phase', 1)
        print(f'Current Phase: {phase}/4')
        
        # Show terminal status
        phase_key = f'phase_{phase}'
        if phase_key in data:
            print('\\nTerminal Status:')
            for tid, tdata in data[phase_key]['terminals'].items():
                print(f'  Terminal {tid}: {tdata[\"status\"]} ({tdata[\"progress\"]}%)')
except:
    print('Phase data not found')
"
    
    echo ""
    read -p "Resume this project? (y/n) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Update history
        project_name=$(basename "$project_path")
        update_history "$project_path" "$project_name"
        
        # Launch with enhanced script
        bash "$SWARM_HOME/bin/launch-swarm-enhanced.sh" "$project_path" "$project_name"
    fi
}

# Main menu
if [ "$1" == "--list" ] || [ -z "$1" ]; then
    show_projects
    echo ""
    echo "To resume a project:"
    echo "  swarm-resume <number>  # Resume project by number"
    echo "  swarm-resume <path>    # Resume project by path"
    echo ""
    
    read -p "Enter project number to resume (or q to quit): " choice
    
    if [ "$choice" == "q" ] || [ "$choice" == "Q" ]; then
        exit 0
    fi
    
    # Get project path by number
    project_path=$(python3 -c "
import json
try:
    with open('$HISTORY_FILE', 'r') as f:
        history = json.load(f)
    choice = int('$choice') - 1
    if 0 <= choice < len(history):
        print(history[choice]['path'])
except:
    pass
")
    
    if [ -n "$project_path" ]; then
        resume_project "$project_path"
    else
        echo "Invalid selection"
        exit 1
    fi
    
elif [ -d "$1" ]; then
    # Resume by path
    resume_project "$1"
    
else
    # Resume by number
    project_path=$(python3 -c "
import json
try:
    with open('$HISTORY_FILE', 'r') as f:
        history = json.load(f)
    choice = int('$1') - 1
    if 0 <= choice < len(history):
        print(history[choice]['path'])
except:
    pass
")
    
    if [ -n "$project_path" ]; then
        resume_project "$project_path"
    else
        echo "Invalid project number or path: $1"
        exit 1
    fi
fi