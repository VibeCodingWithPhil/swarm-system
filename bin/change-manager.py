#!/usr/bin/env python3

"""
Change Manager - Handles change requests and creates new phases
"""

import json
import sys
from pathlib import Path
from datetime import datetime
from prompt_enhancer import PromptEnhancer

class ChangeManager:
    """Manages change requests and generates new phases"""
    
    def __init__(self, project_path):
        self.project_path = Path(project_path)
        self.enhancer = PromptEnhancer()
        
    def process_change_request(self, change_description: str) -> Dict:
        """Process a change request and generate new phases"""
        
        # Enhance the change request
        enhanced = self.enhancer.enhance_prompt(change_description)
        
        # Load current project state
        current_state = self._load_project_state()
        
        # Generate change phases
        change_phases = self._generate_change_phases(
            change_description,
            enhanced,
            current_state
        )
        
        # Create new todo lists
        new_todos = self._generate_change_todos(change_phases)
        
        # Save change request
        self._save_change_request(change_description, change_phases, new_todos)
        
        return {
            'change_description': change_description,
            'enhanced': enhanced,
            'new_phases': change_phases,
            'new_todos': new_todos,
            'implementation_plan': self._create_implementation_plan(change_phases)
        }
    
    def _load_project_state(self) -> Dict:
        """Load current project state"""
        state = {
            'config': {},
            'current_phase': 1,
            'completed_features': [],
            'existing_files': []
        }
        
        # Load config
        config_file = self.project_path / "swarm.config"
        if config_file.exists():
            with open(config_file, 'r') as f:
                for line in f:
                    if '=' in line:
                        key, value = line.strip().split('=', 1)
                        state['config'][key] = value.strip('"')
        
        # Load phase status
        phase_file = self.project_path / "coordination" / "phase-status.json"
        if phase_file.exists():
            with open(phase_file, 'r') as f:
                phase_data = json.load(f)
                state['current_phase'] = phase_data.get('current_phase', 1)
        
        # Load completed features
        resume_file = self.project_path / "coordination" / "resume-data.json"
        if resume_file.exists():
            with open(resume_file, 'r') as f:
                resume_data = json.load(f)
                state['completed_features'] = resume_data.get('analysis', {}).get('implemented_features', [])
        
        # Check existing files
        workspace = self.project_path / "workspace"
        if workspace.exists():
            state['existing_files'] = [str(f.relative_to(workspace)) 
                                     for f in workspace.rglob('*') if f.is_file()]
        
        return state
    
    def _generate_change_phases(self, change: str, enhanced: Dict, state: Dict) -> Dict:
        """Generate phases for the change request"""
        
        # Determine change complexity
        complexity = self._assess_change_complexity(change, enhanced)
        
        phases = {}
        
        if complexity == 'minor':
            # Single phase for minor changes
            phases['change_phase_1'] = {
                'name': 'Change Implementation',
                'terminals': {
                    '1': {'task': 'Update backend for change', 'priority': 'high'},
                    '2': {'task': 'Update data layer if needed', 'priority': 'medium'},
                    '3': {'task': 'Update UI for change', 'priority': 'high'},
                    '4': {'task': 'Update features affected', 'priority': 'medium'},
                    '5': {'task': 'Test changes thoroughly', 'priority': 'high'}
                }
            }
        
        elif complexity == 'moderate':
            # Two phases for moderate changes
            phases['change_phase_1'] = {
                'name': 'Change Preparation',
                'terminals': {
                    '1': {'task': 'Refactor architecture for change', 'priority': 'high'},
                    '2': {'task': 'Update data models', 'priority': 'high'},
                    '3': {'task': 'Prepare UI components', 'priority': 'medium'},
                    '4': {'task': 'Identify affected features', 'priority': 'medium'},
                    '5': {'task': 'Create change test plan', 'priority': 'high'}
                }
            }
            phases['change_phase_2'] = {
                'name': 'Change Implementation',
                'terminals': {
                    '1': {'task': 'Implement backend changes', 'priority': 'high'},
                    '2': {'task': 'Migrate data if needed', 'priority': 'high'},
                    '3': {'task': 'Implement UI changes', 'priority': 'high'},
                    '4': {'task': 'Update all affected features', 'priority': 'high'},
                    '5': {'task': 'Execute test plan', 'priority': 'high'}
                }
            }
        
        else:  # major
            # Three phases for major changes
            phases['change_phase_1'] = {
                'name': 'Change Analysis & Design',
                'terminals': {
                    '1': {'task': 'Design new architecture', 'priority': 'high'},
                    '2': {'task': 'Plan data migration', 'priority': 'high'},
                    '3': {'task': 'Design new UI/UX', 'priority': 'high'},
                    '4': {'task': 'Plan feature updates', 'priority': 'medium'},
                    '5': {'task': 'Create comprehensive test strategy', 'priority': 'high'}
                }
            }
            phases['change_phase_2'] = {
                'name': 'Change Development',
                'terminals': {
                    '1': {'task': 'Build new backend components', 'priority': 'high'},
                    '2': {'task': 'Implement data changes', 'priority': 'high'},
                    '3': {'task': 'Build new UI components', 'priority': 'high'},
                    '4': {'task': 'Develop new features', 'priority': 'high'},
                    '5': {'task': 'Write comprehensive tests', 'priority': 'high'}
                }
            }
            phases['change_phase_3'] = {
                'name': 'Change Integration',
                'terminals': {
                    '1': {'task': 'Integrate and optimize backend', 'priority': 'high'},
                    '2': {'task': 'Complete data migration', 'priority': 'high'},
                    '3': {'task': 'Polish UI and UX', 'priority': 'high'},
                    '4': {'task': 'Final feature integration', 'priority': 'high'},
                    '5': {'task': 'Full system testing', 'priority': 'high'}
                }
            }
        
        # Add specific tasks based on detected features
        for phase_key in phases:
            for feature in enhanced['detected_features']:
                if feature == 'auth' and '1' in phases[phase_key]['terminals']:
                    phases[phase_key]['terminals']['1']['subtasks'] = ['Update authentication flow']
                elif feature == 'payment' and '4' in phases[phase_key]['terminals']:
                    phases[phase_key]['terminals']['4']['subtasks'] = ['Update payment processing']
        
        return phases
    
    def _assess_change_complexity(self, change: str, enhanced: Dict) -> str:
        """Assess the complexity of a change request"""
        
        change_lower = change.lower()
        
        # Keywords indicating complexity
        minor_keywords = ['fix', 'update', 'change', 'modify', 'adjust', 'tweak']
        moderate_keywords = ['add', 'implement', 'create', 'enhance', 'improve', 'refactor']
        major_keywords = ['redesign', 'rebuild', 'migrate', 'replace', 'overhaul', 'transform']
        
        if any(keyword in change_lower for keyword in major_keywords):
            return 'major'
        elif any(keyword in change_lower for keyword in moderate_keywords):
            return 'moderate'
        elif any(keyword in change_lower for keyword in minor_keywords):
            return 'minor'
        
        # Check based on detected features
        if len(enhanced['detected_features']) > 3:
            return 'major'
        elif len(enhanced['detected_features']) > 1:
            return 'moderate'
        else:
            return 'minor'
    
    def _generate_change_todos(self, phases: Dict) -> Dict:
        """Generate todo lists for change phases"""
        
        todos = {}
        
        for terminal_num in range(1, 6):
            todo_content = f"""# Terminal {terminal_num} - Change Request Tasks

## Change Implementation

"""
            for phase_key, phase_data in phases.items():
                phase_name = phase_data['name']
                terminal_task = phase_data['terminals'].get(str(terminal_num), {})
                
                if terminal_task:
                    todo_content += f"""### {phase_name}
**Task:** {terminal_task.get('task', 'Support change implementation')}
**Priority:** {terminal_task.get('priority', 'medium')}

Tasks:
- [ ] Analyze existing code related to change
- [ ] Plan implementation approach
- [ ] Implement changes incrementally
- [ ] Write tests for changes
- [ ] Document changes
- [ ] Coordinate with other terminals

"""
                    if 'subtasks' in terminal_task:
                        for subtask in terminal_task['subtasks']:
                            todo_content += f"- [ ] {subtask}\n"
                    
                    todo_content += "\n"
            
            todos[terminal_num] = todo_content
        
        return todos
    
    def _save_change_request(self, change: str, phases: Dict, todos: Dict):
        """Save change request to project"""
        
        # Create changes directory
        changes_dir = self.project_path / "changes"
        changes_dir.mkdir(exist_ok=True)
        
        # Create timestamped change file
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        change_file = changes_dir / f"change_{timestamp}.json"
        
        change_data = {
            'timestamp': timestamp,
            'description': change,
            'phases': phases,
            'status': 'pending'
        }
        
        with open(change_file, 'w') as f:
            json.dump(change_data, f, indent=2)
        
        # Save todo files
        for terminal, content in todos.items():
            todo_file = changes_dir / f"change_{timestamp}_terminal_{terminal}.md"
            with open(todo_file, 'w') as f:
                f.write(content)
    
    def _create_implementation_plan(self, phases: Dict) -> str:
        """Create an implementation plan for the change"""
        
        plan = "CHANGE IMPLEMENTATION PLAN\n"
        plan += "=" * 50 + "\n\n"
        
        for i, (phase_key, phase_data) in enumerate(phases.items(), 1):
            plan += f"Step {i}: {phase_data['name']}\n"
            plan += "-" * 30 + "\n"
            
            for terminal, task in phase_data['terminals'].items():
                plan += f"  Terminal {terminal}: {task['task']}\n"
            
            plan += "\n"
        
        plan += "EXECUTION:\n"
        plan += "1. Review and approve plan\n"
        plan += "2. Load change todos into terminals\n"
        plan += "3. Execute phases sequentially\n"
        plan += "4. Test after each phase\n"
        plan += "5. Document completion\n"
        
        return plan

