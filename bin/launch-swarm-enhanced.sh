#!/bin/bash

# Enhanced Swarm Launcher with code checking and Docker testing

PROJECT_PATH="$1"
PROJECT_NAME="$2"
CLAUDE_CMD="$HOME/.claude/local/claude"

if [ -z "$PROJECT_PATH" ] || [ -z "$PROJECT_NAME" ]; then
    echo "Error: Missing parameters"
    exit 1
fi

cd "$PROJECT_PATH"

echo "========================================"
echo "  Launching Enhanced Swarm: $PROJECT_NAME"
echo "========================================"

# Check existing code first
echo "Analyzing existing code..."
python3 "$(dirname "$0")/code-checker.py" "$PROJECT_PATH"

# Create Docker test configuration
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

# Create test Dockerfile
cat > "$PROJECT_PATH/workspace/Dockerfile.test" << 'EOF'
FROM node:18-python3

WORKDIR /app

# Install common test tools
RUN apt-get update && apt-get install -y \
    python3-pip \
    golang \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install pytest pytest-cov pytest-asyncio
RUN npm install -g jest @testing-library/react

# Copy and install dependencies
COPY package*.json ./
RUN if [ -f package.json ]; then npm ci; fi

COPY requirements*.txt ./
RUN if [ -f requirements.txt ]; then pip3 install -r requirements.txt; fi

COPY . .

CMD ["echo", "Test container ready"]
EOF

# Launch phase controller with proper terminal settings
osascript << 'EOF_CONTROLLER'
tell application "Terminal"
    activate
    
    -- Create new window with Basic profile (no highlighting)
    set controlWindow to do script ""
    
    -- Set to Basic profile to avoid highlighting
    tell controlWindow
        set current settings to settings set "Basic"
    end tell
    
    -- Now run the command
    do script "cd 'PROJECT_PATH_PLACEHOLDER' && bash 'BIN_PATH_PLACEHOLDER/phase-controller.sh' 'PROJECT_PATH_PLACEHOLDER'" in controlWindow
end tell
EOF_CONTROLLER

# Replace placeholders
osascript_cmd="${osascript_cmd//PROJECT_PATH_PLACEHOLDER/$PROJECT_PATH}"
osascript_cmd="${osascript_cmd//BIN_PATH_PLACEHOLDER/$(dirname "$0")}"
echo "$osascript_cmd" | osascript

sleep 2

# Launch 5 terminals with code awareness
for i in {1..5}; do
    cat > "$PROJECT_PATH/launch-term-$i.sh" << LAUNCH_SCRIPT
#!/bin/bash
TERM_NUM=$i
PROJECT_PATH="$PROJECT_PATH"
PROJECT_NAME="$PROJECT_NAME"

# Disable terminal highlighting
export TERM=xterm-256color
clear

echo "========================================"
echo "  Terminal \$TERM_NUM: $PROJECT_NAME"
echo "========================================"
echo ""

# Check what's already done
echo "Checking existing code..."
RESUME_DATA=\$(cat "\$PROJECT_PATH/coordination/resume-data.json" 2>/dev/null || echo "{}")

if [ "\$RESUME_DATA" != "{}" ]; then
    echo "Found existing work. Resuming from checkpoint..."
    python3 -c "
import json
data = json.loads('''\$RESUME_DATA''')
print('Completed features:', ', '.join(data.get('analysis', {}).get('implemented_features', [])))
print('Completion:', data.get('analysis', {}).get('completion_percentage', 0), '%')
print('Focus:', ', '.join(data.get('focus_areas', [])))
    " 2>/dev/null
fi

echo ""
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

# Create enhanced prompt with code awareness
cat > /tmp/swarm-prompt-\$TERM_NUM.txt << 'PROMPT'
You are Terminal \$TERM_NUM working on: $PROJECT_NAME

IMPORTANT: Check existing code first!
1. Check workspace/ directory for existing files
2. Read coordination/resume-data.json for what's already done
3. Skip any features marked as "implemented_features"
4. Focus on remaining tasks only

Your workflow:
1. Read todo/terminal-\$TERM_NUM.md
2. Check coordination/phase-status.json for current phase
3. Analyze workspace/ for existing code
4. Work ONLY on unimplemented features
5. Create Docker tests for all new code
6. Run tests with: docker-compose -f docker-compose.test.yml up
7. Update progress in phase-status.json

Testing requirements:
- Write unit tests for all functions
- Use Docker for test isolation
- Ensure tests pass before marking complete
- Tests go in tests/ directory

DO NOT duplicate existing work. Build on what's there.
Start by checking what exists, then implement only what's missing.
PROMPT

# Launch Claude
$CLAUDE_CMD --dangerously-skip-permissions < /tmp/swarm-prompt-\$TERM_NUM.txt

echo ""
echo "Terminal \$TERM_NUM session ended"
bash
LAUNCH_SCRIPT
    
    chmod +x "$PROJECT_PATH/launch-term-$i.sh"
    
    # Launch with Basic profile to avoid highlighting
    osascript << EOF_TERM
    tell application "Terminal"
        -- Create new tab with Basic profile
        set termWindow to do script ""
        
        -- Set to Basic profile (no highlighting)
        tell termWindow
            set current settings to settings set "Basic"
        end tell
        
        -- Run the launch script
        do script "cd '$PROJECT_PATH' && ./launch-term-$i.sh" in termWindow
    end tell
EOF_TERM
    
    sleep 1
done

echo ""
echo "✓ All terminals launched with:"
echo "  - Code checking enabled"
echo "  - Docker testing configured"
echo "  - Terminal highlighting fixed"
echo ""
echo "Docker testing: docker-compose -f docker-compose.test.yml up"
echo "Check existing code: python3 $(dirname "$0")/code-checker.py '$PROJECT_PATH'"