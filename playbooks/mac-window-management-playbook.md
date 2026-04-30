# macOS Window Management Playbook
A minimal, reproducible add-on stack to make window management on macOS feel closer to a proper tiling WM (Windows / i3 / Sway), without disabling SIP or running anything exotic.
## The Stack
| Tool | Role | Install |
| --- | --- | --- |
| **AutoRaise** | Focus-follows-mouse. Hover a window → it comes to front. | `brew install dimentium/autoraise/autoraise` |
| **Loop** | Keyboard/mouse-driven tiling & snapping. | Mac App Store or `brew install --cask loop` |
| **Karabiner-Elements** | Remaps Caps Lock → Hyper (⌘⌃⌥⇧). Gives a private keyspace. | `brew install --cask karabiner-elements` |
Optional future additions: Rectangle (extra keyboard snap zones), AeroSpace/yabai (true tiling WM), Hammerspoon (Lua automation).
## Why This Combo
- **AutoRaise** eliminates the click-to-focus friction macOS forces on you.
- **Loop** gives you keyboard-driven tiling without SIP changes.
- **Hyper key** gives Loop (and anything else) an entire modifier namespace with zero collisions against system or app shortcuts.
## One-Shot Setup
Run in order. Each step is independently idempotent.
### 1. AutoRaise
```zsh
brew tap dimentium/autoraise 2>/dev/null || true
brew install dimentium/autoraise/autoraise
brew services start dimentium/autoraise/autoraise
```
Verify:
```zsh
brew services list | grep autoraise            # → started
pgrep -lf AutoRaise                              # → PID listed
/usr/libexec/PlistBuddy -c 'Print :RunAtLoad' \
  ~/Library/LaunchAgents/homebrew.mxcl.autoraise.plist   # → true
```
Config file: `~/.AutoRaise` — tune `delay`, `warpX`, `warpY`, `ignoreSpaceChanged`, etc. After editing:
```zsh
brew services restart dimentium/autoraise/autoraise
```
Permissions required (System Settings → Privacy & Security):
- **Accessibility** → `/opt/homebrew/opt/autoraise/bin/AutoRaise`
- **Screen Recording** (only if using `warpX`/`warpY` cursor warping)
### 2. Loop
Install from Mac App Store, or:
```zsh
brew install --cask loop
open -a Loop
```
Grant Accessibility permission when prompted.
### 3. Karabiner-Elements + Hyper Key
```zsh
brew install --cask karabiner-elements
open -a Karabiner-Elements   # triggers first-run; approve DriverKit extension when macOS prompts
```
Then drop the Hyper-key rule into the config:
```zsh
mkdir -p ~/.config/karabiner
cp ~/.config/karabiner/karabiner.json ~/.config/karabiner/karabiner.json.bak.$(date +%s) 2>/dev/null || true
cat > ~/.config/karabiner/karabiner.json <<'JSON'
{
    "global": {
        "check_for_updates_on_startup": true,
        "show_in_menu_bar": true,
        "show_profile_name_in_menu_bar": false
    },
    "profiles": [
        {
            "name": "Default profile",
            "selected": true,
            "simple_modifications": [],
            "complex_modifications": {
                "parameters": {
                    "basic.simultaneous_threshold_milliseconds": 50,
                    "basic.to_delayed_action_delay_milliseconds": 500,
                    "basic.to_if_alone_timeout_milliseconds": 200,
                    "basic.to_if_held_down_threshold_milliseconds": 500
                },
                "rules": [
                    {
                        "description": "Caps Lock → Hyper (⌘⌃⌥⇧) when held; Escape when tapped alone",
                        "manipulators": [
                            {
                                "type": "basic",
                                "from": {
                                    "key_code": "caps_lock",
                                    "modifiers": { "optional": ["any"] }
                                },
                                "to": [
                                    {
                                        "key_code": "left_shift",
                                        "modifiers": ["left_command", "left_control", "left_option"]
                                    }
                                ],
                                "to_if_alone": [
                                    { "key_code": "escape" }
                                ]
                            }
                        ]
                    }
                ]
            },
            "devices": [],
            "fn_function_keys": [],
            "virtual_hid_keyboard": { "keyboard_type_v2": "ansi" }
        }
    ]
}
JSON
# Force Karabiner to reload the config
pkill -x karabiner_console_user_server
```
Required macOS approvals (in order):
1. **System Settings → General → Login Items & Extensions → Driver Extensions** → enable `org.pqrs.Karabiner-DriverKit-VirtualHIDDevice`.
2. **Privacy & Security → Input Monitoring** → enable `karabiner_grabber` (and `Karabiner-Elements` if shown).
3. **Privacy & Security → Accessibility** → enable `Karabiner-Elements`.
If the driver is stuck in `[activated waiting for user]`, force re-activation:
```zsh
/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager activate
systemextensionsctl list | grep karabiner       # → [activated enabled]
```
## Verification
### AutoRaise
Hover an unfocused window for ~1 s → it raises.
### Hyper Key
Open **Karabiner-EventViewer → Main** tab, press and hold Caps Lock ~300 ms:
```
down  left_command
down  left_control
down  left_option
down  left_shift        flags: left_command, left_control, left_option, left_shift
up    left_shift
up    left_control
up    left_option
up    left_command
```
Tap Caps Lock briefly (<200 ms) → `down escape / up escape`.
### Loop Bindings
In Loop → Settings → Keybinds, record shortcuts by pressing **Caps Lock + letter**. Suggested layout:
| Action | Shortcut |
| --- | --- |
| Left half | Caps Lock + H |
| Right half | Caps Lock + L |
| Top half | Caps Lock + K |
| Bottom half | Caps Lock + J |
| Maximize | Caps Lock + Return |
| Center / restore | Caps Lock + C |
| Top-left quarter | Caps Lock + U |
| Top-right quarter | Caps Lock + I |
| Bottom-left quarter | Caps Lock + M |
| Bottom-right quarter | Caps Lock + , |
## Troubleshooting
| Symptom | Cause | Fix |
| --- | --- | --- |
| Caps Lock still capitalises | DriverKit extension not approved or `karabiner_grabber` unable to start | Approve in Login Items & Extensions → Driver Extensions; then `...-Manager activate` |
| Caps Lock emits only `left_shift` instead of full Hyper | `karabiner_console_user_server` hasn't pushed the new config to Core-Service | `pkill -x karabiner_console_user_server` (it auto-respawns and re-pushes) |
| `to_if_alone` (escape on tap) never fires | Holding past 200 ms | Shorten hold, or raise `basic.to_if_alone_timeout_milliseconds` |
| AutoRaise does nothing on hover | Accessibility permission missing | System Settings → Privacy & Security → Accessibility → add `/opt/homebrew/opt/autoraise/bin/AutoRaise` |
| AutoRaise not running after reboot | LaunchAgent not registered | `brew services start dimentium/autoraise/autoraise` |
| macOS intercepts Caps Lock before Karabiner | A system-level remap is set | `hidutil property --get UserKeyMapping` (should be `null`); also System Settings → Keyboard → Modifier Keys → reset Caps Lock to default |
## Uninstall / Rollback
```zsh
brew services stop dimentium/autoraise/autoraise
brew uninstall --cask karabiner-elements
brew uninstall dimentium/autoraise/autoraise
brew uninstall --cask loop
rm -rf ~/.config/karabiner ~/.AutoRaise ~/Library/LaunchAgents/homebrew.mxcl.autoraise.plist
```
(You'll also need to remove Karabiner's DriverKit system extension via System Settings → Login Items & Extensions → Driver Extensions if you want a fully clean state.)
## Files This Playbook Touches
- `~/.config/karabiner/karabiner.json` — Hyper key rule
- `~/.AutoRaise` — AutoRaise config
- `~/Library/LaunchAgents/homebrew.mxcl.autoraise.plist` — login auto-start
- `~/Library/Logs/AutoRaise.log` — AutoRaise runtime log
- `~/.local/share/karabiner/log/console_user_server.log` — Karabiner runtime log
