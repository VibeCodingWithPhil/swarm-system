# Swarm Kanban Monitor

Real-time web-based monitoring interface for Swarm AI agents.

## Features

- **Live Progress Tracking**: See what each of the 5 terminals is working on in real-time
- **Task Visualization**: View completed, in-progress, and pending tasks for each agent
- **Phase Monitoring**: Track which development phase the swarm is currently in
- **Overall Progress**: See the combined progress of all agents
- **Auto-refresh**: Updates automatically as agents work
- **WebSocket Support**: Real-time updates without page refresh
- **Responsive Design**: Works on desktop and mobile devices

## Installation

The Kanban monitor is automatically installed with the Swarm system. Dependencies are installed when you first launch it.

## Usage

### Launch from any project directory:
```bash
swarm kanban
```

### Launch for specific project:
```bash
swarm kanban my-project
```

### Direct launch:
```bash
cd swarm-system/kanban
./start-kanban.sh [project-name]
```

## Interface

The Kanban board shows:

1. **Header Section**
   - Project selector dropdown
   - Current phase indicator
   - Overall progress bar
   - Last update timestamp

2. **Terminal Columns** (5 columns)
   - Terminal number and status
   - Current task assignment
   - Task lists (completed/in-progress/pending)
   - Individual progress bar

3. **Connection Status**
   - Shows real-time connection to server
   - Green = connected, Red = disconnected

## How It Works

1. **File Watching**: Monitors todo files and phase status files for changes
2. **WebSocket**: Pushes updates to browser clients in real-time
3. **Periodic Updates**: Backup polling every 5 seconds
4. **Multi-project**: Can switch between projects without restart

## Files Monitored

- `todo/terminal-*.md` - Task lists for each terminal
- `coordination/phase-status.json` - Current phase and terminal status
- `coordination/task-tracking.json` - Task completion tracking

## Architecture

- **Backend**: Python Flask + SocketIO
- **Frontend**: Pure HTML/CSS/JavaScript (no framework dependencies)
- **File Watching**: Uses watchdog library for file system monitoring
- **Real-time**: WebSocket for instant updates

## Troubleshooting

### Server won't start
- Server uses port 5555 (to avoid macOS AirPlay conflict on port 5000)
- Check if port 5555 is already in use
- Ensure Python 3.7+ is installed
- Try: `lsof -i :5555` to see if port is occupied

### No updates showing
- Verify project has been initialized with swarm
- Check that todo files exist in project
- Ensure file permissions allow reading

### Can't connect
- Check firewall settings
- Verify server is running (check terminal output)
- Try refreshing browser

## Development

To modify the Kanban interface:

1. **Server**: Edit `server.py` for backend changes
2. **UI**: Edit `templates/kanban.html` for frontend
3. **Styles**: CSS is embedded in the HTML file
4. **Auto-reload**: Server restarts automatically on file changes in debug mode

## Security Note

The Kanban interface is read-only and cannot modify project files. It only displays current status and does not accept user input beyond project selection.