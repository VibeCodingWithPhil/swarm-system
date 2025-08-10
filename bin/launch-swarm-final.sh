#!/bin/bash

# Final Enhanced Swarm Launcher with all features

PROJECT_PATH="$1"
PROJECT_NAME="$2"
CLAUDE_CMD="$HOME/.claude/local/claude"
SWARM_HOME="$(cd "$(dirname "$0")/.." && pwd)"

if [ -z "$PROJECT_PATH" ] || [ -z "$PROJECT_NAME" ]; then
    echo "Error: Missing parameters"
    exit 1
fi

cd "$PROJECT_PATH"

echo "========================================"
echo "  Enhanced Swarm Launcher: $PROJECT_NAME"
echo "========================================"
echo ""

# Check existing code
echo "Analyzing existing code..."
python3 "$SWARM_HOME/bin/code-checker.py" "$PROJECT_PATH"

# Generate all phase prompts
echo "Generating phase prompts..."
python3 "$SWARM_HOME/bin/phase-prompter.py" "$PROJECT_PATH"

# Create Docker configuration
cat > "$PROJECT_PATH/docker-compose.test.yml" << 'EOF'
version: '3.8'

services:
  test-runner:
    build:
      context: ./workspace
      dockerfile: Dockerfile.test
    volumes:
      - ./workspace:/app
      - ./tests:/tests
    environment:
      - NODE_ENV=test
      - PYTHONPATH=/app
    command: |
      sh -c "
        echo 'Running tests...';
        if [ -f /app/package.json ]; then npm test; fi;
        if [ -f /app/requirements.txt ]; then pytest /tests; fi;
        if [ -f /app/go.mod ]; then go test ./...; fi;
      "

  test-db:
    image: postgres:15-alpine
    environment:
      POSTGRES_PASSWORD: test
      POSTGRES_DB: test
    tmpfs:
      - /var/lib/postgresql/data
EOF

# Create enhanced phase controller
cat > "$PROJECT_PATH/phase-controller-enhanced.sh" << 'CONTROLLER'
#!/bin/bash

PROJECT_PATH="$(pwd)"
SWARM_HOME="SWARM_HOME_PLACEHOLDER"

echo "========================================"
echo "    Enhanced Phase Controller"
echo "========================================"

show_status() {
    if [ -f "$PROJECT_PATH/coordination/phase-status.json" ]; then
        python3 -c "
import json
with open('$PROJECT_PATH/coordination/phase-status.json', 'r') as f:
    data = json.load(f)
    phase = data['current_phase']
    print(f'\\nPhase {phase}: {data[f\"phase_{phase}\"][\"name\"]}\\n')
    
    completed = 0
    total = 0
    for tid, tdata in data[f'phase_{phase}']['terminals'].items():
        status = tdata['status']
        progress = tdata['progress']
        if status == 'COMPLETED':
            completed += 1
        total += 1
        print(f'Terminal {tid}: {status} ({progress}%) - {tdata[\"task\"]}')
    
    print(f'\\nPhase Progress: {completed}/{total} terminals complete')
    
    if completed == total:
        print('\\n✓ PHASE COMPLETE! Ready to advance.')
        print('\\nNext phase prompts available at:')
        next_phase = phase + 1
        if next_phase <= 4:
            print(f'  prompts/phase-{next_phase}-all-terminals.md')
        " 2>/dev/null
    fi
}

advance_phase() {
    python3 -c "
import json
with open('$PROJECT_PATH/coordination/phase-status.json', 'r+') as f:
    data = json.load(f)
    phase = data['current_phase']
    
    # Check completion
    all_done = all(
        t['status'] == 'COMPLETED' 
        for t in data[f'phase_{phase}']['terminals'].values()
    )
    
    if all_done and phase < 4:
        next_phase = phase + 1
        data['current_phase'] = next_phase
        data[f'phase_{phase}']['status'] = 'COMPLETED'
        data[f'phase_{next_phase}']['status'] = 'ACTIVE'
        
        for tid in data[f'phase_{next_phase}']['terminals']:
            data[f'phase_{next_phase}']['terminals'][tid]['status'] = 'NOT_STARTED'
            data[f'phase_{next_phase}']['terminals'][tid]['progress'] = 0
        
        f.seek(0)
        json.dump(data, f, indent=2)
        f.truncate()
        
        print(f'✓ Advanced to Phase {next_phase}')
        print(f'\\nPHASE {next_phase} PROMPTS READY!')
        print(f'Copy prompts from: prompts/phase-{next_phase}-all-terminals.md')
        print('Paste the appropriate prompt to each terminal.')
        
        # Generate new prompts if needed
        import subprocess
        subprocess.run(['python3', '$SWARM_HOME/bin/phase-prompter.py', '$PROJECT_PATH', str(next_phase)])
        
    elif phase >= 4:
        print('All phases complete!')
    else:
        print('Current phase not complete')
    " 2>/dev/null
}

