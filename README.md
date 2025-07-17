
# 🚨 Zone Guard

Zone Guard is a community-driven crime reporting mobile application built with **Flutter** and powered by **Supabase**. It enables users to stay informed, report incidents, and contribute to safer neighborhoods through real-time location-based crime data.



---

## 📱 Features

- 🔐 **User Authentication**
  - Secure login & registration using Supabase Auth
- 🗺️ **Live Crime Map**
  - Visualize incidents on an interactive map with color-coded severity
- 📝 **Add Crime Reports**
  - Post incident details with optional images and automatic location tagging
- 📍 **Location Awareness**
  - Auto-detects user’s current location (e.g., Mirpur, Mohammadpur, Uttara)
- 📨 **Inbox & Notifications**
  - Stay updated on crime reports in your area
- ⚙️ **Settings**
  - Manage profile, privacy, and notification preferences

---

## 📦 Tech Stack

| Frontend | Backend | Other |
|----------|---------|-------|
| Flutter  | Supabase (Auth, DB, Storage) | OSM API |
| Dart     | PostgreSQL (via Supabase)   | GeoLocation      |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Supabase account & project
- Android/iOS emulator or real device

### Clone the repo

```bash
git clone https://github.com/faiyazzrahman/zoneguard.git
cd zoneguard
````

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

---

## 🔐 Supabase Setup

1. Create a project at [Supabase](https://supabase.com)
2. Set up the following:

   * **Authentication** (enable email auth)
   * **Database tables**: `profiles`, `incidents`, `locations`
   * **Storage buckets**: `profile-pictures`, `incident-images`
3. Configure your `lib/supabase_config.dart` file:

```dart
const supabaseUrl = 'https://your-project.supabase.co';
const supabaseKey = 'public-anon-key';
```

---

## 📁 Project Structure

```
lib/
├── auth/
├── components/
├── models/
├── pages/
│   ├── HomePage.dart
│   ├── PostCrimePage.dart
│   ├── InboxPage.dart
│   ├── SettingsPage.dart
├── services/
├── supabase_config.dart
└── main.dart
```

---

## 🤝 Contributions

Contributions are welcome! Here's how you can help:

* 🐞 Report bugs
* 💡 Suggest new features
* 📄 Improve documentation
* 📱 Enhance UI/UX

---

## 🧠 Future Improvements

* Role-based access for moderators/police
* Heatmap for crime hotspots
* Offline incident caching
* Real-time push notifications

---

## 📜 License

[MIT License](LICENSE)

---

## 🙋‍♂️ Author

**Md Faiyazur Rahman**
Specializing in UI/UX Design • Full-Stack Development • Mobile Apps
📫 [Connect on LinkedIn](https://linkedin.com/in/faiyazzrahman)
🌐 [My GitHub](https://github.com/faiyazzrahman)

---

> *"Empowering safer communities through technology."*
> — Zone Guard Team

```

