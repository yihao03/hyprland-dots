# Hyprland Lua Config

Hyprland configured in Lua (`hyprland.lua` → `config/*`). The same keys adapt
to the active layout (`dwindle` vs `scrolling`) via `layout_binding()` in
`config/utils.lua`.

## Philosophy

- **Modifiers compose.** `SUPER` focuses, `SHIFT` moves, `ALT` resizes or
  alternates, `CTRL` goes system-wide. `SUPER + H` focuses left,
  `SUPER + SHIFT + H` moves left, `SUPER + ALT + H` resizes left.
- **Vim everywhere.** `H J K L` for focus, move, and resize; `h j k l` in the
  overview; `N / P` for next/previous workspace and monitor moves.
- **`T` toggles.** See the toggle table — same letter, one mnemonic.
- **Edges flow, not walls.** `K / J` fall back to workspace `r-1 / r+1`, and
  `scrolling` focus prefers a column neighbor before falling back.
- **Modes over chords.** `SUPER + M` (move window) and `SUPER + P` (display)
  open submaps; notifications announce entry and exit.

## Layout

| File | Role |
| ---- | ---- |
| `config/constants.lua` | `main_mod`, `active_layout`, apps, `noct_prefix`, timeouts |
| `config/utils.lua` | `layout_binding`, `if_neighbor`, `swap/move/organize_workspaces` |
| `config/keybinds.lua` | Bindings below |
| `config/monitors.lua` | Outputs, lid switch, `SUPER + P` display mode, `wl-mirror` |
| `config/plugins.lua` | Scrolloverview, dynamic-cursors, hyprglass |
| `config/appearance.lua`, `config/windowrules.lua`, `config/input.lua`, `config/misc.lua`, `config/env.lua`, `config/autostart.lua` | Look, rules, input, env, autostart |
| `scripts/alttab.lua` | Overview alt-tab (unwired; see commented block in `plugins.lua`) |

## Apps

| Keys | Action |
| ---- | ------ |
| `SUPER + Q` | Terminal |
| `SUPER + B` / `SHIFT + B` | Browser / incognito |
| `SUPER + E` | File manager |
| `SUPER + W` / `CTRL + W` / `SHIFT + W` | Close / SIGKILL / SIGQUIT |

## Noctalia and media

| Keys | Action |
| ---- | ------ |
| `SUPER + A` | Control-center |
| `SUPER + CTRL + L` | Session |
| `SUPER + SHIFT + V` | Clipboard |
| `ALT + Tab` | Window-switcher (skipped if already open) |
| `SUPER + SHIFT + F23` | Launcher menu |
| `Print` | Region screenshot |
| `XF86AudioRaise/LowerVolume`, `Mute`, `MicMute` | `wpctl` volume (locked, repeating) |
| `XF86MonBrightnessUp/Down` | Noctalia brightness ±5 (locked, repeating) |
| `XF86Calculator` | Media play/pause |

## Toggles (the `T` family)

| Keys | Action |
| ---- | ------ |
| `SUPER + T` | `togglesplit` (dwindle) / `consume_or_expel prev` (scrolling) |
| `SUPER + CTRL + T` | Layout `scrolling` ↔ `dwindle` |
| `SUPER + SHIFT + T` | Swap monitors |
| `SUPER + ALT + T` | Workspace to next monitor |
| `SUPER + V` | Float toggle + halve to monitor size |
| `SUPER + F` | Fullscreen toggle (helium/brave keep sidebar) |
| `SUPER + S` / `SHIFT + S` | Special `magic` show / send |
| Overview `T` / `SHIFT + T` | Same split/layout toggles inside overview |
| `SUPER + P`, then `T` | Built-in panel on/off |

## Focus with `SUPER + H J K L`

| Keys | Dwindle | Scrolling |
| ---- | ------- | --------- |
| `H` / `L` | Focus left / right | Column neighbor → `focus l / r`, else direction |
| `K` / `J` | Neighbor → up / down, else workspace `r-1 / r+1` | Neighbor → `focus u / d`, else workspace `r-1 / r+1` |
| `SUPER + mouse_up / down` | — | `focus l / r` |

## Move with `SUPER + SHIFT + H J K L`

| Keys | Dwindle | Scrolling |
| ---- | ------- | --------- |
| `H` / `L` | Move left / right | Vertical neighbor → move, else `swapcol l / r` |
| `K` / `J` | Neighbor → move up / down, else workspace `r-1 / r+1` | Same as dwindle |

Mouse: `SUPER + mouse:272` drag, `ALT + mouse:272` resize.

## Resize (repeating)

| Keys | Dwindle | Scrolling |
| ---- | ------- | --------- |
| `SUPER + ALT + H / L` | `x ∓50` relative | `colresize ∓0.1` |
| `SUPER + ALT + J / K` | `y ±50` relative | Same |

## Workspaces

| Keys | Action |
| ---- | ------ |
| `SUPER + 0-9` | Focus workspace 1-10 (`0` = 10) |
| `SUPER + SHIFT + mouse_down / up` | Prev / next workspace |
| `SUPER + ALT + E` | Empty workspace on current monitor |
| `SUPER + CTRL + J / K` | Reorder workspace ID ±1 within monitor (swap or create) |
| `SUPER + CTRL + O` | Renumber all IDs grouped by monitor |

## Move-window mode (`SUPER + M`)

| Keys | Action |
| ---- | ------ |
| `0-9` | Send to workspace 1-10 |
| `N / P` | Send to `m+1 / m-1` (monitor neighbor) |
| `SHIFT + N / P` | Send to `e+1 / e-1` (empty neighbor) |
| `E` | Send to `emptym` on current monitor + exit mode |
| `escape` | Abort |

## Display mode (`SUPER + P`) and lid

| Keys | Action |
| ---- | ------ |
| `T` | Toggle built-in `eDP-1` (blocked while lid closed) |
| `M` | Mirror `eDP-1` onto externals via `wl-mirror` / stop |

Lid closed + lone panel → lock-and-suspend; docked → disable built-in.
Unplug re-enables it and reloads, unless the lid is closed.

## Overview mode (`SUPER + Tab`)

| Keys | Action |
| ---- | ------ |
| `h / l / k / j` | Navigate |
| `SUPER + H / L / K / J` | Move window (same fallbacks as above) |
| `d` | Close window |
| `return` / `escape` | Overview off |
| `mouse:272` / `mouse:274` | Select + off / close window under cursor |
