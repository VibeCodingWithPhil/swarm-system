#!/usr/bin/env python3

"""
Project Analyzer - Automatically generates todos and phases for any project
"""

import sys
import json
import os
from pathlib import Path

def analyze_project(project_name, project_prompt, project_path):
    """Analyze project requirements and generate todos for 5 terminals"""
    
    # Parse the project prompt to understand requirements
    prompt_lower = project_prompt.lower()
    
    # Determine project type and complexity
    project_type = detect_project_type(prompt_lower)
    features = extract_features(prompt_lower)
    
    # Generate phase structure
    phases = generate_phases(project_type, features)
    
    # Generate todos for each terminal
    todos = generate_todos(project_type, features, phases)
    
    # Write todo files
    for term_num in range(1, 6):
        todo_file = Path(project_path) / "todo" / f"terminal-{term_num}.md"
        with open(todo_file, 'w') as f:
            f.write(todos[term_num])
    
    # Write master checklist
    master_file = Path(project_path) / "todo" / "MASTER-CHECKLIST.md"
    with open(master_file, 'w') as f:
        f.write(generate_master_checklist(project_name, project_prompt, phases))
    
    # Write phase status
    phase_file = Path(project_path) / "coordination" / "phase-status.json"
    with open(phase_file, 'w') as f:
        json.dump(phases, f, indent=2)
    
    print(f"✓ Generated {len(todos)} terminal todo lists")
    print(f"✓ Created {len(phases)-1} development phases")

def detect_project_type(prompt):
    """Detect the type of project from the prompt"""
    
    types = {
        'webapp': ['web', 'website', 'frontend', 'react', 'vue', 'angular', 'next'],
        'api': ['api', 'backend', 'rest', 'graphql', 'microservice'],
        'mobile': ['mobile', 'ios', 'android', 'react native', 'flutter'],
        'ml': ['machine learning', 'ml', 'ai', 'neural', 'model', 'training'],
        'cli': ['cli', 'command line', 'terminal', 'console'],
        'game': ['game', 'unity', 'unreal', 'godot', '2d', '3d'],
        'blockchain': ['blockchain', 'web3', 'smart contract', 'defi', 'nft'],
        'devops': ['devops', 'kubernetes', 'docker', 'ci/cd', 'infrastructure']
    }
    
    for project_type, keywords in types.items():
        if any(keyword in prompt for keyword in keywords):
            return project_type
    
    return 'general'

def extract_features(prompt):
    """Extract required features from the prompt"""
    
    features = []
    
    feature_keywords = {
        'auth': ['auth', 'login', 'user', 'account', 'signup'],
        'database': ['database', 'db', 'postgres', 'mysql', 'mongodb', 'data'],
        'payment': ['payment', 'billing', 'stripe', 'subscription', 'checkout'],
        'realtime': ['realtime', 'real-time', 'websocket', 'live', 'chat'],
        'testing': ['test', 'testing', 'tdd', 'unit test', 'e2e'],
        'api': ['api', 'endpoint', 'rest', 'graphql'],
        'ui': ['ui', 'interface', 'design', 'ux', 'frontend'],
        'security': ['security', 'secure', 'encryption', 'ssl', 'https'],
        'analytics': ['analytics', 'metrics', 'tracking', 'dashboard'],
        'search': ['search', 'elasticsearch', 'algolia', 'filter'],
        'files': ['file', 'upload', 'storage', 's3', 'media'],
        'email': ['email', 'mail', 'notification', 'smtp'],
        'admin': ['admin', 'management', 'cms', 'panel'],
        'mobile': ['mobile', 'responsive', 'pwa', 'app'],
        'performance': ['performance', 'optimization', 'cache', 'cdn']
    }
    
    for feature, keywords in feature_keywords.items():
        if any(keyword in prompt for keyword in keywords):
            features.append(feature)
    
    return features

