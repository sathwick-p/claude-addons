# HD demo tape — pitch black background, high resolution
# Record: vhs demo/dream-hd.tape

Output demo/dream-hd.gif

Set Shell "bash"
Set FontSize 16
Set Width 1200
Set Height 660
Set Padding 24
Set Framerate 30
Set PlaybackSpeed 0.8

# Pitch black background with bright foreground
Set Theme { "name": "Dream", "black": "#000000", "red": "#ff5f56", "green": "#5af78e", "yellow": "#f3f99d", "blue": "#57c7ff", "purple": "#ff6ac1", "cyan": "#9aedfe", "white": "#f1f1f0", "brightBlack": "#686868", "brightRed": "#ff5f56", "brightGreen": "#5af78e", "brightYellow": "#f3f99d", "brightBlue": "#57c7ff", "brightPurple": "#ff6ac1", "brightCyan": "#9aedfe", "brightWhite": "#f1f1f0", "foreground": "#f1f1f0", "background": "#000000", "selectionBackground": "#444444", "cursorColor": "#f1f1f0" }

Set TypingSpeed 35ms

# --- Install ---
Type "./install.sh"
Enter
Sleep 5s

# --- Status ---
Type "./install.sh --status"
Enter
Sleep 3s

# --- Dream demo ---
Type "# /dream — consolidate memories"
Enter
Sleep 500ms

Type "bash demo/demo-dream.sh"
Enter
Sleep 10s

Sleep 2s
