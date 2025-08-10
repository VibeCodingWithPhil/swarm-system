# 🐝 Swarm System - AI Development Orchestration

> Coordinate 5 AI terminals to build any project automatically with phase-based development

## What is Swarm?

Swarm is a revolutionary development system that orchestrates multiple Claude AI instances to work collaboratively on any software project. It automatically:
- Analyzes your project requirements
- Divides work among 5 specialized terminals
- Manages development phases
- Prevents duplicate work
- Coordinates progress automatically

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/VibeCodingWithPhil/swarm-system.git
cd swarm-system

# Install clear, descriptive commands
./bin/swarm-setup-global-clear.sh
source ~/.bashrc  # or ~/.zshrc
```

### Quick Test (30 seconds!)

```bash
# Instant demo - creates todo app and starts swarm
swarm-demo

# Or interactive test
./bin/quick-test.sh
```

### Create Your First Project

```bash
# Clear, descriptive commands:
swarm-new my-app "Build a React dashboard"
swarm-go my-app
swarm-start

# Monitor in another terminal:
swarm-kanban
```

### Import Existing Project

```bash
swarm-existing ./my-code my-project
swarm-go my-project
swarm-start
```

This launches 5 AI terminals that build your project collaboratively!

## 🎯 Features

- **Automatic Task Distribution**: Intelligently assigns tasks to 5 terminals
- **Phase-Based Development**: 4 phases from setup to deployment
- **No Duplicate Work**: Terminals coordinate to avoid overlap
- **Any Project Type**: Web apps, APIs, ML models, CLIs, games, etc.
- **Progress Tracking**: Real-time status monitoring
- **Template Library**: Pre-configured templates for common projects

## 📋 How It Works

1. **Describe Your Project**
   ```bash
   swarm init my-project "Your project description"
   ```

2. **System Analyzes Requirements**
   - Detects project type
   - Identifies features needed
   - Creates development phases

3. **Generates Terminal Tasks**
   - Terminal 1: Core architecture
   - Terminal 2: Data layer
   - Terminal 3: Business logic
   - Terminal 4: Interface/API
   - Terminal 5: Testing/DevOps

4. **Launches Coordinated Development**
   - Each terminal works on assigned tasks
   - Automatic phase progression
   - Real-time coordination

## 🛠️ Commands

```bash
swarm init <name> "<description>"  # Create new project
swarm start                        # Launch swarm for current project
swarm status                       # Show all projects status
swarm template <type> <name>      # Use a template
swarm clean                        # Clean temporary files
swarm help                         # Show help
```

## 📚 Templates

Use pre-built templates for common projects:

```bash
swarm template webapp my-app      # Full-stack web application
swarm template api my-api         # REST API with database
swarm template ml my-model        # Machine learning project
swarm template cli my-tool        # Command-line tool
swarm template mobile my-app      # Mobile application
swarm template game my-game       # Game development
swarm template blockchain my-dapp # Web3/blockchain project
```

## 🔄 Development Phases

### Phase 1: Foundation & Setup
- Project structure
- Core architecture
- Development environment
- Basic configuration

### Phase 2: Core Features
- Main functionality
- Business logic
- Data models
- API endpoints

### Phase 3: Advanced Features
- Additional features
- Integrations
- Optimizations
- Security

### Phase 4: Polish & Deployment
- Testing
- Documentation
- Performance tuning
- Deployment setup

## 📊 Monitoring Progress

### Phase Controller
A dedicated terminal shows real-time progress:
- Current phase and tasks
- Terminal status
- Completion percentage
- Phase advancement

### Status Files
- `coordination/phase-status.json` - Current phase and progress
- `todo/terminal-*.md` - Individual terminal tasks
- `logs/` - Detailed execution logs

## 🤝 Terminal Coordination

Terminals coordinate through:
1. **Phase Status File**: Tracks current tasks and progress
2. **Todo Lists**: Detailed tasks for each terminal
3. **Master Checklist**: Overall project tracking
4. **Automatic Advancement**: Moves to next phase when ready

## 🎨 Custom Projects

For projects not covered by templates:

```bash
swarm init my-custom-app "Detailed description of what you want to build"
```

The system will:
- Analyze your requirements
- Create custom task distribution
- Generate appropriate phases
- Start building immediately

## 📁 Project Structure

```
your-project/
├── todo/                 # Terminal task lists
│   ├── terminal-1.md
│   ├── terminal-2.md
│   ├── terminal-3.md
│   ├── terminal-4.md
│   ├── terminal-5.md
│   └── MASTER-CHECKLIST.md
├── coordination/         # Coordination files
│   └── phase-status.json
├── workspace/           # Generated code goes here
├── logs/                # Execution logs
├── prompts/            # Terminal prompts
└── swarm.config        # Project configuration
```

## 🔧 Requirements

- Claude CLI installed (`~/.claude/local/claude`)
- Python 3.7+
- Bash shell
- macOS (Terminal.app) or Linux

## 💡 Use Cases

- **Rapid Prototyping**: Build MVPs in hours
- **Learning Projects**: See how professionals structure code
- **Hackathons**: Parallel development for speed
- **Complex Projects**: Coordinate multiple aspects
- **Code Generation**: Automate boilerplate creation

## 🤖 How Terminals Specialize

Based on project type, terminals adapt:

### Web Application
- Terminal 1: Backend architecture
- Terminal 2: API development
- Terminal 3: Frontend UI
- Terminal 4: Database design
- Terminal 5: DevOps & testing

### Machine Learning
- Terminal 1: Data pipeline
- Terminal 2: Model development
- Terminal 3: Training infrastructure
- Terminal 4: Evaluation metrics
- Terminal 5: Deployment

### API Service
- Terminal 1: Core logic
- Terminal 2: Database layer
- Terminal 3: Authentication
- Terminal 4: Integrations
- Terminal 5: Documentation

## 🚦 Status Indicators

- `NOT_STARTED` - Task pending
- `WORKING` - Currently in progress
- `COMPLETED` - Task finished
- `WAITING` - Waiting for phase advancement

## 🎯 Pro Tips

1. **Start Simple**: Begin with templates for common projects
2. **Monitor Progress**: Keep phase controller visible
3. **Let It Run**: Terminals work autonomously
4. **Review Output**: Check workspace/ for generated code
5. **Iterate**: Refine requirements and run again

## 📝 Example Session

```bash
# Create a SaaS application
$ swarm init saas-app "Build a SaaS platform with user management, 
  subscription billing, admin dashboard, and API"

