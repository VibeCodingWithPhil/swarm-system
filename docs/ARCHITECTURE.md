# Swarm System Architecture

## Overview

Swarm System orchestrates multiple AI agents to collaborate on software development projects through a sophisticated phase-based approach.

## Core Components

### 1. Project Analyzer (`analyze-project.py`)
- Parses project descriptions
- Detects project type and requirements
- Generates terminal-specific todo lists
- Creates 4-phase development structure

### 2. Code Checker (`code-checker.py`)
- Analyzes existing code in workspace
- Detects implemented features
- Calculates completion percentage
- Prevents duplicate work

### 3. Phase Prompter (`phase-prompter.py`)
- Generates context-aware prompts for each phase
- Includes completed work to maintain continuity
- Creates terminal-specific instructions
- Manages phase transitions

### 4. Prompt Enhancer (`prompt-enhancer.py`)
- Applies context engineering to prompts
- Detects technologies and features
- Adds quality requirements
- Structures success criteria

### 5. Change Manager (`change-manager.py`)
- Processes change requests
- Imports existing projects
- Generates new phases for changes
- Maintains project state

### 6. Task Tracker (`task-tracker.py`)
- Monitors task completion
- Prevents duplication
- Merges new requests
- Provides progress metrics

### 7. Kanban Server (`kanban/server.py`)
- Real-time web interface
- WebSocket updates
- File system monitoring
- Multi-project support

## Data Flow

```
User Input → Prompt Enhancement → Project Analysis
    ↓
Todo Generation → Phase Planning → Terminal Launch
    ↓
Code Checking → Task Distribution → Agent Work
    ↓
Progress Tracking → Phase Advancement → Completion
```

## File Structure

### Project Directory
```
project-name/
├── todo/                  # Task lists
│   ├── terminal-1.md
│   ├── terminal-2.md
│   ├── terminal-3.md
│   ├── terminal-4.md
│   ├── terminal-5.md
│   └── MASTER-CHECKLIST.md
├── coordination/          # Status tracking
│   ├── phase-status.json
│   ├── task-tracking.json
│   └── resume-data.json
├── prompts/              # Generated prompts
│   ├── phase-1-terminal-*.md
│   └── phase-*-all-terminals.md
├── workspace/            # Actual code
├── logs/                 # Execution logs
├── changes/              # Change requests
└── swarm.config          # Project configuration
```

## Terminal Specialization

### Terminal 1: Backend Architecture
- System design
- API structure
- Database schema
- Authentication
- Core services

### Terminal 2: Data & Integration
- Database operations
- External APIs
- Third-party services
- Data migration
- Caching

### Terminal 3: Frontend & UI
- User interface
- Component development
- State management
- Responsive design
- User experience

### Terminal 4: Features & Logic
- Business rules
- Feature implementation
- Workflow automation
- Integration coordination
- Feature testing

### Terminal 5: DevOps & Quality
- Testing suite
- CI/CD pipeline
- Docker configuration
- Performance optimization
- Security hardening

## Phase Structure

### Phase 1: Foundation (25%)
- Environment setup
- Project scaffolding
- Tool configuration
- Basic structure
- Initial tests

### Phase 2: Core (35%)
- Main functionality
- Data models
- Primary APIs
- Core UI
- Authentication

### Phase 3: Advanced (25%)
- Advanced features
- Integrations
- UI enhancements
- Monitoring
- Optimization

### Phase 4: Production (15%)
- Complete testing
- Documentation
- Deployment setup
- Security hardening
- Final polish

## Communication Protocol

### Phase Status
```json
{
  "current_phase": 1,
  "phase_1": {
    "status": "ACTIVE",
    "terminals": {
      "1": {"status": "WORKING", "progress": 50},
      "2": {"status": "WORKING", "progress": 30},
      ...
    }
  }
}
```

### Task Tracking
```json
{
  "tasks": {
    "task_id": {
      "text": "Task description",
      "completed": false,
      "terminal": 1,
      "phase": 1
    }
  }
}
```

## Security Considerations

- Read-only Kanban interface
- No external network access for agents
- Isolated Docker testing environment
- Local file system operations only
- No credential storage in configs