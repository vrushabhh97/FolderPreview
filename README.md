# 🧩 Folder & ZIP Quick Look Extension for macOS

macOS doesn't let you preview the contents of folders or zip files in Finder — even with the spacebar.  
So I built a Quick Look extension to fix that.

---

## ✨ Features

- 📁 **Folder Previews**: View folder contents (icons + names) in a grid without opening Finder
- 🗜️ **ZIP Previews**: View ZIP contents without unzipping
- ⚡ Triggered with a simple **Spacebar** press in Finder
- Native experience using macOS Quick Look framework

---

## 🧠 Tech Stack

- `Swift`
- `SwiftUI`
- `QuickLook.framework`
- [`ZIPFoundation`](https://github.com/weichsel/ZIPFoundation)

---

## 📥 How to Run the App Locally
### 1. 📥 Download the App

👉 [Download FolderPreview.app (ZIP)](https://drive.google.com/file/d/1qf9rvHNTmQiCeJfpY4JG2AQOJYpK28_P/view?usp=sharing)

### 2. Run the App

- Right-click or double-click on `FolderPreview.app`
- If you get a security warning, follow the instructions below to open it

---

## 🛡 macOS May Block the App (Unidentified Developer)

Since the app isn't signed with a Apple Developer ID, macOS will show:

> “`FolderPreview.app` can’t be opened because it is from an unidentified developer.”

### ✅ Here's how to allow it:

1. Try opening the app (it will fail with a warning)
2. Go to **System Settings > Privacy & Security**
3. Scroll to the **Security** section at the bottom
4. Click **“Open Anyway”** next to `FolderPreview.app`
5. Confirm in the popup dialog

Now the app should launch properly.

---

## 🚀 Using the Preview Feature

Once the app is opened:

1. Finder will register the extension
2. Select any **folder** or `.zip` file in Finder
3. Press **Spacebar**  
🎉 You'll see a live preview of its contents!

If it doesn’t appear:
- Try restarting Finder:  
  ```bash
  killall Finder