def import_existing_project(source_path: str, swarm_path: str, project_name: str, description: str = None):
    """Import an existing project into swarm system"""
    
    source = Path(source_path)
    if not source.exists():
        raise ValueError(f"Source path does not exist: {source_path}")
    
    # Create project in swarm
    project_path = Path(swarm_path) / "projects" / project_name
    project_path.mkdir(parents=True, exist_ok=True)
    
    # Copy existing code to workspace
    workspace = project_path / "workspace"
    workspace.mkdir(exist_ok=True)
    
    # Copy files
    import shutil
    if source.is_file():
        shutil.copy2(source, workspace)
    else:
        for item in source.iterdir():
            if item.name not in ['.git', 'node_modules', '__pycache__', '.venv', 'venv']:
                dest = workspace / item.name
                if item.is_dir():
                    shutil.copytree(item, dest, dirs_exist_ok=True)
                else:
                    shutil.copy2(item, dest)
    
    # Analyze existing code
    analysis = analyze_existing_codebase(workspace)
    
    # Generate description if not provided
    if not description:
        description = f"Imported project with {len(analysis['languages'])} languages, {len(analysis['features'])} detected features"
    
    # Create swarm config
    config_file = project_path / "swarm.config"
    with open(config_file, 'w') as f:
        f.write(f'PROJECT_NAME="{project_name}"\n')
        f.write(f'PROJECT_PROMPT="{description}"\n')
        f.write(f'CREATED_AT="{datetime.now()}"\n')
        f.write('TERMINALS=5\n')
        f.write('PHASES=4\n')
        f.write('STATUS="IMPORTED"\n')
        f.write(f'SOURCE_PATH="{source_path}"\n')
    
    # Create initial directories
    (project_path / "todo").mkdir(exist_ok=True)
    (project_path / "coordination").mkdir(exist_ok=True)
    (project_path / "logs").mkdir(exist_ok=True)
    (project_path / "prompts").mkdir(exist_ok=True)
    
    # Generate todos based on analysis
    generate_todos_for_existing(project_path, analysis)
    
    return {
        'project_path': str(project_path),
        'analysis': analysis,
        'message': f"Successfully imported {project_name}"
    }

