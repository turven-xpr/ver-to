# Brick Wall Tasks & Goals (Ver-To)

A modern cross-platform Flutter productivity app combining granular task execution with tangible visual goal progression.

## Features

- 🧱 **Masonry Brick Wall Visualization**: Watch your long-term goals materialize brick-by-brick from the foundation up. Each completed task lays a brick in the wall.
- 📋 **Task Management**: Prioritized tasks (High, Medium, Low) with automated end-of-day expiration (23:59 PM today), quick toggle, mark as incomplete, edit, and delete options.
- 🔥 **Duolingo-Style Streak System**: Build an unbreakable habit streak requiring a minimum of **3 completed tasks per day** to ignite the daily flame, complete with 7-day visual calendar dots and progress tracker.
- 📖 **Journal & Printable PDF Book Export**: Record daily, weekly, and monthly reflections, and export them anytime into a beautifully formatted, publication-ready PDF book with cover page, summary, and goal completion status.
- ☁️ **Cloud Firestore & Offline-First Sync**: Automatic offline persistence with local fallback and real-time cloud synchronization with Firebase Auth (Google Sign-In + Guest Mode).

## Getting Started

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
2. Fill in your Firebase configuration values.
3. Fetch dependencies:
   ```bash
   flutter pub get
   ```
4. Run on your target platform:
   ```bash
   flutter run -d chrome
   # or
   flutter run -d android
   ```
