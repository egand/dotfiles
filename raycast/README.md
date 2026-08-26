# Raycast Configuration & Dotfiles Sync

Raycast stores hotkeys, extensions, and preferences inside an encrypted database on macOS, but provides a native **Export & Import** mechanism (`.rayconfig`) that allows you to version-control your complete setup in your dotfiles.

---

## 1. One-Time Setup on This Mac

### A. Set Ghostty as the Terminal
1. Open Raycast (`Cmd + Space`).
2. Search for **Ghostty**.
3. Press **`Cmd + K`** to open the Action menu.
4. Select **Set Alias** and type `terminal`.
5. *(Optional)* Search for Apple's built-in **Terminal**, press **`Cmd + K`**, and select **Hide Application**.
6. Open Raycast Settings (`Cmd + ,`) -> **Extensions** -> Set **Terminal Application** to **Ghostty**.

### B. Configure Clipboard History Hotkey
1. Open Raycast Settings (`Cmd + ,`).
2. Go to the **Extensions** tab.
3. Search for **Clipboard History**.
4. Click on the **Hotkey** field and press **`Cmd + Shift + V`** (or `Option + V`).

---

## 2. Export & Save to Dotfiles

Once configured, save your setup into this repository:

1. Open Raycast Settings (`Cmd + ,`).
2. Go to the **Advanced** tab.
3. Scroll down to **Import / Export** and click **Export Settings & Data...**.
4. Choose the destination folder:
   ```
   ~/.dotfiles/raycast/raycast.rayconfig
   ```
   *(Setting an export password is optional).*
5. Commit the backup to your git repository:
   ```bash
   git -C ~/.dotfiles add raycast/raycast.rayconfig
   git -C ~/.dotfiles commit -m "feat(raycast): save raycast configuration backup"
   ```

---

## 3. Restoring on a New Mac

When setting up a new Mac or restoring your environment:

### Method 1: Single Terminal Command
```bash
open ~/.dotfiles/raycast/raycast.rayconfig
```
Raycast will launch its native import wizard and restore all hotkeys, aliases, extensions, and settings in one click.

### Method 2: Raycast UI
1. Open Raycast Settings (`Cmd + ,`) -> **Advanced** tab.
2. Click **Import Settings & Data...**.
3. Select `~/.dotfiles/raycast/raycast.rayconfig`.
