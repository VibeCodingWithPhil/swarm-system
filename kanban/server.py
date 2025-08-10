#!/usr/bin/env python3

"""
Swarm Kanban Server - Real-time monitoring interface for swarm agents
"""

from flask import Flask, render_template, jsonify, send_from_directory
from flask_socketio import SocketIO, emit
import json
import os
from pathlib import Path
from datetime import datetime
import threading
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

app = Flask(__name__)
app.config['SECRET_KEY'] = 'swarm-kanban-secret-key'
socketio = SocketIO(app, cors_allowed_origins="*")

# Global state
current_project = None
file_observer = None

class TodoFileHandler(FileSystemEventHandler):
    """Watches todo files for changes"""
    
    def on_modified(self, event):
        if event.src_path.endswith('.md'):
            # Parse and emit updated data
            update_data = parse_project_status()
            socketio.emit('status_update', update_data)

def parse_project_status():
    """Parse all project files to get current status"""
    
    if not current_project:
        return {'error': 'No project loaded'}
    
    project_path = Path(current_project)
    status = {
        'project_name': project_path.name,
        'timestamp': datetime.now().isoformat(),
        'terminals': {},
        'phase': {},
        'overall_progress': 0
    }
    
    # Parse phase status
    phase_file = project_path / 'coordination' / 'phase-status.json'
    if phase_file.exists():
        with open(phase_file, 'r') as f:
            phase_data = json.load(f)
            status['phase'] = {
                'current': phase_data.get('current_phase', 1),
                'name': phase_data.get(f"phase_{phase_data.get('current_phase', 1)}", {}).get('name', 'Unknown'),
                'status': phase_data.get(f"phase_{phase_data.get('current_phase', 1)}", {}).get('status', 'UNKNOWN')
            }
            
            # Get terminal status from phase data
            current_phase_key = f"phase_{phase_data.get('current_phase', 1)}"
            if current_phase_key in phase_data:
                terminals = phase_data[current_phase_key].get('terminals', {})
                for tid, tdata in terminals.items():
                    status['terminals'][tid] = {
                        'status': tdata.get('status', 'NOT_STARTED'),
                        'progress': tdata.get('progress', 0),
                        'task': tdata.get('task', 'No task assigned')
                    }
    
    # Parse todo files for tasks
    todo_dir = project_path / 'todo'
    if todo_dir.exists():
        for terminal_num in range(1, 6):
            terminal_file = todo_dir / f'terminal-{terminal_num}.md'
            if terminal_file.exists():
                tasks = parse_todo_file(terminal_file)
                
                terminal_key = str(terminal_num)
                if terminal_key not in status['terminals']:
                    status['terminals'][terminal_key] = {
                        'status': 'NOT_STARTED',
                        'progress': 0,
                        'task': 'Loading...'
                    }
                
                status['terminals'][terminal_key]['tasks'] = tasks
                
                # Calculate progress
                total_tasks = len(tasks['all'])
                completed_tasks = len(tasks['completed'])
                if total_tasks > 0:
                    calculated_progress = int((completed_tasks / total_tasks) * 100)
                    status['terminals'][terminal_key]['progress'] = calculated_progress
    
    # Calculate overall progress
    total_progress = 0
    terminal_count = 0
    for terminal_data in status['terminals'].values():
        total_progress += terminal_data.get('progress', 0)
        terminal_count += 1
    
    if terminal_count > 0:
        status['overall_progress'] = int(total_progress / terminal_count)
    
    return status

