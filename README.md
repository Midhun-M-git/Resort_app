# 🏨 Resort Booking App

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

</div>

A full-stack resort room booking application built with Flutter and Supabase, 
inspired by platforms like BookMyShow — but for luxury resort stays.

## ✨ Features

### 👤 User Side
- Register / Login with Supabase Auth
- Browse rooms filtered by type (Standard, Deluxe, Suite, Villa, Presidential)
- View room details — floor, capacity, amenities, price per night
- Real-time availability check by date range
- Book rooms with adult/children guest counters and calendar date picker
- Special requests, guest info, and automatic price calculation
- View and track all personal bookings with status badges

### 🛠️ Admin Panel (built into the app)
- Secure role-based access (admin vs user)
- Dashboard with live stats — total rooms, revenue, occupancy
- Add, edit, delete rooms with full details
- Toggle room availability instantly
- View all bookings across all users
- Update booking status — Pending → Confirmed → Completed / Cancelled

## 🧰 Tech Stack

| Layer       | Technology                          |
|-------------|-------------------------------------|
| Frontend    | Flutter (Dart)                      |
| Backend     | Supabase (PostgreSQL + Auth + RLS)  |
| State Mgmt  | Riverpod v2                         |
| Navigation  | GoRouter                            |
| UI/Fonts    | Google Fonts (Playfair Display + Lato) |
| Charts      | fl_chart                            |
| Calendar    | table_calendar                      |

## 📱 Platforms
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows

## 🚀 Getting Started

1. Clone the repo
   git clone https://github.com/Midhun-M-git/Resort_app.git

2. Install dependencies
   flutter pub get

3. Set up Supabase
   - Create a project at https://supabase.com
   - Run the SQL schema from supabase_schema.sql in the SQL Editor
   - Copy your project URL and anon key into .env

4. Add your .env file
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key

5. Run the app
   flutter run

## 🔐 Make Yourself Admin
After registering, go to Supabase Dashboard → Table Editor → profiles
→ find your row → change role from user to admin.

## 📄 License
MIT
