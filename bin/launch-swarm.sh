#!/bin/bash

# Universal Swarm Launcher for any project

PROJECT_PATH="$1"
PROJECT_NAME="$2"
CLAUDE_CMD="$HOME/.claude/local/claude"

if [ -z "$PROJECT_PATH" ] || [ -z "$PROJECT_NAME" ]; then
    echo "Error: Missing parameters"
    exit 1
fi

cd "$PROJECT_PATH"

echo "========================================"
echo "  Launching Swarm: $PROJECT_NAME"
echo "========================================"

# Launch phase controller
osascript << EOF
tell application "Terminal"
    activate
    set controlWindow to do script "cd '$PROJECT_PATH' && bash '$PROJECT_PATH/../../../bin/phase-controller.sh' '$PROJECT_PATH'"
    set current settings of controlWindow to settings set "Ocean"
end tell
EOF

sleep 2

# Launch 5 terminals
for i in {1..5}; do
    cat > "$PROJECT_PATH/launch-term-$i.sh" << LAUNCH_SCRIPT
#!/bin/bash
TERM_NUM=$i
PROJECT_PATH="$PROJECT_PATH"

echo "Terminal \$TERM_NUM starting for $PROJECT_NAME"
echo "Reading todo/terminal-\$TERM_NUM.md"
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

# Create prompt
cat > /tmp/swarm-prompt-\$TERM_NUM.txt << 'PROMPT'
You are Terminal \$TERM_NUM working on project: $PROJECT_NAME

Instructions:
1. Read your todo file at: todo/terminal-\$TERM_NUM.md
2. Check coordination/phase-status.json for current phase task
3. Work ONLY on your assigned task for current phase
4. Update progress in phase-status.json (25%, 50%, 75%, 100%)
5. Mark as COMPLETED when done
6. Create tests for all code
7. Update files in workspace/ directory

Start by reading your todo file and implementing your Phase 1 task.
PROMPT

# Launch Claude
$CLAUDE_CMD --dangerously-skip-permissions < /tmp/swarm-prompt-\$TERM_NUM.txt

echo "Terminal \$TERM_NUM session ended"
bash
LAUNCH_SCRIPT
    
    chmod +x "$PROJECT_PATH/launch-term-$i.sh"
    
    osascript << EOF
    tell application "Terminal"
        set termWindow to do script "cd '$PROJECT_PATH' && ./launch-term-$i.sh"
        set current settings of termWindow to settings set "Basic"
    end tell
EOF
    
    sleep 1
done

echo ""
echo "✓ All terminals launched!"
echo "✓ Phase controller active"
echo ""
echo "Monitor with: cat $PROJECT_PATH/coordination/phase-status.json"