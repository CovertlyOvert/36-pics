# 📸 36 Pics

A minimalist, retro-inspired Flutter app that limits users to just **36 photos per trip**, capturing the joy of mindful photography — like old film cameras.

---

## 🎯 Concept

On vacations or weekend trips, we often get lost in taking *too many* pictures, losing the moment itself.  
**36 Pics** reintroduces that nostalgic constraint — you get **only 36 shots** per trip, so every photo counts.

---

## ✨ Features

- 🧠 **Trip-based memory management**: Start a named trip session
- 📷 **Mock camera interface**: Tap to simulate taking photos
- 🔢 **Photo counter**: Clearly shows progress out of 36
- 🖼 **Gallery view**: See mock photo "names" in a grid layout
- 🎯 **Hard limit**: After 36 photos, shutter is disabled

> This is currently a **mock prototype**. Real camera/photo storage to be integrated in future versions.

---

## 🛠 Tech Stack

- [Flutter](https://flutter.dev/)
- Mock UI (no real camera storage yet)
- State management via `setState`
- Gallery built using `GridView`

---

## 🚀 Getting Started

Clone the repo:

```bash
git clone https://github.com/CovertlyOvert/36-pics.git
cd 36-pics
flutter pub get
flutter run
