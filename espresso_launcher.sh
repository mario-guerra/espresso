#!/bin/bash

# Espresso Launcher Script
# Sets up the proper Python environment for LaunchAgent

# Set the Python path to include user site-packages
export PYTHONPATH="/Users/mguerra/Library/Python/3.13/lib/python/site-packages:$PYTHONPATH"

# Set the PATH to include user binaries
export PATH="/usr/local/bin:/usr/bin:/bin:$HOME/.local/bin:$PATH"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run the Python app
exec /Library/Frameworks/Python.framework/Versions/3.13/bin/python3 "$SCRIPT_DIR/keep_active_menubar.py"
