#!/bin/bash

# Swarm System - Ultra Quick Test Script
# This creates a simple test project and shows everything working

echo "🚀 Swarm System - Quick Test"
echo "============================"
echo ""
echo "This will:"
echo "1. Create a test calculator app project"
echo "2. Show the generated todos"
echo "3. Display the phase structure"
echo "4. Show how to start the swarm"
echo ""
echo "Press Enter to continue..."
read

SWARM_HOME="$(cd "$(dirname "$0")/.." && pwd)"
TEST_NAME="quicktest-$(date +%Y%m%d-%H%M%S)"

echo ""
echo "Creating project: $TEST_NAME"
echo "Description: Build a calculator web app with React"
echo ""

# Create the project
"$SWARM_HOME/bin/swarm-manager.sh" init "$TEST_NAME" "Build a simple calculator web app with React, supporting basic operations (add, subtract, multiply, divide) with a clean, modern UI"

echo ""
echo "✅ Project created at: $SWARM_HOME/projects/$TEST_NAME"
echo ""
echo "📋 Generated Structure:"
echo "----------------------"
ls -la "$SWARM_HOME/projects/$TEST_NAME/todo/" | grep -E "\.md$"

echo ""
echo "📊 Phase 1 Tasks for Terminal 1:"
echo "--------------------------------"
head -20 "$SWARM_HOME/projects/$TEST_NAME/todo/terminal-1.md"

echo ""
echo "🎯 To start the full swarm, run:"
echo "  cd $SWARM_HOME/projects/$TEST_NAME"
echo "  $SWARM_HOME/bin/swarm-manager.sh start"
echo ""
echo "Or use the short commands (after sourcing ~/.bashrc):"
echo "  swgo $TEST_NAME"
echo "  sws"
echo ""
echo "📊 To monitor in real-time:"
echo "  swk $TEST_NAME"
echo ""
echo "Would you like to start the swarm now? (y/n)"
read -n 1 start_now
echo ""

if [[ "$start_now" == "y" ]] || [[ "$start_now" == "Y" ]]; then
    cd "$SWARM_HOME/projects/$TEST_NAME"
    echo ""
    echo "Starting swarm in 3 seconds..."
    echo "Press Ctrl+C to cancel"
    sleep 3
    "$SWARM_HOME/bin/swarm-manager.sh" start
else
    echo "✅ Test complete! Project is ready at:"
    echo "   $SWARM_HOME/projects/$TEST_NAME"
    echo ""
    echo "Start it anytime with:"
    echo "   cd $SWARM_HOME/projects/$TEST_NAME && swarm start"
fi