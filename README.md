# Resort Booking App

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![Analysis](https://github.com/Midhun-M-git/Resort_app/actions/workflows/analyze.yml/badge.svg)](https://github.com/Midhun-M-git/Resort_app/actions/workflows/analyze.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

</div>

A full-stack cross-platform luxury resort room booking application built with Flutter and Supabase. Features real-time availability checks, role-based admin oversight, and booking telemetry.

---

## Architecture and Dataflow

```mermaid
graph TD
    subgraph Client Application
        UI[Flutter Presentation Layer]
        State[Riverpod v2 State Management]
        Router[GoRouter Navigation]
    end

    subgraph Backend Infrastructure
        Auth[Supabase Auth Engine]
        DB[(PostgreSQL Database)]
        RLS[Row Level Security Engine]
    end

    UI --> State
    State --> Router
    State -->|JWT Authenticated Session| Auth
    State -->|Direct RPC / REST Queries| RLS
    RLS -->|Filtered Queries| DB
```

---

## Booking State Machine

```mermaid
stateDiagram-v2
    [*] --> RoomSearch: User selects dates & capacity
    RoomSearch --> RoomDetails: Room available
    RoomDetails --> PendingBooking: Confirm booking request
    PendingBooking --> Confirmed: Admin approval / Auto-confirmation
    Confirmed --> CheckedIn: Guest arrives
    CheckedIn --> Completed: Check-out completed
    PendingBooking --> Cancelled: User cancels / Timeout
    Confirmed --> Cancelled: Admin cancellation
    Completed --> [*]
    Cancelled --> [*]
```

---

## Features

### User Experience
- Register and login with Supabase Authentication
- Dynamic room directory filtered by category (Standard, Deluxe, Suite, Villa, Presidential)
- Granular room profiles detailing floor plan, capacity, amenities, and nightly pricing
- Real-time room availability verification against current reservations
- Date range picker with guest volume controls (Adults and Children)
- Automated price calculation engine including taxes and special requests
- Reservation history dashboard with real-time status tracking

### Administrative Controls
- Role-based access control protecting administrative endpoints
- Operational dashboard displaying total rooms, gross revenue, and occupancy rates
- Complete inventory CRUD management with instant status toggling
- Centralized booking oversight with filterable reservation records
- Administrative status transitions (Pending -> Confirmed -> Completed / Cancelled)

---

## Database Schema Overview

```mermaid
erDiagram
    PROFILES ||--o{ BOOKINGS : places
    ROOMS ||--o{ BOOKINGS : includes
    
    PROFILES {
        uuid id PK
        string email
        string full_name
        string role
        timestamp created_at
    }
    ROOMS {
        uuid id PK
        string room_number
        string room_type
        decimal price_per_night
        int capacity
        boolean is_available
    }
    BOOKINGS {
        uuid id PK
        uuid user_id FK
        uuid room_id FK
        date check_in
        date check_out
        decimal total_price
        string status
    }
```

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
   - Execute the schema definitions from `supabase_schema.sql` in the SQL Editor
   - Copy your project URL and public anon key

4. Configure environment credentials in `.env`:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```

5. Launch the application:
   ```bash
   flutter run
   ```

---

## Admin Configuration

To promote a registered account to Administrator:
1. Navigate to Supabase Dashboard -> Table Editor -> `profiles`.
2. Locate the target user row.
3. Update the `role` value from `user` to `admin`.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
