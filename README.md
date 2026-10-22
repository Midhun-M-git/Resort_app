# Resort Booking App

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

</div>

A full-stack resort room booking application built with Flutter and Supabase, designed for luxury resort stay management.

---

## Features

### User Experience
- Register and login with Supabase Authentication
- Browse rooms filtered by type (Standard, Deluxe, Suite, Villa, Presidential)
- View room details including floor, capacity, amenities, and price per night
- Real-time availability checks by custom date ranges
- Room booking with adult/children guest counters and calendar date picker
- Special requests, guest information, and automated price calculations
- Track personal bookings with real-time status indicators

### Admin Panel
- Secure role-based access control (Admin vs User)
- Operational dashboard with metrics: total rooms, revenue, and occupancy rates
- Complete room inventory CRUD management
- Instant room availability toggling
- Centralized booking oversight across all users
- Lifecycle booking state updates (Pending -> Confirmed -> Completed / Cancelled)

---

## Tech Stack

| Layer | Technology |
| :--- | :--- |
| Frontend | Flutter (Dart) |
| Backend | Supabase (PostgreSQL, Auth, Row Level Security) |
| State Management | Riverpod v2 |
| Navigation | GoRouter |
| Typography | Google Fonts (Playfair Display, Lato) |
| Data Visualization | fl_chart |
| Scheduling | table_calendar |

---

## Supported Platforms

- Android
- iOS
- Web
- Windows Desktop

---

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/Midhun-M-git/Resort_app.git
   cd Resort_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up Supabase:
   - Create a project on [supabase.com](https://supabase.com)
   - Execute the SQL schema from `supabase_schema.sql` in the SQL Editor
   - Copy your project URL and anon public key

4. Configure environment variables in `.env`:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```

5. Run the application:
   ```bash
   flutter run
   ```

---

## Admin Configuration

To grant administrative privileges:
1. Navigate to your Supabase Dashboard -> Table Editor -> `profiles`.
2. Locate your user record.
3. Update the `role` field from `user` to `admin`.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
