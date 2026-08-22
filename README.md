# 📽️ Projector & Cast — Omarchy Status Bar Plugin

[![Omarchy Plugin](https://img.shields.io/badge/Omarchy-Plugin-blue)](https://omarchy.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Languages](https://img.shields.io/badge/Languages-8_supported-green)](I18n.js)

**Projector & Cast** (`elyefris.projector`) is an official third-party bar widget for **Omarchy Linux** and **Hyprland**. It provides 1-click screen mirroring (Miracast / Wi-Fi Direct) to classroom/auditorium projectors (such as Epson 3LCD laser projectors) and Smart TVs (TCL, Samsung, LG, Sony), with instantaneous resolution switching, intelligent HiDPI scaling, and multi-aspect ratio presets (16:9, 16:10, 21:9, 32:9, 4:3).

---

## ✨ Features

* **📡 1-Click Screen Mirroring (Miracast):** Seamlessly launches and manages `gnome-network-displays` with automatic PipeWire video streaming over Wi-Fi Direct (P2P).
* **📐 Multi-Aspect Ratio & Resolution Presets:**
  * **16:9 Standard (TVs & Monitors):** `1080p FHD`, `2K QHD (1.25x)`, `4K UHD (2x HiDPI)`, `720p HD Ready`.
  * **16:10 Classroom Projectors & Laptops:** `WXGA (Epson 1280x800)`, `WUXGA (1920x1200)`, `WQXGA (2560x1600 1.25x)`.
  * **21:9 & 32:9 Ultrawide:** `UW-FHD (2560x1080)`, `UW-QHD (3440x1440)`, `Super UW (5120x1440 1.25x)`.
  * **4:3 / 5:4 Classic:** `XGA (1024x768)`, `SXGA (1280x1024)`.
* **🔄 Hardware-Aware Native Restore:** Automatically detects your computer's native display resolution and scaling and restores it with a single click.
* **🌐 Multilingual Support (i18n):** Auto-detects system locale or allows quick manual switching between **English (EN)**, **Español (ES)**, **Português (PT)**, **Français (FR)**, **Deutsch (DE)**, **中文 (ZH)**, **日本語 (JA)**, and **한국어 (KO)**.
* **🛠️ Automated Firewall Diagnostics & Fix:** Detects UFW / Miracast RTSP (port 7236/tcp) and Wi-Fi Direct requirements, offering 1-click rule repair.
* **🪟 Hyprland Universal Compatibility:** Supports Omarchy's Lua runtime API with fallback to standard Hyprland keyword dispatching.

---

## 📦 Prerequisites

1. **GNOME Network Displays** (for Miracast wireless casting):
   ```bash
   sudo pacman -S gnome-network-displays
   ```

2. **Hyprland Window Rule (Recommended):**
   To keep the connection window floating and centered, add this rule to `~/.config/hypr/hyprland.lua`:
   ```lua
   o.window({ class = ".*[nN]etwork[dD]isplays.*" }, { float = true, center = true, size = "800 580" })
   ```
   *(Or in standard `hyprland.conf`: `windowrule = float, class:.*[nN]etwork[dD]isplays.*`)*

3. **Firewall (UFW):**
   If UFW is active, allow RTSP port 7236 and P2P Wi-Fi Direct:
   ```bash
   sudo ufw allow 7236/tcp comment 'Miracast-RTSP'
   sudo ufw allow in on p2p-+ comment 'Miracast-P2P'
   ```
   *(The plugin also includes a 1-click "Fix Firewall" button directly in the UI).*

---

## 🚀 Installation

### Via Omaplug / Git Clone
```bash
git clone https://github.com/elyefris/omarchy-projector-cast.git ~/.config/omarchy/plugins/elyefris.projector
omarchy restart shell
```

Then add `"elyefris.projector"` to your `~/.config/omarchy/shell.json` in `bar.layout.right`.

---

## 📜 License
MIT License © 2026 elyefris