def analyze_existing_codebase(workspace_path: Path) -> Dict:
    """Analyze an existing codebase"""
    
    analysis = {
        'languages': set(),
        'frameworks': set(),
        'features': set(),
        'file_count': 0,
        'has_tests': False,
        'has_docker': False,
        'has_ci': False,
        'suggestions': []
    }
    
    for file_path in workspace_path.rglob('*'):
        if file_path.is_file():
            analysis['file_count'] += 1
            
            # Detect languages
            suffix = file_path.suffix.lower()
            if suffix in ['.py']:
                analysis['languages'].add('python')
            elif suffix in ['.js', '.jsx']:
                analysis['languages'].add('javascript')
            elif suffix in ['.ts', '.tsx']:
                analysis['languages'].add('typescript')
            elif suffix in ['.java']:
                analysis['languages'].add('java')
            elif suffix in ['.go']:
                analysis['languages'].add('golang')
            
            # Detect special files
            name = file_path.name.lower()
            if 'test' in name or 'spec' in name:
                analysis['has_tests'] = True
            if name == 'dockerfile' or name == 'docker-compose.yml':
                analysis['has_docker'] = True
            if '.github/workflows' in str(file_path) or name == '.gitlab-ci.yml':
                analysis['has_ci'] = True
            
            # Detect frameworks
            if name == 'package.json':
                with open(file_path, 'r') as f:
                    content = f.read()
                    if 'react' in content:
                        analysis['frameworks'].add('react')
                    if 'vue' in content:
                        analysis['frameworks'].add('vue')
                    if 'express' in content:
                        analysis['frameworks'].add('express')
            elif name == 'requirements.txt':
                with open(file_path, 'r') as f:
                    content = f.read()
                    if 'django' in content:
                        analysis['frameworks'].add('django')
                    if 'flask' in content:
                        analysis['frameworks'].add('flask')
                    if 'fastapi' in content:
                        analysis['frameworks'].add('fastapi')
    
    # Generate suggestions
    if not analysis['has_tests']:
        analysis['suggestions'].append('Add comprehensive test suite')
    if not analysis['has_docker']:
        analysis['suggestions'].append('Add Docker configuration')
    if not analysis['has_ci']:
        analysis['suggestions'].append('Set up CI/CD pipeline')
    
    analysis['languages'] = list(analysis['languages'])
    analysis['frameworks'] = list(analysis['frameworks'])
    
    return analysis

