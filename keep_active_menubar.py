#!/usr/bin/env python3
"""
Espresso - Keep Active Menu Bar App for macOS
Auto-starts on login, runs in system tray with icon
Combines caffeinate APIs with subtle F15 keypress to keep Teams status active
"""

import subprocess
import threading
import time
import os
import sys
from datetime import datetime
import rumps
from pynput.keyboard import Controller as KeyboardController, Key

class KeepActiveApp(rumps.App):
    def __init__(self):
        super(KeepActiveApp, self).__init__(
            "Espresso",
            title="☕",  # Espresso cup emoji as title
            quit_button=None  # We'll handle quit manually
        )
        
        # Try to set a custom app icon to avoid Terminal icon in notifications
        try:
            import AppKit
            app = AppKit.NSApplication.sharedApplication()
            # Set app name for better notifications
            app.setActivationPolicy_(AppKit.NSApplicationActivationPolicyAccessory)
        except Exception as e:
            print(f"Could not set app properties: {e}")
        
        # App state
        self.is_active = True
        self.caffeinate_process = None
        self.activity_thread = None
        self.last_activity = None
        self.keyboard = KeyboardController()
        
        # Menu items with direct callback assignment
        self.status_item = rumps.MenuItem("Status: Starting...")
        self.toggle_item = rumps.MenuItem("Pause Espresso", callback=self.toggle_active)
        self.separator1 = rumps.separator
        self.last_activity_item = rumps.MenuItem("Last activity: Never")
        self.separator2 = rumps.separator
        self.about_item = rumps.MenuItem("About Espresso", callback=self.show_about)
        self.quit_item = rumps.MenuItem("Quit Espresso", callback=self.quit_app)
        
        # Build menu
        self.menu = [
            self.status_item,
            self.toggle_item,
            self.separator1,
            self.last_activity_item,
            self.separator2,
            self.about_item,
            self.quit_item
        ]
        
        # Start the keep active functionality
        self.start_keep_active()
    
    def start_keep_active(self):
        """Start the caffeinate process and activity thread."""
        try:
            # Start caffeinate to prevent sleep
            self.caffeinate_process = subprocess.Popen(
                ['caffeinate', '-dims'],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            
            # Start activity simulation thread
            self.activity_thread = threading.Thread(target=self.activity_loop, daemon=True)
            self.activity_thread.start()
            
            self.status_item.title = "Status: Active ✅"
            self.title = "☕"  # Coffee cup when active
            
        except Exception as e:
            self.status_item.title = f"Status: Error - {str(e)}"
            self.title = "❌"
    
    def stop_keep_active(self):
        """Stop the caffeinate process."""
        if self.caffeinate_process:
            self.caffeinate_process.terminate()
            self.caffeinate_process.wait()
            self.caffeinate_process = None
        
        self.status_item.title = "Status: Paused 🫗"
        self.title = "🫗"  # Empty cup when paused
    
    def activity_loop(self):
        """Background thread that simulates user activity every 4 minutes."""
        while True:
            if self.is_active:
                try:
                    # Press and release F15 key (rarely used, won't interfere)
                    self.keyboard.press(Key.f15)
                    time.sleep(0.01)  # Very brief press
                    self.keyboard.release(Key.f15)
                    
                    # Also use caffeinate to prevent system sleep
                    subprocess.run(['caffeinate', '-u', '-t', '1'], 
                                 capture_output=True, timeout=5)
                    
                    self.last_activity = datetime.now()
                    time_str = self.last_activity.strftime('%H:%M:%S')
                    self.last_activity_item.title = f"Last activity: {time_str}"
                    print(f"Activity simulated at {time_str} (F15 keypress)")
                    
                except Exception as e:
                    print(f"Activity update failed: {e}")
            
            # Sleep for 4 minutes (240 seconds)
            time.sleep(240)
    
    def toggle_active(self, sender):
        """Toggle the keep active functionality."""
        print(f"Toggle clicked! Current state: {'active' if self.is_active else 'paused'}")
        if self.is_active:
            # Pause
            print("Pausing Espresso...")
            self.is_active = False
            self.stop_keep_active()
            self.toggle_item.title = "Resume Espresso"
            print("Espresso paused")
        else:
            # Resume
            print("Resuming Espresso...")
            self.is_active = True
            self.start_keep_active()
            self.toggle_item.title = "Pause Espresso"
            print("Espresso resumed")
    
    def show_about(self, sender):
        """Show about dialog."""
        print("About Espresso clicked!")  # Debug log
        
        # Try multiple approaches to show the about info
        success = False
        
        # Method 1: Try rumps.alert (should work)
        try:
            rumps.alert(
                title="☕ About Espresso",
                message="Prevents your Mac from sleeping and keeps MS Teams status active.\n\nUses native macOS caffeinate APIs - no mouse simulation.\nUpdates activity every 4 minutes.",
                ok="OK"
            )
            success = True
            print("Alert dialog shown successfully")
        except Exception as e:
            print(f"Alert failed: {e}")
        
        # Method 2: Try osascript dialog
        if not success:
            try:
                import subprocess
                subprocess.run([
                    'osascript', '-e', 
                    'display dialog "☕ Espresso - macOS Keep-Awake Utility\\n\\nPrevents your Mac from sleeping and keeps MS Teams status active.\\n\\nUses native macOS caffeinate APIs - no mouse simulation.\\nUpdates activity every 4 minutes." with title "About Espresso" buttons {"OK"} default button "OK"'
                ], check=True)
                success = True
                print("osascript dialog shown successfully")
            except Exception as e:
                print(f"osascript dialog failed: {e}")
        
        # Method 3: Try notification as fallback
        if not success:
            try:
                rumps.notification(
                    title="☕ About Espresso",
                    subtitle="macOS Keep-Awake Utility", 
                    message="Prevents sleep & keeps Teams active using native caffeinate APIs. Updates every 4 minutes.",
                    sound=False
                )
                success = True
                print("Notification shown successfully")
            except Exception as e:
                print(f"Notification failed: {e}")
        
        # Method 4: Console fallback
        if not success:
            print("=== ☕ About Espresso ===")
            print("macOS Keep-Awake Utility")
            print("Prevents your Mac from sleeping and keeps MS Teams status active.")
            print("Uses native macOS caffeinate APIs - no mouse simulation.")
            print("Updates activity every 4 minutes.")
            print("========================")
    
    @rumps.clicked("Quit Espresso")
    def quit_app(self, sender):
        """Quit the application."""
        print("Quit Espresso clicked!")  # Debug log
        try:
            print("Stopping keep active processes...")
            self.stop_keep_active()
            print("Keep active processes stopped")
        except Exception as e:
            print(f"Error during cleanup: {e}")
        
        print("Calling rumps.quit_application()...")
        rumps.quit_application()

def main():
    """Main function to run the app."""
    # Check for test mode
    if len(sys.argv) > 1 and sys.argv[1] == '--test':
        print("Testing Espresso dependencies...")
        try:
            import rumps
            print("✅ rumps module available")
            from pynput.keyboard import Controller
            print("✅ pynput module available")
            subprocess.run(['caffeinate', '--help'], 
                          capture_output=True, timeout=5)
            print("✅ caffeinate command available")
            print("✅ All dependencies OK")
            sys.exit(0)
        except ImportError as e:
            print(f"❌ Missing dependency: {e}")
            sys.exit(1)
        except (subprocess.TimeoutExpired, FileNotFoundError):
            print("❌ caffeinate command not available")
            sys.exit(1)
    
    # Check if caffeinate is available
    try:
        subprocess.run(['caffeinate', '--help'], 
                      capture_output=True, timeout=5)
    except (subprocess.TimeoutExpired, FileNotFoundError):
        rumps.alert(
            title="Error",
            message="This app requires macOS with caffeinate command.\n"
                   "Please run on macOS 10.8 or later.",
            ok="OK"
        )
        sys.exit(1)
    
    # Run the app
    app = KeepActiveApp()
    app.run()

if __name__ == "__main__":
    main()
