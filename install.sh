#!/bin/bash

# Espresso Installer for macOS
# Installs to ~/Applications/Espresso/ for permanent location

set -e  # Exit on any error

echo "☕ Espresso Installer"
echo "================================="
echo ""

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: This installer is for macOS only"
    exit 1
fi

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python 3 is required but not found"
    echo "Please install Python 3 and try again"
    exit 1
fi

# Define installation directory
INSTALL_DIR="$HOME/Applications/Espresso"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📁 Source directory: $SCRIPT_DIR"
echo "📁 Install directory: $INSTALL_DIR"

# Create installation directory
echo "📂 Creating installation directory..."
mkdir -p "$INSTALL_DIR"

# Install Python dependencies first
echo "📦 Installing Python dependencies..."
# Install all required packages
if ! pip3 install --upgrade rumps pynput pyobjc-framework-Quartz 2>/dev/null; then
    echo "   Global install failed, installing for user..."
    pip3 install --user --upgrade rumps pynput pyobjc-framework-Quartz
fi

# Find the correct Python path that has rumps installed
PYTHON_PATH=$(which python3)
echo "📍 Default Python: $PYTHON_PATH"

# Get the user's Python site-packages directory
USER_SITE_PACKAGES=$($PYTHON_PATH -c "import site; print(site.USER_SITE)" 2>/dev/null)
echo "📍 User site-packages: $USER_SITE_PACKAGES"

# Copy files to installation directory
echo "📋 Copying application files..."
cp "$SCRIPT_DIR/keep_active_menubar.py" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/requirements.txt" "$INSTALL_DIR/"

# Create the launcher script dynamically with correct paths
echo "📝 Creating launcher script..."
{
    echo '#!/bin/bash'
    echo ''
    echo '# Espresso Launcher Script'
    echo '# Sets up the proper Python environment for LaunchAgent'
    echo ''
    echo "# Set the Python path to include user site-packages"
    echo "export PYTHONPATH=\"$USER_SITE_PACKAGES:\$PYTHONPATH\""
    echo ''
    echo '# Set the PATH to include user binaries'
    echo 'export PATH="/usr/local/bin:/usr/bin:/bin:$HOME/.local/bin:$PATH"'
    echo ''
    echo '# Get the directory where this script is located'
    echo 'SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"'
    echo ''
    echo '# Run the Python app'
    echo "exec \"$PYTHON_PATH\" \"\$SCRIPT_DIR/keep_active_menubar.py\" \"\$@\""
} > "$INSTALL_DIR/espresso_launcher.sh"

chmod +x "$INSTALL_DIR/espresso_launcher.sh"

# Test if rumps is available with current environment
if $PYTHON_PATH -c "import rumps" 2>/dev/null; then
    echo "✅ rumps found in default Python"
else
    echo "⚠️  rumps not found in default Python environment"
    echo "   This is normal for LaunchAgents - we'll fix the environment"
fi

# Create LaunchAgents directory if it doesn't exist
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
mkdir -p "$LAUNCH_AGENTS_DIR"

# Create the plist file with fixed installation path
PLIST_FILE="$LAUNCH_AGENTS_DIR/com.espresso.agent.plist"
echo "📝 Creating launch agent at: $PLIST_FILE"

cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.espresso.agent</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>$INSTALL_DIR/espresso_launcher.sh</string>
    </array>
    
    <key>RunAtLoad</key>
    <true/>
    
    <key>KeepAlive</key>
    <true/>
    
    <key>ProcessType</key>
    <string>Interactive</string>
    
    <key>LimitLoadToSessionType</key>
    <string>Aqua</string>
    
    <key>StandardOutPath</key>
    <string>/tmp/espresso.log</string>
    
    <key>StandardErrorPath</key>
    <string>/tmp/espresso.error.log</string>
    
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:$HOME/.local/bin</string>
        <key>PYTHONPATH</key>
        <string>$USER_SITE_PACKAGES</string>
    </dict>
</dict>
</plist>
EOF

# Make the Python script executable
chmod +x "$INSTALL_DIR/keep_active_menubar.py"

# Load the launch agent
echo "🔄 Loading launch agent..."
launchctl unload "$PLIST_FILE" 2>/dev/null || true  # Ignore error if not loaded
launchctl load "$PLIST_FILE"

# Verify the installation works
echo "🔍 Testing Espresso app with launcher script..."
if "$INSTALL_DIR/espresso_launcher.sh" --test 2>/dev/null; then
    echo "✅ App test successful"
else
    echo "⚠️  App test failed - checking launcher script..."
    echo "   Launcher script contents:"
    cat "$INSTALL_DIR/espresso_launcher.sh"
fi

# Start the app now
echo "▶️  Starting Espresso app..."
launchctl start com.espresso.agent

# Give it a moment to start
sleep 2

# Check if it's running
if pgrep -f "keep_active_menubar.py" > /dev/null; then
    echo "✅ Espresso is running!"
else
    echo "⚠️  Espresso may not have started - check logs"
fi

# Create desktop shortcut
echo "🖥️  Creating desktop shortcut..."
cat > /tmp/Espresso.applescript << 'EOF'
tell application "Terminal"
    do script "$INSTALL_DIR/espresso_launcher.sh"
    delay 2
    close front window
end tell
EOF

# Compile the AppleScript into an app
if osacompile -o ~/Desktop/Espresso.app /tmp/Espresso.applescript 2>/dev/null; then
    echo "✅ Created Espresso.app on your Desktop!"
    rm /tmp/Espresso.applescript
else
    echo "⚠️  Could not create desktop shortcut (this is optional)"
    rm -f /tmp/Espresso.applescript
fi

echo ""
echo "✅ Installation Complete!"
echo ""
echo "📋 What was installed:"
echo "   • App files copied to: $INSTALL_DIR/"
echo "   • Auto-start config: $PLIST_FILE"
echo "   • Python dependency: rumps"
echo "   • Desktop shortcut: ~/Desktop/Espresso.app"
echo ""
echo "🎯 The app should now be running in your menu bar (look for ☕ icon)"
echo ""
echo "📖 Usage:"
echo "   • Click the ☕ icon in menu bar to see status and controls"
echo "   • The app will auto-start every time you log in"
echo "   • Use 'Pause/Resume' to temporarily disable"
echo "   • Use 'Quit' to stop completely"
echo "   • Double-click ~/Desktop/Espresso.app to relaunch after quitting"
echo ""
echo "✨ Benefits of this installation:"
echo "   • App runs from fixed location: $INSTALL_DIR/"
echo "   • You can delete the original project folder"
echo "   • App will survive system updates and folder moves"
echo ""
echo "🗑️  To uninstall later:"
echo "   launchctl unload $PLIST_FILE"
echo "   rm $PLIST_FILE"
echo "   rm -rf $INSTALL_DIR"
echo ""
echo "📊 Logs (if needed for troubleshooting):"
echo "   /tmp/espresso.log"
echo "   /tmp/espresso.error.log"
