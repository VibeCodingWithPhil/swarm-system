#!/usr/bin/env python3

"""
Task Tracker - Manages todo completion and prevents duplication
"""

import re
import json
import hashlib
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple
import difflib

class TaskTracker:
    """Tracks and manages tasks across all terminals"""
    
    def __init__(self, project_path):
        self.project_path = Path(project_path)
        self.todo_dir = self.project_path / "todo"
        self.tracking_file = self.project_path / "coordination" / "task-tracking.json"
        self.load_tracking_data()
    
    def load_tracking_data(self):
        """Load existing tracking data"""
        if self.tracking_file.exists():
            with open(self.tracking_file, 'r') as f:
                self.tracking_data = json.load(f)
        else:
            self.tracking_data = {
                'tasks': {},
                'completed': [],
                'in_progress': [],
                'pending': [],
                'last_updated': datetime.now().isoformat()
            }
    
    def save_tracking_data(self):
        """Save tracking data"""
        self.tracking_data['last_updated'] = datetime.now().isoformat()
        self.tracking_file.parent.mkdir(exist_ok=True)
        with open(self.tracking_file, 'w') as f:
            json.dump(self.tracking_data, f, indent=2)
        
        # Trigger update for Kanban if running
        self._notify_kanban()
    
    def scan_todos(self) -> Dict:
        """Scan all todo files and extract tasks"""
        all_tasks = {}
        
        for terminal_num in range(1, 6):
            todo_file = self.todo_dir / f"terminal-{terminal_num}.md"
            if todo_file.exists():
                tasks = self.parse_markdown_tasks(todo_file)
                all_tasks[terminal_num] = tasks
        
        return all_tasks
    
    def parse_markdown_tasks(self, file_path: Path) -> List[Dict]:
        """Parse tasks from markdown file"""
        tasks = []
        current_section = ""
        
        with open(file_path, 'r') as f:
            lines = f.readlines()
        
        for i, line in enumerate(lines):
            # Track sections
            if line.startswith('#'):
                current_section = line.strip('#').strip()
            
            # Find tasks (both completed and uncompleted)
            task_match = re.match(r'^(\s*)- \[([ xX])\] (.+)$', line)
            if task_match:
                indent = len(task_match.group(1))
                completed = task_match.group(2).lower() == 'x'
                task_text = task_match.group(3)
                
                # Generate unique ID for task
                task_id = self.generate_task_id(file_path.name, task_text)
                
                tasks.append({
                    'id': task_id,
                    'text': task_text,
                    'completed': completed,
                    'section': current_section,
                    'line_number': i,
                    'indent': indent,
                    'file': file_path.name
                })
        
        return tasks
    
    def generate_task_id(self, file_name: str, task_text: str) -> str:
        """Generate unique ID for a task"""
        # Remove variable parts like numbers, dates
        normalized = re.sub(r'\d+', 'N', task_text)
        normalized = re.sub(r'\s+', ' ', normalized).strip().lower()
        
        # Create hash
        content = f"{file_name}:{normalized}"
        return hashlib.md5(content.encode()).hexdigest()[:8]
    
    def update_task_status(self, terminal_num: int, task_text: str, completed: bool):
        """Update task status in markdown file"""
        todo_file = self.todo_dir / f"terminal-{terminal_num}.md"
        
        if not todo_file.exists():
            return False
        
        with open(todo_file, 'r') as f:
            lines = f.readlines()
        
        updated = False
        for i, line in enumerate(lines):
            if '- [ ]' in line or '- [x]' in line or '- [X]' in line:
                # Extract task text from line
                task_match = re.match(r'^(\s*)- \[[ xX]\] (.+)$', line)
                if task_match:
                    line_task = task_match.group(2)
                    # Check if this is the task we're looking for (fuzzy match)
                    similarity = difflib.SequenceMatcher(None, task_text.lower(), line_task.lower()).ratio()
                    if similarity > 0.8:  # 80% similarity threshold
                        indent = task_match.group(1)
                        new_status = 'x' if completed else ' '
                        lines[i] = f"{indent}- [{new_status}] {line_task}\n"
                        updated = True
                        break
        
        if updated:
            with open(todo_file, 'w') as f:
                f.writelines(lines)
        
        return updated
    
    def merge_new_tasks(self, new_request: str) -> Dict:
        """Merge new tasks with existing todos, avoiding duplicates"""
        
        # Scan current todos
        current_tasks = self.scan_todos()
        
        # Extract all task texts for duplicate detection
        existing_texts = []
        for terminal_tasks in current_tasks.values():
            for task in terminal_tasks:
                if not task['completed']:
                    existing_texts.append(task['text'].lower())
        
        # Parse new request for potential tasks
        new_tasks = self.extract_tasks_from_request(new_request)
        
        # Filter out duplicates
        unique_new_tasks = []
        duplicates = []
        
        for task in new_tasks:
            # Check for similarity with existing tasks
            is_duplicate = False
            for existing in existing_texts:
                similarity = difflib.SequenceMatcher(None, task.lower(), existing).ratio()
                if similarity > 0.7:  # 70% similarity threshold
                    duplicates.append(task)
                    is_duplicate = True
                    break
            
            if not is_duplicate:
                unique_new_tasks.append(task)
        
        # Distribute new tasks to terminals
        distribution = self.distribute_tasks(unique_new_tasks, current_tasks)
        
        return {
            'new_tasks': unique_new_tasks,
            'duplicates_avoided': duplicates,
            'distribution': distribution,
            'remaining_tasks': self.count_remaining_tasks(current_tasks)
        }
    
    def extract_tasks_from_request(self, request: str) -> List[str]:
        """Extract potential tasks from a change request"""
        tasks = []
        
        # Common task patterns
        patterns = [
            r'add[s]?\s+(.+?)(?:\.|,|;|$)',
            r'implement[s]?\s+(.+?)(?:\.|,|;|$)',
            r'create[s]?\s+(.+?)(?:\.|,|;|$)',
            r'build[s]?\s+(.+?)(?:\.|,|;|$)',
            r'fix[es]?\s+(.+?)(?:\.|,|;|$)',
            r'update[s]?\s+(.+?)(?:\.|,|;|$)',
            r'improve[s]?\s+(.+?)(?:\.|,|;|$)',
        ]
        
        request_lower = request.lower()
        for pattern in patterns:
            matches = re.finditer(pattern, request_lower)
            for match in matches:
                task = match.group(1).strip()
                if len(task) > 5:  # Minimum task length
                    tasks.append(task)
        
        # Also look for bullet points or numbered lists
        lines = request.split('\n')
        for line in lines:
            line = line.strip()
            if re.match(r'^[-*•]\s+(.+)$', line):
                task = re.sub(r'^[-*•]\s+', '', line)
                tasks.append(task)
            elif re.match(r'^\d+\.\s+(.+)$', line):
                task = re.sub(r'^\d+\.\s+', '', line)
                tasks.append(task)
        
        return tasks
    
    def distribute_tasks(self, tasks: List[str], current_tasks: Dict) -> Dict:
        """Distribute new tasks among terminals based on workload"""
        
        # Calculate current workload
        workload = {}
        for terminal, tasks_list in current_tasks.items():
            incomplete = sum(1 for t in tasks_list if not t['completed'])
            workload[terminal] = incomplete
        
        # Sort terminals by workload (least busy first)
        sorted_terminals = sorted(workload.keys(), key=lambda x: workload[x])
        
        # Distribute tasks
        distribution = {t: [] for t in range(1, 6)}
        for i, task in enumerate(tasks):
            terminal = sorted_terminals[i % len(sorted_terminals)]
            distribution[terminal].append(task)
        
        return distribution
    
    def count_remaining_tasks(self, tasks: Dict) -> Dict:
        """Count remaining tasks per terminal"""
        remaining = {}
        for terminal, tasks_list in tasks.items():
            incomplete = sum(1 for t in tasks_list if not t['completed'])
            complete = sum(1 for t in tasks_list if t['completed'])
            remaining[terminal] = {
                'incomplete': incomplete,
                'complete': complete,
                'total': len(tasks_list)
            }
        return remaining
    
    def append_tasks_to_todos(self, distribution: Dict):
        """Append new tasks to todo files"""
        
        for terminal, tasks in distribution.items():
            if not tasks:
                continue
            
            todo_file = self.todo_dir / f"terminal-{terminal}.md"
            
            # Read existing content
            if todo_file.exists():
                with open(todo_file, 'r') as f:
                    content = f.read()
            else:
                content = f"# Terminal {terminal} - Tasks\n\n"
            
            # Append new section
            new_section = f"\n## New Tasks - {datetime.now().strftime('%Y-%m-%d %H:%M')}\n"
            for task in tasks:
                new_section += f"- [ ] {task}\n"
            
            # Write back
            with open(todo_file, 'w') as f:
                f.write(content + new_section)
    
    def get_status_summary(self) -> Dict:
        """Get summary of all tasks"""
        tasks = self.scan_todos()
        
        summary = {
            'terminals': {},
            'total_tasks': 0,
            'completed_tasks': 0,
            'in_progress_tasks': 0,
            'pending_tasks': 0,
            'completion_percentage': 0
        }
        
        for terminal, task_list in tasks.items():
            completed = sum(1 for t in task_list if t['completed'])
            total = len(task_list)
            
            summary['terminals'][terminal] = {
                'total': total,
                'completed': completed,
                'pending': total - completed,
                'percentage': (completed / total * 100) if total > 0 else 0
            }
            
            summary['total_tasks'] += total
            summary['completed_tasks'] += completed
        
        summary['pending_tasks'] = summary['total_tasks'] - summary['completed_tasks']
        
        if summary['total_tasks'] > 0:
            summary['completion_percentage'] = (
                summary['completed_tasks'] / summary['total_tasks'] * 100
            )
        
        return summary
    
    def _notify_kanban(self):
        """Notify Kanban server of updates if running"""
        try:
            # Try to connect to kanban server
            import socket
            import json as json_lib
            
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(0.5)
            result = sock.connect_ex(('localhost', 5000))
            sock.close()
            
            if result == 0:
                # Server is running, send update signal
                # The file watcher will pick up the changes automatically
                pass
        except:
            # Kanban not running, no problem
            pass

