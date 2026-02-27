# Cisco DX80 Mod 🚀

This repository contains the configuration, macros, and documentation to "unchain" a Cisco DX80 (CE 9.15+) and turn it into a modern, dual-purpose collaboration workstation.

## Features

- **SIP Ready**: Optimized settings for Sipgate and Fritzbox integration.
- **Microservice Shortcuts**: Custom UI buttons for **Microsoft Teams** and **Zoom** via the internal Web Engine.
- **Web Browser Unlocked**: URL bar enabled for unrestricted web navigation.
- **Advanced UI**: Global Dark Mode, Proximity (Wireless Sharing), and Standby optimizations.
- **Macros**: Custom JavaScript logic for UI interaction and system monitoring.

## Repository Structure

- `MeetingShortcuts.js`: Macro code for Teams/Zoom integration.
- `SystemMonitor.js`: Macro for real-time room and device diagnostics.
- `README.md`: This guide.
- `WALKTHROUGH.md`: Step-by-step visual guide of the modifications.

## Installation / Activation

### 1. Enable Web Engine & Features
Run these commands in the **Developer API** (xAPI) terminal:
```bash
xConfiguration UserInterface WebEngine Mode: On
xConfiguration UserInterface WebEngine Features URLBar: On
xConfiguration UserInterface Appearance Mode: Dark
xConfiguration UserInterface Features Personalization: Allow
xConfiguration Proximity Mode: On
```

### 2. Deploy Macros
1. Go to **Macro Editor**.
2. Create two new macros: `MeetingShortcuts` and `SystemMonitor`.
3. Paste the contents of the respective `.js` files from this repo.
4. Save and **Enable** both macros.

### 3. SIP Configuration
Configure your provider (Sipgate/Fritzbox) under **Settings** > **Configuration** > **SIP** using the credentials provided in your private portal.

## Advanced Mods (Community Insights)

- **Wallpaper Styling**: `xCommand UserInterface Wallpaper Set Url: "https://your-image-url.jpg"`
- **Digital Signage**: `xConfiguration Standby Signage Url: "https://your-dashboard-url.com"`
- **Room Analytics**: Monitor temperature and noise via `xStatus RoomAnalytics`.

---
*Created with 💙 by Antigravity AI*
