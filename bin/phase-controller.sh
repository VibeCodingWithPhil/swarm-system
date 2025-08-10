#!/bin/bash

# Universal Phase Controller for any project

PROJECT_PATH="${1:-$(pwd)}"

echo "========================================"
echo "    Swarm Phase Controller"
echo "========================================"

show_status() {
    if [ -f "$PROJECT_PATH/coordination/phase-status.json" ]; then
        python3 -c "
import json
with open('$PROJECT_PATH/coordination/phase-status.json', 'r') as f:
    data = json.load(f)
    phase = data['current_phase']
    print(f\"\\nPhase {phase}: {data[f'phase_{phase}']['name']}\\n\")
    
    for tid, tdata in data[f'phase_{phase}']['terminals'].items():
        print(f\"Terminal {tid}: {tdata['status']} ({tdata['progress']}%) - {tdata['task']}\")
        " 2>/dev/null
    else
        echo "No phase data found"
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
        data['current_phase'] = phase + 1
        data[f'phase_{phase}']['status'] = 'COMPLETED'
        data[f'phase_{phase + 1}']['status'] = 'ACTIVE'
        
        for tid in data[f'phase_{phase + 1}']['terminals']:
            data[f'phase_{phase + 1}']['terminals'][tid]['status'] = 'NOT_STARTED'
            data[f'phase_{phase + 1}']['terminals'][tid]['progress'] = 0
        
        f.seek(0)
        json.dump(data, f, indent=2)
        f.truncate()
        print(f'✓ Advanced to Phase {phase + 1}')
    elif phase >= 4:
        print('All phases complete!')
    else:
        print('Current phase not complete')
    " 2>/dev/null
}

while true; do
    clear
    show_status
    echo ""
    echo "[Enter] Refresh | [a] Advance | [q] Quit"
    read -r -n 1 choice
    
    case $choice in
        a|A) advance_phase; sleep 2 ;;
        q|Q) exit 0 ;;
    esac
done