def generate_phases(project_type, features):
    """Generate development phases based on project type"""
    
    base_phases = {
        "current_phase": 1,
        "phase_1": {
            "name": "Foundation & Setup",
            "status": "ACTIVE",
            "terminals": {}
        },
        "phase_2": {
            "name": "Core Features",
            "status": "PENDING",
            "terminals": {}
        },
        "phase_3": {
            "name": "Advanced Features",
            "status": "PENDING",
            "terminals": {}
        },
        "phase_4": {
            "name": "Polish & Deployment",
            "status": "PENDING",
            "terminals": {}
        }
    }
    
    # Assign tasks based on project type
    if project_type == 'webapp':
        base_phases["phase_1"]["terminals"] = {
            "1": {"task": "Project setup & build configuration", "status": "NOT_STARTED", "progress": 0},
            "2": {"task": "Backend API structure", "status": "NOT_STARTED", "progress": 0},
            "3": {"task": "Frontend framework setup", "status": "NOT_STARTED", "progress": 0},
            "4": {"task": "Database schema design", "status": "NOT_STARTED", "progress": 0},
            "5": {"task": "Development environment & tooling", "status": "NOT_STARTED", "progress": 0}
        }
        base_phases["phase_2"]["terminals"] = {
            "1": {"task": "Authentication system", "status": "WAITING", "progress": 0},
            "2": {"task": "Core API endpoints", "status": "WAITING", "progress": 0},
            "3": {"task": "Main UI components", "status": "WAITING", "progress": 0},
            "4": {"task": "Data models & validation", "status": "WAITING", "progress": 0},
            "5": {"task": "Testing framework", "status": "WAITING", "progress": 0}
        }
    elif project_type == 'api':
        base_phases["phase_1"]["terminals"] = {
            "1": {"task": "API framework setup", "status": "NOT_STARTED", "progress": 0},
            "2": {"task": "Database configuration", "status": "NOT_STARTED", "progress": 0},
            "3": {"task": "Authentication & security", "status": "NOT_STARTED", "progress": 0},
            "4": {"task": "Core endpoints structure", "status": "NOT_STARTED", "progress": 0},
            "5": {"task": "Documentation setup", "status": "NOT_STARTED", "progress": 0}
        }
    elif project_type == 'ml':
        base_phases["phase_1"]["terminals"] = {
            "1": {"task": "Data pipeline setup", "status": "NOT_STARTED", "progress": 0},
            "2": {"task": "Model architecture", "status": "NOT_STARTED", "progress": 0},
            "3": {"task": "Training infrastructure", "status": "NOT_STARTED", "progress": 0},
            "4": {"task": "Evaluation metrics", "status": "NOT_STARTED", "progress": 0},
            "5": {"task": "Experiment tracking", "status": "NOT_STARTED", "progress": 0}
        }
    else:
        # Generic project phases
        base_phases["phase_1"]["terminals"] = {
            "1": {"task": "Core architecture setup", "status": "NOT_STARTED", "progress": 0},
            "2": {"task": "Data layer implementation", "status": "NOT_STARTED", "progress": 0},
            "3": {"task": "Business logic layer", "status": "NOT_STARTED", "progress": 0},
            "4": {"task": "Interface/API layer", "status": "NOT_STARTED", "progress": 0},
            "5": {"task": "Infrastructure & tooling", "status": "NOT_STARTED", "progress": 0}
        }
    
    # Add feature-specific tasks to phase 3
    if features:
        for i, feature in enumerate(features[:5], 1):
            base_phases["phase_3"]["terminals"][str(i)] = {
                "task": f"Implement {feature} feature",
                "status": "WAITING",
                "progress": 0
            }
    
    # Phase 4 is always polish and deployment
    base_phases["phase_4"]["terminals"] = {
        "1": {"task": "Performance optimization", "status": "WAITING", "progress": 0},
        "2": {"task": "Security hardening", "status": "WAITING", "progress": 0},
        "3": {"task": "UI/UX polish", "status": "WAITING", "progress": 0},
        "4": {"task": "Deployment configuration", "status": "WAITING", "progress": 0},
        "5": {"task": "Documentation & testing", "status": "WAITING", "progress": 0}
    }
    
    return base_phases

