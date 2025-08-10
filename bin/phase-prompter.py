#!/usr/bin/env python3

"""
Phase Prompter - Generates context-aware prompts for each phase transition
"""

import json
import sys
from pathlib import Path
from datetime import datetime

def generate_phase_prompt(project_path, terminal_num, next_phase):
    """Generate a detailed prompt for the next phase"""
    
    # Load project config
    config_file = Path(project_path) / "swarm.config"
    project_name = "Project"
    project_prompt = ""
    
    if config_file.exists():
        with open(config_file, 'r') as f:
            for line in f:
                if line.startswith('PROJECT_NAME='):
                    project_name = line.split('=', 1)[1].strip().strip('"')
                elif line.startswith('PROJECT_PROMPT='):
                    project_prompt = line.split('=', 1)[1].strip().strip('"')
    
    # Load phase data
    phase_file = Path(project_path) / "coordination" / "phase-status.json"
    phase_data = {}
    if phase_file.exists():
        with open(phase_file, 'r') as f:
            phase_data = json.load(f)
    
    # Load completed work analysis
    resume_file = Path(project_path) / "coordination" / "resume-data.json"
    completed_features = []
    if resume_file.exists():
        with open(resume_file, 'r') as f:
            resume_data = json.load(f)
            completed_features = resume_data.get('analysis', {}).get('implemented_features', [])
    
    # Get terminal's task for next phase
    phase_key = f"phase_{next_phase}"
    terminal_task = phase_data.get(phase_key, {}).get('terminals', {}).get(str(terminal_num), {})
    task_name = terminal_task.get('task', 'Continue development')
    
    # Generate context-aware prompt
    prompt = f"""
================================================================================
TERMINAL {terminal_num} - PHASE {next_phase} PROMPT
================================================================================

PROJECT: {project_name}
DESCRIPTION: {project_prompt}
CURRENT PHASE: {next_phase} - {phase_data.get(phase_key, {}).get('name', 'Development')}

YOUR SPECIFIC TASK: {task_name}

================================================================================
CONTEXT & COMPLETED WORK
================================================================================

ALREADY IMPLEMENTED (DO NOT DUPLICATE):
{chr(10).join(f'✓ {feature}' for feature in completed_features) if completed_features else '- No features completed yet'}

FILES IN WORKSPACE:
Check workspace/ directory for existing code and build upon it.

================================================================================
DETAILED PHASE {next_phase} REQUIREMENTS
================================================================================
"""
    
    # Add phase-specific detailed requirements
    if next_phase == 1:
        prompt += """
FOUNDATION PHASE REQUIREMENTS:

1. PROJECT STRUCTURE:
   - Create organized directory structure in workspace/
   - Set up configuration files (package.json, requirements.txt, etc.)
   - Initialize version control (.gitignore)
   - Create README.md with project overview

2. DEVELOPMENT ENVIRONMENT:
   - Set up build tools and scripts
   - Configure linters and formatters
   - Create development vs production configs
   - Set up environment variables structure

3. CORE ARCHITECTURE:
   - Design main application structure
   - Create base classes/modules
   - Set up routing/navigation framework
   - Implement error handling structure

4. DOCKER SETUP:
   - Create Dockerfile for application
   - Set up docker-compose.yml for development
   - Configure test containers
   - Ensure reproducible builds

5. TESTING FRAMEWORK:
   - Set up test directory structure
   - Configure test runners
   - Create initial test files
   - Write tests for any code you create

DELIVERABLES:
- Complete project structure in workspace/
- All configuration files
- Docker setup working
- Basic tests passing
- Clear documentation
"""
    
    elif next_phase == 2:
        prompt += """
CORE FEATURES PHASE REQUIREMENTS:

1. MAIN FUNCTIONALITY:
   - Implement primary business logic
   - Create core data models/schemas
   - Build essential API endpoints/routes
   - Implement data validation

2. DATABASE/STORAGE:
   - Set up database connections
   - Create migration files
   - Implement CRUD operations
   - Add data persistence layer

3. USER INTERFACE (if applicable):
   - Build main UI components
   - Implement navigation
   - Create forms and inputs
   - Add basic styling

4. AUTHENTICATION (if needed):
   - User registration/login
   - Session management
   - Authorization checks
   - Security middleware

5. INTEGRATION:
   - Connect frontend to backend
   - Wire up database operations
   - Implement state management
   - Add error handling

DELIVERABLES:
- Working core features
- Database operations functional
- UI/API responding correctly
- Authentication working (if needed)
- Integration tests passing
"""
    
    elif next_phase == 3:
        prompt += """
ADVANCED FEATURES PHASE REQUIREMENTS:

1. ADDITIONAL FUNCTIONALITY:
   - Implement secondary features
   - Add advanced operations
   - Create specialized components
   - Build complex workflows

2. PERFORMANCE OPTIMIZATION:
   - Add caching layers
   - Optimize database queries
   - Implement lazy loading
   - Reduce bundle sizes

3. THIRD-PARTY INTEGRATIONS:
   - External API connections
   - Payment processing (if needed)
   - Email/notification services
   - Analytics integration

4. ADVANCED UI/UX:
   - Responsive design
   - Animations and transitions
   - Accessibility features
   - Progressive enhancement

5. MONITORING & LOGGING:
   - Application logging
   - Error tracking
   - Performance monitoring
   - Health check endpoints

DELIVERABLES:
- All advanced features working
- Performance improvements measurable
- Integrations functional
- Enhanced UI/UX complete
- Monitoring in place
"""
    
    elif next_phase == 4:
        prompt += """
POLISH & DEPLOYMENT PHASE REQUIREMENTS:

1. FINAL TESTING:
   - Complete test coverage
   - End-to-end testing
   - Load testing
   - Security testing

2. DOCUMENTATION:
   - API documentation
   - User guide
   - Developer documentation
   - Deployment guide

3. PRODUCTION READINESS:
   - Production configurations
   - Environment variables
   - Secrets management
   - SSL/TLS setup

4. DEPLOYMENT SETUP:
   - CI/CD pipeline configuration
   - Deployment scripts
   - Rollback procedures
   - Monitoring setup

5. FINAL POLISH:
   - UI refinements
   - Performance tuning
   - Bug fixes
   - Code cleanup

DELIVERABLES:
- 80%+ test coverage
- Complete documentation
- Production-ready code
- Deployment automated
- All bugs fixed
"""
    
    prompt += f"""
================================================================================
WORKING INSTRUCTIONS
================================================================================

1. CHECK EXISTING CODE:
   - Run: ls -la workspace/
   - Review what's already implemented
   - Build upon existing work, don't duplicate

2. IMPLEMENT YOUR TASK:
   - Focus on: {task_name}
   - Write clean, documented code
   - Follow project conventions
   - Create modular, reusable components

3. WRITE TESTS:
   - Create tests in tests/ directory
   - Test all new functionality
   - Run: docker-compose -f docker-compose.test.yml up
   - Ensure tests pass before marking complete

4. UPDATE PROGRESS:
   - Update phase-status.json with your progress (25%, 50%, 75%, 100%)
   - Mark task as COMPLETED when done
   - Document any blockers or issues

5. COORDINATE:
   - Check what other terminals are doing
   - Avoid conflicts and duplication
   - Share common utilities
   - Maintain consistent coding style

================================================================================
START NOW
================================================================================

Begin by:
1. Check workspace/ for existing code
2. Read your complete todo list at todo/terminal-{terminal_num}.md
3. Implement {task_name} with tests
4. Update phase-status.json regularly

Remember: Quality over speed. Write production-ready code with tests.
"""
    
    return prompt

