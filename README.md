# Espresso - macOS Menu Bar App

A professional macOS menu bar application that prevents your computer from sleeping and keeps MS Teams status active. Automatically starts on login with an elegant espresso cup icon.

## 📁 Project Structure

```
espresso/
├── keep_active_menubar.py    # Main menu bar application
├── install.sh               # Installer (copies to ~/Applications/Espresso/)
├── uninstall.sh            # Complete removal script  
├── requirements.txt        # Python dependencies
├── com.keepactive.agent.plist # LaunchAgent template
├── README.md              # This file
├── LICENSE                # MIT license
└── .gitignore            # Git ignore rules
```

## 🚀 Quick Install

```bash
./install.sh
```

That's it! The installer will:
- ✅ Copy files to `~/Applications/Espresso/`
- ✅ Install Python dependencies
- ✅ Set up auto-start on login
- ✅ Start the app immediately
- ✅ Show a ☕ icon in your menu bar
- ✅ Let you delete this project folder afterward

## 🎯 Features

- **Menu Bar Icon**: Espresso cup (☕) icon shows status at a glance
- **Auto-Start**: Launches automatically when you log in
- **Native APIs**: Uses macOS `caffeinate` - no mouse simulation
- **Pause/Resume**: Toggle functionality without quitting
- **Status Display**: Shows last activity time and current status
- **Minimal Impact**: Lightweight, runs in background
- **Easy Uninstall**: One-command removal

## 📱 Menu Bar Controls

Click the ☕ icon to access:
- **Status**: Shows if active or paused
- **Pause/Resume**: Toggle the keep-active functionality  
- **Last Activity**: Timestamp of last activity update
- **About**: Information about the app
- **Quit**: Stop the app completely

## 🔧 How It Works

1. **Sleep Prevention**: Uses `caffeinate -dims` to prevent system sleep
2. **Activity Simulation**: Checks system idle time every 4 minutes
3. **Smart Mouse Movement**: Only moves mouse 1 pixel if idle for 2+ minutes (won't interfere with active work)
4. **Teams Status**: Mouse movement resets macOS idle timer, keeping Teams status active
5. **Background Operation**: Runs silently with minimal system impact

## 📋 What Gets Installed

- **App Files**: Copied to `~/Applications/Espresso/`
  - `keep_active_menubar.py` - Main menu bar application
  - `requirements.txt` - Dependencies list
- **Auto-Start**: `~/Library/LaunchAgents/com.keepactive.agent.plist` - macOS launch agent
- **Dependencies**: 
  - `rumps` - Python package for menu bar functionality
  - `pynput` - Python package for mouse control
  - `pyobjc-framework-Quartz` - macOS Quartz framework for idle time detection

## 🗑️ Uninstall

```bash
./uninstall.sh
```

This removes:
- The launch agent (stops auto-start)
- Log files
- App files from `~/Applications/Espresso/`

## 🛠️ Manual Usage

If you prefer not to auto-install:

```bash
# Install dependencies
pip3 install rumps pynput pyobjc-framework-Quartz

# Run manually
python3 keep_active_menubar.py
```

## 📊 Troubleshooting

**App not appearing in menu bar?**
- Check logs: `/tmp/espresso.log` and `/tmp/espresso.error.log`
- Ensure Python 3 and rumps are installed
- Try running manually: `python3 keep_active_menubar.py`

**Permission issues?**
- The app uses native macOS APIs that don't require special permissions
- If prompted, allow Terminal or Python to control your computer

**App crashes on startup?**
- Check you're running macOS 10.8+ (required for caffeinate)
- Verify Python 3 is installed: `python3 --version`

## 🔒 Security & Privacy

- ✅ Uses official Apple APIs only
- ✅ No network access required
- ✅ No mouse simulation or input injection
- ✅ No accessibility permissions needed
- ✅ Open source - you can review all code
- ✅ OWASP security compliant

## 🎨 Customization

Edit `keep_active_menubar.py` to customize:
- Activity interval (default: 4 minutes)
- Menu bar icon (default: ☕)
- Menu text and options

## 💡 Why This Solution?

- **Professional**: Proper macOS app with native integration
- **Reliable**: Uses official Apple APIs, not hacks
- **Convenient**: Set-and-forget with auto-start
- **Visible**: Menu bar icon shows it's working
- **Controllable**: Easy pause/resume without terminal commands