show_prompts() {
    CURRENT_PHASE=$(python3 -c "
import json
with open('$PROJECT_PATH/coordination/phase-status.json', 'r') as f:
    print(json.load(f)['current_phase'])
" 2>/dev/null)
    
    echo ""
    echo "Current Phase: $CURRENT_PHASE"
    echo "Prompt files available:"
    ls -la prompts/phase-${CURRENT_PHASE}-*.md 2>/dev/null || echo "No prompts generated yet"
    echo ""
    echo "To view a prompt:"
    echo "  cat prompts/phase-${CURRENT_PHASE}-terminal-1.md"
}

while true; do
    clear
    show_status
    echo ""
    echo "Commands:"
    echo "  [Enter] - Refresh status"
    echo "  [a]     - Advance to next phase"
    echo "  [p]     - Show prompt files" 
    echo "  [t]     - Run tests"
    echo "  [c]     - Check existing code"
    echo "  [q]     - Quit"
    echo ""
    read -r -n 1 choice
    
    case $choice in
        a|A) 
            advance_phase
            echo ""
            echo "Press any key to continue..."
            read -n 1
            ;;
        p|P)
            show_prompts
            echo "Press any key to continue..."
            read -n 1
            ;;
        t|T)
            echo "Running tests..."
            docker-compose -f docker-compose.test.yml up
            echo "Press any key to continue..."
            read -n 1
            ;;
        c|C)
            python3 "$SWARM_HOME/bin/code-checker.py" "$PROJECT_PATH"
            echo "Press any key to continue..."
            read -n 1
            ;;
        q|Q) 
            exit 0 
            ;;
    esac
done
CONTROLLER

# Replace placeholder
sed -i '' "s|SWARM_HOME_PLACEHOLDER|$SWARM_HOME|g" "$PROJECT_PATH/phase-controller-enhanced.sh" 2>/dev/null || 
sed -i "s|SWARM_HOME_PLACEHOLDER|$SWARM_HOME|g" "$PROJECT_PATH/phase-controller-enhanced.sh"

chmod +x "$PROJECT_PATH/phase-controller-enhanced.sh"

# Launch enhanced phase controller
osascript << EOF
tell application "Terminal"
    activate
    
    -- Create control window
    set controlWindow to do script "cd '$PROJECT_PATH' && ./phase-controller-enhanced.sh"
    
    -- Use Basic profile to avoid highlighting
    set current settings of controlWindow to settings set "Basic"
end tell
EOF

sleep 2

# Launch 5 terminals with phase awareness
for i in {1..5}; do
    cat > "$PROJECT_PATH/launch-term-$i.sh" << LAUNCH_SCRIPT
#!/bin/bash
TERM_NUM=$i
PROJECT_PATH="$PROJECT_PATH"
PROJECT_NAME="$PROJECT_NAME"
SWARM_HOME="$SWARM_HOME"

# Terminal settings
export TERM=xterm-256color
export CLICOLOR=0
clear

echo "========================================"
echo "  Terminal \$TERM_NUM: $PROJECT_NAME"
echo "========================================"
echo ""

# Check existing code
echo "Checking existing code..."
RESUME_DATA=\$(cat "\$PROJECT_PATH/coordination/resume-data.json" 2>/dev/null || echo "{}")

if [ "\$RESUME_DATA" != "{}" ]; then
    python3 -c "