def generate_todos_for_existing(project_path: Path, analysis: Dict):
    """Generate todo lists for an existing project"""
    
    # Terminal 1: Architecture & Refactoring
    todo1 = """# Terminal 1 - Architecture & Refactoring

## Phase 1: Analysis
- [ ] Analyze current architecture
- [ ] Identify improvement areas
- [ ] Plan refactoring strategy
- [ ] Document existing patterns

## Phase 2: Refactoring
- [ ] Refactor core components
- [ ] Improve code organization
- [ ] Implement design patterns
- [ ] Update dependencies
"""
    
    # Terminal 2: Testing
    todo2 = """# Terminal 2 - Testing & Quality

## Phase 1: Test Setup
- [ ] Set up test framework
- [ ] Create test structure
- [ ] Write unit tests for existing code
- [ ] Set up test coverage

## Phase 2: Test Implementation
- [ ] Write integration tests
- [ ] Add end-to-end tests
- [ ] Implement test automation
- [ ] Achieve 80% coverage
"""
    
    # Terminal 3: Features & UI
    todo3 = """# Terminal 3 - Features & UI Enhancement

## Phase 1: UI Analysis
- [ ] Review current UI/UX
- [ ] Identify improvement areas
- [ ] Plan enhancements
- [ ] Create component library

## Phase 2: Implementation
- [ ] Enhance UI components
- [ ] Improve user experience
- [ ] Add responsive design
- [ ] Implement accessibility
"""
    
    # Terminal 4: DevOps & Deployment
    todo4 = """# Terminal 4 - DevOps & Deployment

## Phase 1: Infrastructure
- [ ] Set up Docker configuration
- [ ] Create CI/CD pipeline
- [ ] Configure environments
- [ ] Set up monitoring

## Phase 2: Deployment
- [ ] Create deployment scripts
- [ ] Set up staging environment
- [ ] Configure production
- [ ] Implement rollback strategy
"""
    
    # Terminal 5: Documentation & Optimization
    todo5 = """# Terminal 5 - Documentation & Optimization

## Phase 1: Documentation
- [ ] Write README
- [ ] Create API documentation
- [ ] Write user guide
- [ ] Document architecture

## Phase 2: Optimization
- [ ] Performance profiling
- [ ] Optimize database queries
- [ ] Improve load times
- [ ] Security hardening
"""
    
    # Add suggestions from analysis
    for i, suggestion in enumerate(analysis['suggestions'][:5], 1):
        todo_var = locals()[f'todo{i}']
        todo_var += f"\n## Additional Task\n- [ ] {suggestion}\n"
    
    # Save todos
    for i, content in enumerate([todo1, todo2, todo3, todo4, todo5], 1):
        todo_file = project_path / "todo" / f"terminal-{i}.md"
        with open(todo_file, 'w') as f:
            f.write(content)
    
    # Create master checklist
    master = f"""# Master Checklist - Existing Project Enhancement

## Project Analysis
- Languages: {', '.join(analysis['languages'])}
- Frameworks: {', '.join(analysis['frameworks'])}
- File Count: {analysis['file_count']}
- Has Tests: {analysis['has_tests']}
- Has Docker: {analysis['has_docker']}

## Enhancement Plan
1. Architecture refactoring
2. Test suite implementation
3. UI/UX enhancement
4. DevOps setup
5. Documentation & optimization

## Suggestions
{chr(10).join(f'- {s}' for s in analysis['suggestions'])}
"""
    
    master_file = project_path / "todo" / "MASTER-CHECKLIST.md"
    with open(master_file, 'w') as f:
        f.write(master)