def parse_todo_file(file_path):
    """Parse a markdown todo file"""
    
    tasks = {
        'completed': [],
        'in_progress': [],
        'pending': [],
        'all': []
    }
    
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    current_section = ''
    for line in lines:
        # Track sections
        if line.startswith('#'):
            current_section = line.strip('#').strip()
        
        # Parse tasks
        if '- [x]' in line.lower() or '- [X]' in line:
            task = line.replace('- [x]', '').replace('- [X]', '').strip()
            tasks['completed'].append({
                'text': task,
                'section': current_section,
                'status': 'completed'
            })
            tasks['all'].append(task)
        elif '- [ ]' in line:
            task = line.replace('- [ ]', '').strip()
            # Check if it looks like it's being worked on
            if any(keyword in current_section.lower() for keyword in ['current', 'working', 'in progress']):
                tasks['in_progress'].append({
                    'text': task,
                    'section': current_section,
                    'status': 'in_progress'
                })
            else:
                tasks['pending'].append({
                    'text': task,
                    'section': current_section,
                    'status': 'pending'
                })
            tasks['all'].append(task)
    
    return tasks

def watch_project_files(project_path):
    """Start watching project files for changes"""
    
    global file_observer
    
    if file_observer:
        file_observer.stop()
    
    event_handler = TodoFileHandler()
    file_observer = Observer()
    
    # Watch todo directory
    todo_dir = Path(project_path) / 'todo'
    if todo_dir.exists():
        file_observer.schedule(event_handler, str(todo_dir), recursive=True)
    
    # Watch coordination directory
    coord_dir = Path(project_path) / 'coordination'
    if coord_dir.exists():
        file_observer.schedule(event_handler, str(coord_dir), recursive=True)
    
    file_observer.start()

@app.route('/')
def index():
    """Main kanban board page"""
    return render_template('kanban.html')

@app.route('/api/status')
def get_status():
    """Get current project status"""
    return jsonify(parse_project_status())

@app.route('/api/projects')
def get_projects():
    """Get list of available projects"""
    
    swarm_home = Path(__file__).parent.parent
    projects_dir = swarm_home / 'projects'
    
    projects = []
    if projects_dir.exists():
        for project_dir in projects_dir.iterdir():
            if project_dir.is_dir() and (project_dir / 'swarm.config').exists():
                config = {}
                with open(project_dir / 'swarm.config', 'r') as f:
                    for line in f:
                        if '=' in line:
                            key, value = line.strip().split('=', 1)
                            config[key] = value.strip('"')
                
                projects.append({
                    'name': project_dir.name,
                    'path': str(project_dir),
                    'created': config.get('CREATED_AT', 'Unknown'),
                    'status': config.get('STATUS', 'Unknown')
                })
    
    return jsonify(projects)

@app.route('/api/project/<project_name>')
def load_project(project_name):
    """Load a specific project"""
    
    global current_project
    
    swarm_home = Path(__file__).parent.parent
    project_path = swarm_home / 'projects' / project_name
    
    if not project_path.exists():
        return jsonify({'error': 'Project not found'}), 404
    
    current_project = str(project_path)
    watch_project_files(current_project)
    
    return jsonify({'success': True, 'project': project_name})

@app.route('/static/<path:path>')
def send_static(path):
    """Serve static files"""
    return send_from_directory('static', path)

@socketio.on('connect')
def handle_connect():
    """Handle client connection"""
    print('Client connected')
    if current_project:
        emit('status_update', parse_project_status())

@socketio.on('disconnect')
def handle_disconnect():
    """Handle client disconnection"""
    print('Client disconnected')

@socketio.on('request_update')
def handle_update_request():
    """Handle manual update request"""
    emit('status_update', parse_project_status())

def periodic_update():
    """Send periodic updates to all clients"""
    while True:
        time.sleep(5)  # Update every 5 seconds
        if current_project:
            socketio.emit('status_update', parse_project_status())

def main():
    """Main entry point"""
    
    import sys
    
    # Check if project path provided
    if len(sys.argv) > 1:
        global current_project
        current_project = sys.argv[1]
        watch_project_files(current_project)
    
    # Start periodic update thread
    update_thread = threading.Thread(target=periodic_update, daemon=True)
    update_thread.start()
    
    print("=" * 60)
    print("  Swarm Kanban Server")
    print("=" * 60)
    print(f"  Running on: http://localhost:5000")
    print(f"  Press Ctrl+C to stop")
    print("=" * 60)
    
    socketio.run(app, host='0.0.0.0', port=5000, debug=False)

if __name__ == '__main__':
    main()