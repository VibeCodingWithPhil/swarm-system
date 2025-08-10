# 🎯 Swarm System - Clear Commands Reference

## ✨ Commands That Make Sense!

All commands now clearly describe what they do. No more confusion!

## 📦 Installation

```bash
# Install the clear commands
./swarm-system/bin/swarm-setup-global-clear.sh

# Activate them
source ~/.bashrc  # or ~/.zshrc
```

## 🚀 Core Commands

| Command | What It Does |
|---------|-------------|
| `swarm-new <name> "description"` | Create NEW project |
| `swarm-start` | START the swarm (current directory) |
| `swarm-kanban [project]` | Open KANBAN monitor |
| `swarm-resume` | RESUME previous project |
| `swarm-status` | Show STATUS of all projects |
| `swarm-existing <path> <name>` | Import EXISTING project |
| `swarm-change "description"` | Request CHANGES to current project |

## 📚 Project Templates

| Command | Creates |
|---------|---------|
| `swarm-new-webapp <name>` | Web Application |
| `swarm-new-api <name>` | REST API |
| `swarm-new-cli <name>` | CLI Tool |
| `swarm-new-ml <name>` | Machine Learning Project |
| `swarm-new-mobile <name>` | Mobile App |
| `swarm-new-game <name>` | Game |

## 🧭 Navigation

| Command | Takes You To |
|---------|-------------|
| `swarm-home` | Swarm system directory |
| `swarm-projects` | Projects directory |
| `swarm-go <project>` | Specific project |
| `swarm-list` | Lists all projects |
| `swarm-info` | Shows current project info |

## 🧪 Testing

| Command | What It Does |
|---------|-------------|
| `swarm-demo` | Creates todo app and starts immediately |
| `swarm-test` | Runs the test project |
| `swarm-quick-test` | Interactive test walkthrough |

## 📊 Complete Workflow Examples

### Example 1: New Project
```bash
swarm-new myapp "Build a task management app"
swarm-go myapp
swarm-start
# In another terminal:
swarm-kanban myapp
```

### Example 2: Import Existing Code
```bash
swarm-existing ./my-code awesome-project
swarm-go awesome-project
swarm-start
```

### Example 3: Quick Demo
```bash
swarm-demo  # One command does everything!
```

### Example 4: Resume Work
```bash
swarm-list                    # See all projects
swarm-go my-previous-project  # Navigate to it
swarm-resume                  # Continue where you left off
```

### Example 5: Request Changes
```bash
swarm-go myapp
swarm-change "Add user authentication and profiles"
swarm-start
```

## 🆘 Help Commands

| Command | Shows |
|---------|-------|
| `swarm-help` | All available commands |
| `swarm-info` | Current project information |
| `swarm help` | Detailed swarm documentation |

## 💡 Pro Tips

1. **Always use descriptive commands** - they tell you exactly what they do
2. **Start with `swarm-demo`** to see everything working
3. **Use `swarm-kanban`** in a separate terminal for live monitoring
4. **Use `swarm-go`** to quickly jump between projects
5. **Use templates** like `swarm-new-webapp` for faster setup

## 🎯 Command Naming Logic

Every command follows a clear pattern:
- `swarm-new` → Creates something NEW
- `swarm-start` → STARTS the swarm
- `swarm-kanban` → Opens KANBAN board
- `swarm-existing` → Imports EXISTING code
- `swarm-resume` → RESUMES previous work
- `swarm-go` → GO to a project
- `swarm-list` → LIST projects

No more guessing what `sw`, `swk`, or `sws` means!

## 🚦 Quick Start Checklist

1. ✅ Run `swarm-setup` to install commands
2. ✅ Run `source ~/.bashrc` to activate
3. ✅ Run `swarm-help` to see all commands
4. ✅ Run `swarm-demo` to test everything
5. ✅ Run `swarm-kanban` to monitor

---

**Remember**: Every command name describes exactly what it does. When in doubt, run `swarm-help`!