def main():
    """CLI interface"""
    if len(sys.argv) < 2:
        print("Usage:")
        print("  change-manager.py <project-path> change \"<change-description>\"")
        print("  change-manager.py import <source-path> <project-name> [description]")
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == "import":
        if len(sys.argv) < 4:
            print("Usage: change-manager.py import <source-path> <project-name> [description]")
            sys.exit(1)
        
        source_path = sys.argv[2]
        project_name = sys.argv[3]
        description = ' '.join(sys.argv[4:]) if len(sys.argv) > 4 else None
        
        swarm_path = Path(__file__).parent.parent
        result = import_existing_project(source_path, swarm_path, project_name, description)
        
        print("✓", result['message'])
        print(f"  Project path: {result['project_path']}")
        print(f"  Languages: {', '.join(result['analysis']['languages'])}")
        print(f"  Files: {result['analysis']['file_count']}")
        
    else:
        # Process change request
        project_path = sys.argv[1]
        if len(sys.argv) > 2 and sys.argv[2] == "change":
            change = ' '.join(sys.argv[3:])
            
            manager = ChangeManager(project_path)
            result = manager.process_change_request(change)
            
            print("=" * 60)
            print("CHANGE REQUEST PROCESSED")
            print("=" * 60)
            print(result['implementation_plan'])
            print("\n✓ Change request saved to changes/ directory")

if __name__ == "__main__":
    main()