import json
data = json.loads('''\$RESUME_DATA''')
features = data.get('analysis', {}).get('implemented_features', [])
if features:
    print('Already implemented:', ', '.join(features))
completion = data.get('analysis', {}).get('completion_percentage', 0)
print(f'Project completion: {completion:.1f}%')
    " 2>/dev/null
fi

# Get current phase
CURRENT_PHASE=\$(python3 -c "
import json
with open('\$PROJECT_PATH/coordination/phase-status.json', 'r') as f:
    data = json.load(f)
    phase = data['current_phase']
    task = data[f'phase_{phase}']['terminals'][str(\$TERM_NUM)]['task']
    print(f'Phase {phase}: {task}')
" 2>/dev/null)

echo ""
echo "Your task: \$CURRENT_PHASE"
echo ""

# Update status
python3 -c "
import json
with open('\$PROJECT_PATH/coordination/phase-status.json', 'r+') as f:
    data = json.load(f)
    phase = data['current_phase']
    data[f'phase_{phase}']['terminals'][str(\$TERM_NUM)]['status'] = 'WORKING'
    f.seek(0)
    json.dump(data, f, indent=2)
    f.truncate()
" 2>/dev/null

# Get phase prompt
PHASE_NUM=\$(python3 -c "
import json
with open('\$PROJECT_PATH/coordination/phase-status.json', 'r') as f:
    print(json.load(f)['current_phase'])
" 2>/dev/null)

echo "Loading Phase \$PHASE_NUM prompt..."
echo ""

# Check if phase prompt exists
if [ -f "\$PROJECT_PATH/prompts/phase-\$PHASE_NUM-terminal-\$TERM_NUM.md" ]; then
    echo "Using phase-specific prompt"
    PROMPT_FILE="\$PROJECT_PATH/prompts/phase-\$PHASE_NUM-terminal-\$TERM_NUM.md"
else
    echo "Generating prompt..."
    python3 "\$SWARM_HOME/bin/phase-prompter.py" "\$PROJECT_PATH" "\$PHASE_NUM"
    PROMPT_FILE="\$PROJECT_PATH/prompts/phase-\$PHASE_NUM-terminal-\$TERM_NUM.md"
fi

# Launch Claude with phase prompt
if [ -f "\$PROMPT_FILE" ]; then
    $CLAUDE_CMD --dangerously-skip-permissions < "\$PROMPT_FILE"
else
    echo "Error: Could not find prompt file"
fi

echo ""
echo "Terminal \$TERM_NUM session ended"
echo "Check phase controller for next phase"
bash
LAUNCH_SCRIPT
    
    chmod +x "$PROJECT_PATH/launch-term-$i.sh"
    
    # Launch terminal
    osascript << EOF_TERM
    tell application "Terminal"
        -- Create new tab
        set termWindow to do script "cd '$PROJECT_PATH' && ./launch-term-$i.sh"
        
        -- Use Basic profile
        set current settings of termWindow to settings set "Basic"
    end tell
EOF_TERM
    
    sleep 1
done

echo ""
echo "========================================"
echo "  Swarm Launched Successfully!"
echo "========================================"
echo ""
echo "Features:"
echo "✓ Phase-aware prompts for each terminal"
echo "✓ Automatic code checking"
echo "✓ Docker testing configured"
echo "✓ Phase controller with prompt management"
echo "✓ No terminal highlighting issues"
echo ""
echo "Phase Controller Commands:"
echo "  [a] - Advance to next phase"
echo "  [p] - Show available prompts"
echo "  [t] - Run Docker tests"
echo "  [c] - Check existing code"
echo ""
echo "When a phase completes:"
echo "1. Controller shows 'PHASE COMPLETE!'"
echo "2. Press [a] to advance"
echo "3. New prompts are generated"
echo "4. Copy prompts to terminals to continue"
echo ""
echo "Files:"
echo "  prompts/phase-*-terminal-*.md - Individual prompts"
echo "  prompts/phase-*-all-terminals.md - All prompts in one file"
echo "  coordination/phase-status.json - Current progress"
echo ""
echo "Real-time Monitoring:"
echo "  Run 'swarm kanban' in another terminal"
echo "  Open browser at http://localhost:5000"