def main():
    """CLI interface"""
    import sys
    
    if len(sys.argv) < 2:
        print("Usage:")
        print("  task-tracker.py <project-path> scan        # Scan all todos")
        print("  task-tracker.py <project-path> update <terminal> <task> <status>")
        print("  task-tracker.py <project-path> merge \"<new-request>\"")
        print("  task-tracker.py <project-path> status      # Get status summary")
        sys.exit(1)
    
    project_path = sys.argv[1]
    command = sys.argv[2] if len(sys.argv) > 2 else 'scan'
    
    tracker = TaskTracker(project_path)
    
    if command == 'scan':
        tasks = tracker.scan_todos()
        for terminal, task_list in tasks.items():
            print(f"\nTerminal {terminal}:")
            for task in task_list:
                status = '✓' if task['completed'] else '○'
                print(f"  {status} {task['text'][:60]}...")
    
    elif command == 'update':
        if len(sys.argv) < 6:
            print("Usage: task-tracker.py <project> update <terminal> <task> <true|false>")
            sys.exit(1)
        
        terminal = int(sys.argv[3])
        task = sys.argv[4]
        status = sys.argv[5].lower() == 'true'
        
        if tracker.update_task_status(terminal, task, status):
            print(f"✓ Updated task status")
        else:
            print("✗ Task not found")
    
    elif command == 'merge':
        if len(sys.argv) < 4:
            print("Usage: task-tracker.py <project> merge \"<new-request>\"")
            sys.exit(1)
        
        request = ' '.join(sys.argv[3:])
        result = tracker.merge_new_tasks(request)
        
        print(f"New tasks: {len(result['new_tasks'])}")
        print(f"Duplicates avoided: {len(result['duplicates_avoided'])}")
        
        if result['new_tasks']:
            print("\nNew tasks to add:")
            for task in result['new_tasks']:
                print(f"  - {task}")
        
        if result['duplicates_avoided']:
            print("\nDuplicates avoided:")
            for task in result['duplicates_avoided']:
                print(f"  - {task}")
        
        # Append tasks
        tracker.append_tasks_to_todos(result['distribution'])
        print("\n✓ Tasks added to todo files")
    
    elif command == 'status':
        summary = tracker.get_status_summary()
        print(f"\nProject Status:")
        print(f"Total Tasks: {summary['total_tasks']}")
        print(f"Completed: {summary['completed_tasks']}")
        print(f"Pending: {summary['pending_tasks']}")
        print(f"Completion: {summary['completion_percentage']:.1f}%")
        
        print("\nPer Terminal:")
        for terminal, stats in summary['terminals'].items():
            print(f"  Terminal {terminal}: {stats['completed']}/{stats['total']} ({stats['percentage']:.0f}%)")

if __name__ == "__main__":
    main()