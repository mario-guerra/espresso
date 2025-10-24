#!/bin/bash

# Keep Active Uninstaller for macOS
# Removes the auto-start menu bar app

echo "🗑️  Espresso Uninstaller"
echo "========================="
echo ""

PLIST_FILE="$HOME/Library/LaunchAgents/com.espresso.agent.plist"
INSTALL_DIR="$HOME/Applications/Espresso"

if [ -f "$PLIST_FILE" ]; then
    echo "🔄 Stopping and unloading Espresso..."
    launchctl stop com.espresso.agent 2>/dev/null || true
    launchctl unload "$PLIST_FILE" 2>/dev/null || true
    
    echo "🗑️  Removing launch agent..."
    rm "$PLIST_FILE"
    
    echo "🗑️  Removing application files..."
    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
        echo "   • Removed: $INSTALL_DIR"
    fi
    
    echo "🧹 Cleaning up log files..."
    rm -f /tmp/espresso.log /tmp/espresso.error.log
    
    echo "🗑️  Removing desktop shortcut..."
    if [ -d "$HOME/Desktop/Espresso.app" ]; then
        rm -rf "$HOME/Desktop/Espresso.app"
        echo "   • Removed: ~/Desktop/Espresso.app"
    fi
    
    echo ""
    echo "✅ Espresso has been completely uninstalled"
    echo "   • Auto-start disabled"
    echo "   • Launch agent removed"
    echo "   • Application files removed"
    echo "   • Desktop shortcut removed"
    echo "   • Log files cleaned up"
    echo ""
    echo "💡 Note: You may want to manually remove the Python dependency:"
    echo "   pip3 uninstall rumps"
else
    echo "❌ Espresso launch agent not found"
    echo "   It may not be installed or already removed"
    
    # Still try to remove app files if they exist
    if [ -d "$INSTALL_DIR" ]; then
        echo "🗑️  Found app files, removing them..."
        rm -rf "$INSTALL_DIR"
        echo "   • Removed: $INSTALL_DIR"
    fi
fi

echo ""
echo "🏁 Uninstall complete!"