def generate_todos(project_type, features, phases):
    """Generate detailed todo lists for each terminal"""
    
    todos = {}
    
    # Terminal roles based on project type
    if project_type == 'webapp':
        roles = {
            1: "Backend Architecture",
            2: "API Development",
            3: "Frontend Development",
            4: "Database & Data",
            5: "DevOps & Testing"
        }
    elif project_type == 'api':
        roles = {
            1: "Core API Logic",
            2: "Database Layer",
            3: "Authentication & Security",
            4: "Integration & Middleware",
            5: "Testing & Documentation"
        }
    elif project_type == 'ml':
        roles = {
            1: "Data Engineering",
            2: "Model Development",
            3: "Training Pipeline",
            4: "Evaluation & Metrics",
            5: "Deployment & Serving"
        }
    else:
        roles = {
            1: "Core Architecture",
            2: "Data Management",
            3: "Business Logic",
            4: "Interface Layer",
            5: "Infrastructure"
        }
    
    for term_num in range(1, 6):
        todo_content = f"""# Terminal {term_num} - {roles[term_num]}

## Role
{roles[term_num]}

## Phase 1: {phases['phase_1']['name']}
### Priority 1: {phases['phase_1']['terminals'][str(term_num)]['task']}
- [ ] Initial setup and configuration
- [ ] Create base structure
- [ ] Implement core functionality
- [ ] Write unit tests
- [ ] Document implementation

## Phase 2: {phases['phase_2']['name']}
### Priority 2: {phases['phase_2']['terminals'].get(str(term_num), {}).get('task', 'Core feature implementation')}
- [ ] Design component architecture
- [ ] Implement main features
- [ ] Add error handling
- [ ] Create integration tests
- [ ] Update documentation

## Phase 3: {phases['phase_3']['name']}
### Priority 3: {phases['phase_3']['terminals'].get(str(term_num), {}).get('task', 'Advanced features')}
- [ ] Implement advanced functionality
- [ ] Optimize performance
- [ ] Add monitoring/logging
- [ ] Create end-to-end tests
- [ ] Write user documentation

## Phase 4: {phases['phase_4']['name']}
### Priority 4: {phases['phase_4']['terminals'][str(term_num)]['task']}
- [ ] Final optimizations
- [ ] Security review
- [ ] Deployment preparation
- [ ] Final testing
- [ ] Documentation review

## Coordination
- Check phase-status.json before starting any task
- Update progress regularly (25%, 50%, 75%, 100%)
- Mark tasks as COMPLETED when done
- Wait for phase advancement before moving to next phase
"""
        todos[term_num] = todo_content
    
    return todos

def generate_master_checklist(project_name, project_prompt, phases):
    """Generate master checklist for the project"""
    
    return f"""# {project_name} - Master Implementation Checklist

## Project Description
{project_prompt}

## Current Status
- Current Phase: 1/4
- Started: {os.popen('date').read().strip()}

## Phase Overview

### Phase 1: {phases['phase_1']['name']}
- Terminal 1: {phases['phase_1']['terminals']['1']['task']}
- Terminal 2: {phases['phase_1']['terminals']['2']['task']}
- Terminal 3: {phases['phase_1']['terminals']['3']['task']}
- Terminal 4: {phases['phase_1']['terminals']['4']['task']}
- Terminal 5: {phases['phase_1']['terminals']['5']['task']}

### Phase 2: {phases['phase_2']['name']}
- Terminal 1: {phases['phase_2']['terminals'].get('1', {}).get('task', 'TBD')}
- Terminal 2: {phases['phase_2']['terminals'].get('2', {}).get('task', 'TBD')}
- Terminal 3: {phases['phase_2']['terminals'].get('3', {}).get('task', 'TBD')}
- Terminal 4: {phases['phase_2']['terminals'].get('4', {}).get('task', 'TBD')}
- Terminal 5: {phases['phase_2']['terminals'].get('5', {}).get('task', 'TBD')}

### Phase 3: {phases['phase_3']['name']}
- Terminal 1: {phases['phase_3']['terminals'].get('1', {}).get('task', 'TBD')}
- Terminal 2: {phases['phase_3']['terminals'].get('2', {}).get('task', 'TBD')}
- Terminal 3: {phases['phase_3']['terminals'].get('3', {}).get('task', 'TBD')}
- Terminal 4: {phases['phase_3']['terminals'].get('4', {}).get('task', 'TBD')}
- Terminal 5: {phases['phase_3']['terminals'].get('5', {}).get('task', 'TBD')}

### Phase 4: {phases['phase_4']['name']}
- Terminal 1: {phases['phase_4']['terminals']['1']['task']}
- Terminal 2: {phases['phase_4']['terminals']['2']['task']}
- Terminal 3: {phases['phase_4']['terminals']['3']['task']}
- Terminal 4: {phases['phase_4']['terminals']['4']['task']}
- Terminal 5: {phases['phase_4']['terminals']['5']['task']}

## Coordination Protocol
1. Each terminal works on assigned tasks only
2. Update phase-status.json with progress
3. Mark tasks COMPLETED when done
4. System auto-advances when all terminals complete phase
5. Check this file for task assignments

## Success Metrics
- [ ] All Phase 1 tasks completed
- [ ] All Phase 2 tasks completed
- [ ] All Phase 3 tasks completed
- [ ] All Phase 4 tasks completed
- [ ] Tests passing
- [ ] Documentation complete
- [ ] Deployment ready
"""

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: analyze-project.py <project-name> <project-prompt> <project-path>")
        sys.exit(1)
    
    project_name = sys.argv[1]
    project_prompt = sys.argv[2]
    project_path = sys.argv[3]
    
    analyze_project(project_name, project_prompt, project_path)