def generate_all_phase_prompts(project_path, phase_num):
    """Generate prompts for all 5 terminals for a specific phase"""
    
    prompts = {}
    for terminal in range(1, 6):
        prompt = generate_phase_prompt(project_path, terminal, phase_num)
        
        # Save to file
        prompt_file = Path(project_path) / "prompts" / f"phase-{phase_num}-terminal-{terminal}.md"
        prompt_file.parent.mkdir(exist_ok=True)
        
        with open(prompt_file, 'w') as f:
            f.write(prompt)
        
        prompts[terminal] = prompt
    
    # Create a master prompt file with all terminals
    master_file = Path(project_path) / "prompts" / f"phase-{phase_num}-all-terminals.md"
    with open(master_file, 'w') as f:
        f.write(f"# PHASE {phase_num} PROMPTS - ALL TERMINALS\n\n")
        f.write("Copy the appropriate prompt to each terminal when transitioning to this phase.\n\n")
        f.write("=" * 80 + "\n\n")
        
        for terminal, prompt in prompts.items():
            f.write(f"## TERMINAL {terminal}\n")
            f.write("```\n")
            f.write(prompt)
            f.write("```\n\n")
            f.write("=" * 80 + "\n\n")
    
    return prompts

def main():
    if len(sys.argv) < 2:
        print("Usage: phase-prompter.py <project-path> [phase-num]")
        sys.exit(1)
    
    project_path = sys.argv[1]
    phase_num = int(sys.argv[2]) if len(sys.argv) > 2 else None
    
    if phase_num:
        # Generate for specific phase
        print(f"Generating prompts for Phase {phase_num}...")
        prompts = generate_all_phase_prompts(project_path, phase_num)
        print(f"✓ Generated prompts for {len(prompts)} terminals")
        print(f"✓ Saved to prompts/phase-{phase_num}-*.md")
    else:
        # Generate for all phases
        for phase in range(1, 5):
            print(f"Generating prompts for Phase {phase}...")
            generate_all_phase_prompts(project_path, phase)
        print("✓ Generated prompts for all 4 phases")

if __name__ == "__main__":
    main()