✓ Project initialized
✓ Generated 5 terminal todo lists
✓ Created 4 development phases

$ cd projects/saas-app
$ swarm start

Launching swarm...
✓ Terminal 1: Backend Architecture
✓ Terminal 2: API Development
✓ Terminal 3: Frontend Dashboard
✓ Terminal 4: Billing System
✓ Terminal 5: Testing & DevOps
✓ Phase Controller Active

[Terminals work autonomously through all phases]
```

## 🌟 Advanced Features

### Claude Integration
Works with Claude's `--dangerously-skip-permissions` flag for automated execution.

### Extensible Templates
Create your own templates in `templates/` directory.

### Custom Analyzers
Modify `analyze-project.py` to add project type detection.

## 🐛 Troubleshooting

**Terminals not opening?**
- Ensure Claude CLI is installed
- Check Terminal.app permissions on macOS

**Phase not advancing?**
- Check if all terminals marked tasks as COMPLETED
- Use phase controller to manually advance

**Can't find swarm command?**
- Run `source ~/.bashrc` or restart terminal
- Check PATH includes swarm-system/bin

## 📄 License

MIT License - Use freely for any project!

## 🤝 Contributing

Contributions welcome! Please submit PRs for:
- New templates
- Better project analysis
- Additional project types
- Bug fixes

## 🎉 Built With Swarm

This very system was built using itself! The OpenSwarm project demonstrates the power of coordinated AI development.

---

**Ready to swarm?** Start building your next project with 5x the development power! 🚀