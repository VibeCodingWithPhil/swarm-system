#!/bin/bash

# Swarm System Setup Script

echo "========================================"
echo "    Swarm System Setup"
echo "========================================"
echo ""

SWARM_HOME="$(cd "$(dirname "$0")" && pwd)"

# Make all scripts executable
chmod +x "$SWARM_HOME/bin/"*.sh
chmod +x "$SWARM_HOME/bin/"*.py
chmod +x "$SWARM_HOME/bin/swarm"

# Add to PATH
echo "Adding swarm to PATH..."
SHELL_RC="$HOME/.bashrc"
[ -n "$ZSH_VERSION" ] && SHELL_RC="$HOME/.zshrc"

if ! grep -q "SWARM_HOME" "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo "# Swarm System" >> "$SHELL_RC"
    echo "export SWARM_HOME=\"$SWARM_HOME\"" >> "$SHELL_RC"
    echo "export PATH=\"\$SWARM_HOME/bin:\$PATH\"" >> "$SHELL_RC"
fi

echo "✓ Setup complete!"
echo ""
echo "To start using swarm:"
echo "  source $SHELL_RC"
echo "  swarm help"
echo ""
echo "Quick start:"
echo "  swarm init my-project \"Build a todo app with React\""
echo "  cd $SWARM_HOME/projects/my-project"
echo "  swarm start"