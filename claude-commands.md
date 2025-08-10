# Claude Swarm Commands Implementation

## Setup Instructions for Claude

Please implement these two commands in your session:

### 1. /swarm Command - Create New Projects

When I type `/swarm "project description"`, execute:

```python
import re
import subprocess
import os
from datetime import datetime

def handle_swarm_command(user_input):
    match = re.match(r'/swarm\s+"([^"]+)"', user_input)
    if not match:
        return None
    
    description = match.group(1)
    
    # Generate project name
    project_name = re.sub(r'[^a-z0-9\s]', '', description.lower())
    project_name = '-'.join(project_name.split()[:3])
    if not project_name:
        project_name = f"project-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
    
    swarm_path = "~/Documents/OpenUp/ZED Test/GPT5/OpenSwarm/swarm-system"
    
    commands = [
        f'cd "{swarm_path}"',
        f'./bin/swarm init {project_name} "{description}"',
        f'cd projects/{project_name}',
        '# Analyzing existing code...',
        f'python3 ../../bin/code-checker.py .',
        '# Launching swarm with Docker testing...',
        f'../../bin/launch-swarm-enhanced.sh . {project_name}'
    ]
    
    return {
        'project_name': project_name,
        'description': description,
        'commands': commands
    }
```

### 2. /swarm-resume Command - Continue Projects

When I type `/swarm-resume` or `/swarm-resume <number>`, execute:

```python
def handle_swarm_resume_command(user_input):
    import json
    import os
    from datetime import datetime
    
    swarm_path = "~/Documents/OpenUp/ZED Test/GPT5/OpenSwarm/swarm-system"
    history_file = f"{swarm_path}/config/project-history.json"
    
    # Parse command
    if user_input.strip() == '/swarm-resume':
        # Show list
        try:
            with open(os.path.expanduser(history_file), 'r') as f:
                history = json.load(f)
            
            if not history:
                return "No projects to resume. Create one with /swarm"
            
            output = ["Recent Projects:", "=" * 60]
            for i, project in enumerate(history[:10], 1):
                last_accessed = datetime.fromisoformat(project['last_accessed'])
                now = datetime.now()
                delta = now - last_accessed
                
                if delta.days > 0:
                    time_ago = f'{delta.days} days ago'
                elif delta.seconds > 3600:
                    time_ago = f'{delta.seconds // 3600} hours ago'
                elif delta.seconds > 60:
                    time_ago = f'{delta.seconds // 60} minutes ago'
                else:
                    time_ago = 'just now'
                
                output.append(f"{i}. {project['name']} ({project.get('completion', 0):.0f}% complete) - {time_ago}")
                output.append(f"   {project['prompt'][:60]}...")
            
            output.append("\nTo resume: /swarm-resume <number>")
            return '\n'.join(output)
            
        except FileNotFoundError:
            return "No project history found. Create a project with /swarm first."
    
    # Resume specific project
    match = re.match(r'/swarm-resume\s+(\d+)', user_input)
    if match:
        project_num = int(match.group(1)) - 1
        
        try:
            with open(os.path.expanduser(history_file), 'r') as f:
                history = json.load(f)
            
            if 0 <= project_num < len(history):
                project = history[project_num]
                commands = [
                    f'cd "{project["path"]}"',
                    '# Checking existing code...',
                    f'python3 {swarm_path}/bin/code-checker.py .',
                    '# Resuming swarm...',
                    f'{swarm_path}/bin/launch-swarm-enhanced.sh . "{project["name"]}"'
                ]
                
                return {
                    'project': project,
                    'commands': commands,
                    'message': f"Resuming {project['name']} from {project.get('completion', 0):.0f}% completion"
                }
            else:
                return "Invalid project number"
                
        except FileNotFoundError:
            return "No project history found"
    
    return "Usage: /swarm-resume or /swarm-resume <number>"
```

## Command Examples

### Creating New Projects:
```
/swarm "Build a REST API with user authentication and file uploads"
/swarm "Create a React dashboard with real-time data visualization"
/swarm "Develop a CLI tool for managing Docker containers"
```

### Resuming Projects:
```
/swarm-resume                    # Shows list of recent projects
/swarm-resume 1                   # Resumes the most recent project
/swarm-resume 3                   # Resumes the 3rd project in the list
```

## What These Commands Do

### /swarm Features:
1. **Analyzes Requirements** - Understands project needs
2. **Checks Existing Code** - Prevents duplicate work
3. **Creates Docker Tests** - Automatic test setup
4. **Launches 5 Terminals** - Coordinated development
5. **Tracks Progress** - Saves to history

### /swarm-resume Features:
1. **Shows Recent Projects** - With completion percentage
2. **Time Tracking** - Shows when last accessed
3. **Code Analysis** - Checks what's already done
4. **Continues From Checkpoint** - No repeated work
5. **Preserves Context** - Remembers project state

## Implementation Benefits

- **No Duplicate Work**: Always checks existing code first
- **Docker Testing**: All tests run in isolated containers
- **Terminal Fix**: Uses Basic profile (no highlighting)
- **Smart Resume**: Continue exactly where you left off
- **Progress Tracking**: See completion percentage
- **History Management**: Last 20 projects saved

## Terminal Display Fix

The enhanced launcher now:
- Sets terminal to Basic profile (no highlighting)
- Uses `export TERM=xterm-256color`
- Clears screen before starting
- Properly formats output

## Docker Testing

Every project now includes:
- `docker-compose.test.yml` - Test configuration
- `Dockerfile.test` - Test container setup
- Automatic test detection for:
  - Node.js (npm test)
  - Python (pytest)
  - Go (go test)

Run tests with:
```bash
docker-compose -f docker-compose.test.yml up
```

---

Please implement these commands so I can use `/swarm` and `/swarm-resume` directly!