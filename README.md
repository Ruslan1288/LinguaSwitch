# LinguaSwitch

A macOS menu bar utility that automatically switches keyboard layouts between English and Ukrainian — similar to Punto Switcher, but built natively for macOS 13+.

## Features

- **Auto-switch** — detects mistyped words and converts them to the correct layout
- **Manual convert** — `⌥Z` converts the last typed word instantly
- **Selected text convert** — `⌥⇧Space` converts selected text and switches layout
- **Cycle case** — `⌥⇧C` cycles through lowercase → UPPERCASE → Title Case
- **Layout switch** — `⌥Space` manually switches EN ↔ UA
- **Floating indicator** — shows current layout near cursor
- **App exceptions** — disable auto-switch per app (e.g. password managers)
- **Sound effects** — audio feedback on switch
- **Stats** — dashboard of auto/manual conversions

## How it works

LinguaSwitch uses a combination of:
- **N-gram analysis** (bigrams + trigrams) for short-word detection
- **SQLite dictionary** (370k EN + 320k UA words via GRDB.swift) for word lookup
- **CGEventTap** for system-wide keyboard monitoring (requires Accessibility permission)

## Requirements

- macOS 13.0+
- Accessibility permission (System Settings → Privacy & Security → Accessibility)

## Installation (Beta)

1. Download `LinguaSwitch-0.5.0.dmg` from [Releases](../../releases)
2. Open the `.dmg` and drag **LinguaSwitch** to `/Applications`
3. First launch: **right-click → Open** (bypasses Gatekeeper for unsigned apps)
4. Grant Accessibility permission when prompted

## Building from source

```bash
git clone https://github.com/YOUR_USERNAME/LinguaSwitch
cd LinguaSwitch
swift build -c release
# or to build .dmg:
zsh build_dmg.sh
```

## Hotkeys

| Action | Shortcut |
|--------|----------|
| Switch layout | `⌥Space` |
| Convert last word | `⌥Z` |
| Convert selected text | `⌥⇧Space` |
| Cycle case | `⌥⇧C` |

## Status

Currently in **public beta** (v0.5.0). Feedback welcome via GitHub Issues.
