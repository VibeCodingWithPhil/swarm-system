#!/usr/bin/env python3

"""
Code Checker - Analyzes existing code to prevent duplicate work
"""

import os
import json
import re
from pathlib import Path
from datetime import datetime

def check_existing_code(project_path):
    """Analyze what code already exists in the project"""
    
    workspace = Path(project_path) / "workspace"
    analysis = {
        "timestamp": datetime.now().isoformat(),
        "existing_files": {},
        "implemented_features": [],
        "tests_found": [],
        "todos_remaining": [],
        "completion_percentage": 0
    }
    
    # Check workspace directory
    if workspace.exists():
        for root, dirs, files in os.walk(workspace):
            # Skip hidden and cache directories
            dirs[:] = [d for d in dirs if not d.startswith('.') and d != '__pycache__']
            
            for file in files:
                if file.startswith('.'):
                    continue
                    
                file_path = Path(root) / file
                rel_path = file_path.relative_to(workspace)
                
                # Analyze file content
                try:
                    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read()
                        
                    analysis["existing_files"][str(rel_path)] = {
                        "size": len(content),
                        "lines": content.count('\n'),
                        "type": detect_file_type(file),
                        "features": extract_features_from_code(content, file)
                    }
                    
                    # Check for tests
                    if 'test' in file.lower() or 'spec' in file.lower():
                        analysis["tests_found"].append(str(rel_path))
                    
                    # Extract TODOs
                    todos = re.findall(r'(?:TODO|FIXME|XXX):\s*(.+)', content)
                    analysis["todos_remaining"].extend(todos)
                    
                except Exception as e:
                    print(f"Error reading {file_path}: {e}")
    
    # Check what features are implemented
    analysis["implemented_features"] = detect_implemented_features(analysis["existing_files"])
    
    # Calculate completion
    analysis["completion_percentage"] = calculate_completion(project_path, analysis)
    
    return analysis

def detect_file_type(filename):
    """Detect the type of file"""
    ext = Path(filename).suffix.lower()
    
    type_map = {
        '.py': 'python',
        '.js': 'javascript',
        '.ts': 'typescript',
        '.jsx': 'react',
        '.tsx': 'react-typescript',
        '.java': 'java',
        '.go': 'golang',
        '.rs': 'rust',
        '.cpp': 'cpp',
        '.c': 'c',
        '.html': 'html',
        '.css': 'css',
        '.scss': 'scss',
        '.json': 'json',
        '.yaml': 'yaml',
        '.yml': 'yaml',
        '.md': 'markdown',
        '.sql': 'sql',
        '.sh': 'shell',
        '.dockerfile': 'docker',
        'Dockerfile': 'docker',
        'docker-compose.yml': 'docker-compose',
        'docker-compose.yaml': 'docker-compose'
    }
    
    if filename == 'Dockerfile':
        return 'docker'
    
    return type_map.get(ext, 'unknown')

def extract_features_from_code(content, filename):
    """Extract implemented features from code"""
    features = []
    
    # Check for common patterns
    patterns = {
        'auth': r'(?:login|logout|authenticate|authorization|jwt|token)',
        'database': r'(?:database|db|sql|mongo|postgres|mysql|connect)',
        'api': r'(?:api|endpoint|route|REST|graphql|query|mutation)',
        'testing': r'(?:test|spec|describe|it\(|expect|assert)',
        'docker': r'(?:docker|container|compose|kubernetes|k8s)',
        'frontend': r'(?:react|vue|angular|component|render|useState)',
        'backend': r'(?:express|fastapi|django|flask|spring|server)',
        'security': r'(?:encrypt|decrypt|hash|salt|cors|helmet|sanitize)',
        'validation': r'(?:validate|validator|schema|joi|yup|zod)',
        'realtime': r'(?:websocket|socket\.io|ws|realtime|pubsub)',
        'payment': r'(?:stripe|payment|billing|subscription|checkout)',
        'email': r'(?:email|mail|smtp|sendgrid|nodemailer)',
        'file-upload': r'(?:upload|multer|file|multipart|s3)',
        'cache': r'(?:cache|redis|memcache|ttl)',
        'queue': r'(?:queue|job|worker|celery|bull|rabbitmq)'
    }
    
    content_lower = content.lower()
    for feature, pattern in patterns.items():
        if re.search(pattern, content_lower):
            features.append(feature)
    
    return list(set(features))

