# 🚀 Swarm System - Quick Reference Card

## ⚡ Quick Setup (One Time)
```bash
# Run this to install global commands:
./swarm-system/bin/swarm-setup-global.sh

# Then activate:
source ~/.bashrc  # or ~/.zshrc for ZSH
```

## 🎯 Essential Commands (Ultra Short!)

| Command | What it does |
|---------|-------------|
| `sw` | Main swarm command (alias for swarm) |
| `sws` | **Start** swarm in current directory |
| `swk` | Launch **Kanban** monitor |
| `swn myapp "description"` | Create **new** project |
| `swquick app "desc"` | Create & **immediately start** |
| `swgo myapp` | **Navigate** to project |
| `swhelp` | Show all commands |

## 🏃 Quick Test Commands

```bash
# Instant demo - creates todo app and starts swarm
swdemo

# Test with existing swarm-enhancement project
swtest

# Super quick test
swrun
```

## 📁 Navigation Shortcuts

```bash
swcd    # Go to swarm home
swp     # Go to projects directory  
swls    # List all projects
swgo app # Go to specific project
swinfo  # Show current project info
```

## 🎨 Template Shortcuts

```bash
sw-web mysite    # Create web application
sw-api backend   # Create REST API
sw-cli mytool    # Create CLI tool
sw-ml model      # Create ML project
```

## 📊 Monitoring

```bash
kb          # Launch Kanban (shortest!)
kanban      # Launch Kanban monitor
swk myapp   # Kanban for specific project
```

## 🔄 Project Management

```bash
swr              # Resume previous project
swst             # Show all projects status
swc "add login"  # Request changes
swclean          # Clean temp files
```

## 🎮 Complete Workflow Example

```bash
# 1. Create project (super quick)
swquick chatapp "Build a real-time chat with React and WebSockets"

# This automatically:
# - Creates the project
# - Navigates to it
# - Starts the swarm

# 2. In another terminal, monitor progress
kb

# 3. Request changes later
swc "add user profiles and avatars"
```

## 💡 Pro Tips

### Fastest Test
```bash
swdemo  # One command to see everything working!
```

### Quick Project Start
```bash
swn myapp "Build something cool" && swgo myapp && sws
```

### Even Shorter
```bash
swquick myapp "Build something cool"  # Does all above in one!
```

## 🆘 Help

```bash
swhelp      # Quick command list
sw help     # Detailed swarm help
swinfo      # Current project info
```

## 📱 All Commands At a Glance

### Core (3 letters!)
- `sw` - Swarm
- `sws` - Start
- `swk` - Kanban
- `swn` - New
- `swr` - Resume
- `kb` - Kanban (shortest!)

### Quick Actions
- `swquick` - Create & start
- `swgo` - Navigate to project
- `swdemo` - Run demo
- `swtest` - Run test
- `swrun` - Quick test

### Info
- `swhelp` - Help
- `swinfo` - Project info
- `swst` - Status
- `swls` - List projects

---

**Remember**: After creating a project with `swn`, you can always just `swgo projectname` to jump to it and `sws` to start!

**Fastest Demo**: Just type `swdemo` and watch the magic! ✨