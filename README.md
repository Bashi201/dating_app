# 💘 FlutterMatch

A modern, full-stack dating application inspired by Tinder and Bumble — built with **Flutter** (mobile) and **Laravel** (REST API).

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Laravel](https://img.shields.io/badge/Laravel-11.x-FF2D20?logo=laravel)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?logo=postgresql)
![Cloudinary](https://img.shields.io/badge/Cloudinary-Image%20Storage-3448C5?logo=cloudinary)

---

## 📱 What is FlutterMatch?

FlutterMatch allows users to discover profiles, swipe right to like or left to dislike, match with mutual connections, and chat in real time. When two users like each other, a match is created and a private chat channel opens between them.

### ✨ Core Features

- 🔐 **Auth** — Register, login, logout via Laravel Sanctum tokens
- 👤 **Profile Setup** — Bio, age, gender, interests, city, Instagram, Spotify
- 📸 **Photo Upload** — Up to 6 photos per user, stored on Cloudinary
- 🔍 **Discovery Feed** — Swipeable card stack filtered by age & distance
- 💞 **Match System** — Mutual likes create a match instantly
- 💬 **Real-time Chat** — WebSocket chat via Laravel Reverb
- 🚫 **Safety** — Block and report users
- 🛡️ **Admin Panel** — Ban users, review reports, delete photos

---

## 🗂️ Project Structure

This is a **monorepo** containing both the backend and mobile app:

```
FlutterMatch/
├── fluttermatch-api/        ← Laravel REST API (Backend)
└── fluttermatch_app/        ← Flutter Mobile App (Frontend)
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter 3.x + Dart + Riverpod |
| Backend | Laravel 11 + PHP |
| Database | PostgreSQL |
| Auth | Laravel Sanctum (token-based) |
| Image Storage | Cloudinary |
| Real-time | Laravel Reverb (WebSockets) |
| HTTP Client | Dio |
| Secure Storage | flutter_secure_storage |

---

## 🚀 Getting Started

### Prerequisites

- PHP 8.2+
- Composer
- PostgreSQL
- Flutter 3.x SDK
- A free [Cloudinary](https://cloudinary.com) account

---

### 🔧 Backend Setup (Laravel)

```bash
# 1. Navigate to the backend folder
cd fluttermatch-api

# 2. Install PHP dependencies
composer install

# 3. Copy the environment file
cp .env.example .env

# 4. Generate application key
php artisan key:generate

# 5. Configure your .env file (see below)

# 6. Run database migrations
php artisan migrate

# 7. Start the development server
php artisan serve
```

**Required `.env` values:**

```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=fluttermatch
DB_USERNAME=postgres
DB_PASSWORD=your_password

CLOUDINARY_URL=cloudinary://API_KEY:API_SECRET@CLOUD_NAME
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

> ⚠️ **Never commit your `.env` file.** It is already listed in `.gitignore`. Each teammate fills in their own credentials.

---

### 📱 Flutter App Setup

```bash
# 1. Navigate to the Flutter folder
cd fluttermatch_app

# 2. Install Flutter dependencies
flutter pub get

# 3. Set your API base URL
# Edit: lib/core/constants/api_constants.dart
# Android emulator:  http://10.0.2.2:8000/api
# iOS simulator:     http://127.0.0.1:8000/api
# Physical device:   http://YOUR_LOCAL_IP:8000/api

# 4. Run the app
flutter run
```

---

### 👥 Onboarding a New Teammate

After cloning the repo a teammate only needs to:

```bash
git clone https://github.com/YOUR_USERNAME/FlutterMatch.git
cd FlutterMatch/fluttermatch-api
composer install
cp .env.example .env
# → Fill in DB credentials and Cloudinary keys in .env
php artisan key:generate
php artisan migrate
php artisan serve
```

> ✅ No `php.ini` edits needed — SSL handling for Cloudinary is done in code automatically for `local` environments.

---

## 📡 API Overview

### Auth
| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/register` | Create account |
| POST | `/api/login` | Login, returns token |
| POST | `/api/logout` | Revoke token |
| GET | `/api/me` | Get current user |

### Profile
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/profile` | Get own profile |
| PUT | `/api/profile` | Update profile |
| POST | `/api/profile/photos` | Upload photo |
| DELETE | `/api/profile/photos/{id}` | Delete photo |
| PATCH | `/api/profile/photos/{id}/primary` | Set primary photo |

### Discovery & Matches
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/discover` | Get discovery feed |
| POST | `/api/like/{userId}` | Like a user |
| POST | `/api/dislike/{userId}` | Dislike a user |
| GET | `/api/matches` | List all matches |
| GET | `/api/matches/{id}/messages` | Get chat messages |
| POST | `/api/matches/{id}/messages` | Send a message |

All protected endpoints require the header:
```
Authorization: Bearer YOUR_TOKEN
```

---

## 🗄️ Database Schema

8 core tables: `users`, `profiles`, `photos`, `likes`, `matches`, `messages`, `blocks`, `reports`

```
users ──── profiles
  │  └──── photos
  │
  ├──── likes (liker_id → liked_id)
  │
  ├──── matches (user1_id, user2_id)
  │         └──── messages
  │
  ├──── blocks
  └──── reports
```

---

## 📸 Photo Upload Flow

```
Flutter app
  → multipart POST /api/profile/photos
    → Laravel validates file
      → Uploads to Cloudinary
        → Stores public_id + secure_url in DB
          → Returns PhotoResource to Flutter
```

---

## 🔒 Security

- Passwords hashed with **bcrypt** via Laravel's `Hash` facade
- Tokens issued per-device via **Laravel Sanctum**
- Rate limiting on login/register (`6 requests/minute`)
- Banned users blocked at login and on every authenticated request
- `.env` file never committed to version control

---

## 🏗️ Production Deployment Notes

- Set `APP_ENV=production` and `APP_DEBUG=false`
- Use HTTPS with a valid SSL certificate
- Enable Redis for cache, sessions, and queues
- Run queue workers with Supervisor
- Set up Cloudflare or a CDN in front of the API

---

## 📄 License

MIT License — feel free to use this project as a learning resource or starting point.

---

## 🙋 Author

Built by **Bhashitha** — contributions and feedback welcome.