def detect_implemented_features(existing_files):
    """Detect what major features are implemented"""
    features = set()
    
    for filepath, info in existing_files.items():
        features.update(info.get('features', []))
        
        # Check for specific files that indicate features
        if 'auth' in filepath.lower() or 'login' in filepath.lower():
            features.add('authentication')
        if 'test' in filepath.lower() or 'spec' in filepath.lower():
            features.add('testing')
        if 'docker' in filepath.lower():
            features.add('containerization')
        if 'api' in filepath.lower() or 'route' in filepath.lower():
            features.add('api')
        if 'model' in filepath.lower() or 'schema' in filepath.lower():
            features.add('data-models')
    
    return list(features)

def calculate_completion(project_path, analysis):
    """Calculate project completion percentage"""
    
    # Check phase status
    phase_file = Path(project_path) / "coordination" / "phase-status.json"
    if phase_file.exists():
        try:
            with open(phase_file, 'r') as f:
                phase_data = json.load(f)
                
            current_phase = phase_data.get('current_phase', 1)
            total_phases = 4
            
            # Calculate phase completion
            phase_completion = 0
            phase_key = f'phase_{current_phase}'
            if phase_key in phase_data:
                terminals = phase_data[phase_key].get('terminals', {})
                completed = sum(1 for t in terminals.values() if t.get('status') == 'COMPLETED')
                total = len(terminals)
                if total > 0:
                    phase_completion = (completed / total) * 100
            
            # Overall completion
            base_completion = ((current_phase - 1) / total_phases) * 100
            current_phase_contribution = (phase_completion / total_phases)
            
            return min(base_completion + current_phase_contribution, 100)
            
        except Exception as e:
            print(f"Error reading phase status: {e}")
    
    # Fallback: estimate based on files
    file_count = len(analysis.get('existing_files', {}))
    test_count = len(analysis.get('tests_found', []))
    
    if file_count == 0:
        return 0
    
    # Basic heuristic
    base = min(file_count * 5, 50)  # Up to 50% for having files
    test_bonus = min(test_count * 10, 30)  # Up to 30% for tests
    feature_bonus = min(len(analysis.get('implemented_features', [])) * 5, 20)  # Up to 20% for features
    
    return min(base + test_bonus + feature_bonus, 100)

def generate_resume_data(project_path, analysis):
    """Generate data for resuming work"""
    
    resume_data = {
        "analysis": analysis,
        "next_tasks": [],
        "skip_tasks": [],
        "focus_areas": []
    }
    
    # Determine what to skip
    for feature in analysis["implemented_features"]:
        resume_data["skip_tasks"].append(f"Skip {feature} - already implemented")
    
    # Determine what to focus on
    if analysis["completion_percentage"] < 25:
        resume_data["focus_areas"].append("Foundation and setup")
    elif analysis["completion_percentage"] < 50:
        resume_data["focus_areas"].append("Core features implementation")
    elif analysis["completion_percentage"] < 75:
        resume_data["focus_areas"].append("Advanced features and integration")
    else:
        resume_data["focus_areas"].append("Testing, optimization, and deployment")
    
    # Add TODOs as next tasks
    resume_data["next_tasks"] = analysis["todos_remaining"][:5]
    
    # Save resume data
    resume_file = Path(project_path) / "coordination" / "resume-data.json"
    with open(resume_file, 'w') as f:
        json.dump(resume_data, f, indent=2)
    
    return resume_data

def main():
    """Main function for command-line usage"""
    import sys
    
    if len(sys.argv) != 2:
        print("Usage: code-checker.py <project-path>")
        sys.exit(1)
    
    project_path = sys.argv[1]
    
    print(f"Analyzing existing code in {project_path}...")
    analysis = check_existing_code(project_path)
    
    print(f"\nFound {len(analysis['existing_files'])} existing files")
    print(f"Implemented features: {', '.join(analysis['implemented_features'])}")
    print(f"Tests found: {len(analysis['tests_found'])}")
    print(f"Completion: {analysis['completion_percentage']:.1f}%")
    
    if analysis['todos_remaining']:
        print(f"\nRemaining TODOs:")
        for todo in analysis['todos_remaining'][:5]:
            print(f"  - {todo}")
    
    # Generate resume data
    resume_data = generate_resume_data(project_path, analysis)
    print(f"\nResume data saved to coordination/resume-data.json")
    print(f"Focus areas: {', '.join(resume_data['focus_areas'])}")

if __name__ == "__main__":
    main()