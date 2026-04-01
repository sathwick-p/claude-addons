# VHS tape file for recording the claude-addons demo GIF
# Install: brew install vhs
# Record: cd /path/to/claude-addons && vhs demo/claude-addons.tape
#
# This produces demo/claude-addons.gif

Output demo/claude-addons.gif

Set Shell "bash"
Set FontSize 14
Set Width 900
Set Height 500
Set Padding 20
Set Theme "Catppuccin Mocha"
Set TypingSpeed 40ms

# --- Install ---
Type "# Step 1: Install"
Enter
Sleep 500ms

Type "./install.sh"
Enter
Sleep 5s

# --- Status ---
Type "./install.sh --status"
Enter
Sleep 3s

# --- Dream demo ---
Type "# Step 2: /dream — consolidate memories"
Enter
Sleep 500ms

Type "bash demo/demo-dream.sh"
Enter
Sleep 10s

Sleep 2s
