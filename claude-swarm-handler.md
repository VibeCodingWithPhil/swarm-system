# Claude Swarm Command Handler

## How to Use the /swarm Command

When you want to start a new swarm project, simply type:

```
/swarm "Your project description here"
```

For example:
- `/swarm "Build a React dashboard with authentication and real-time data"`
- `/swarm "Create a REST API for a blog platform with comments"`
- `/swarm "Develop a machine learning model for image classification"`

## What Happens When You Use /swarm

1. **Project Analysis**: The system analyzes your prompt and determines:
   - Project type (webapp, api, ml, etc.)
   - Required features
   - Optimal terminal assignments

2. **Automatic Setup**: Creates:
   - 5 terminal todo lists
   - 4 development phases
   - Coordination files
   - Project workspace

3. **Terminal Launch**: Opens 5 terminals that:
   - Work on different aspects simultaneously
   - Coordinate through phases
   - Don't duplicate work
   - Auto-advance when phase completes

## Implementation Instructions for Claude

When a user types `/swarm "prompt"`, you should:

1. Extract the project requirements
2. Run: `swarm init project-name "prompt"`
3. Navigate to project: `cd swarm-system/projects/project-name`
4. Launch: `swarm start`

The system will handle everything else automatically!

## Example Workflow

```bash
# User types in Claude:
/swarm "Build an e-commerce platform with product catalog, cart, and checkout"

# Claude executes:
cd /path/to/swarm-system
./bin/swarm init ecommerce "Build an e-commerce platform with product catalog, cart, and checkout"
cd projects/ecommerce
../../../bin/swarm start

# Result: 5 terminals open and start building the project
```

## Templates Available

Quick templates for common projects:
- `swarm template webapp my-app` - Full-stack web application
- `swarm template api my-api` - REST API with database
- `swarm template ml my-model` - Machine learning project
- `swarm template cli my-tool` - Command-line tool
- `swarm template mobile my-app` - Mobile application

## Monitoring Progress

Once launched, monitor with:
- Phase controller terminal (shows all progress)
- `cat coordination/phase-status.json`
- Check individual todo files
- View logs in `logs/` directory