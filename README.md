

# Hexora

## Introduction

**Hexora** is more than a calendar app — it’s a **powerful scheduling and collaboration platform** designed for teams, families, and small businesses.

The name comes from **Hex** (structure, connection, technology) and **Ora** (time, from the Spanish *hora*), symbolizing a perfect blend of **organization** and **time management**.

Whether you’re managing a family business, coordinating a project with your team, or just keeping track of your personal schedule, Hexora helps you **plan, connect, and visualize your time** like never before.

With **real-time updates**, **shared calendars**, and future-ready features like **data visualization** and **AI-powered insights**, Hexora turns scheduling into a seamless, collaborative experience.

---

## Features

### 🔐 Authentication

* Register, log in, verify email, and recover passwords.

### 👥 Groups

* Create groups with custom names and images.
* Add members by username.
* Assign roles to members.
* Manage group settings and membership.
* Quickly view and switch between groups.

### 📅 Calendar

* Personal and shared group calendars.
* Monthly, weekly, and daily views.
* Agenda-style view for streamlined browsing.
* Instantly see which group members are connected to events.

### 🗓️ Events

* Add, edit, or delete events.
* Event details include **title, start/end dates, location, description, and notes**.
* Flexible repetition options:

  * Daily, Weekly, Monthly, Yearly (with intervals and end dates).

### 📊 Graphs & Insights *(future-ready)*

* Generate **visual analytics** for events and schedules.
* Identify scheduling patterns with graphs and charts.
* Make informed decisions with **data-driven insights**.

### 🔔 Notifications

* Real-time notifications for group activity and events.
* Invitations and reminders powered by live socket connections.

### 👤 Profile & Settings

* Personal profile with avatar customization.
* Theme customization (light and dark modes).
* Multi-language support (**English & Spanish**).

### 📤 File Uploads

* Upload images for groups and events for richer collaboration.

### 🎨 Interface

* Smooth drawer-style navigation menu.
* Floating action button (FAB) for quick and intuitive actions.
* Clean, modern UI with customizable themes.

---

✨ With **Hexora**, scheduling isn’t just about setting dates — it’s about **connecting people**, **streamlining workflows**, and **bringing structure to time**.

---

# High-Level Structure

### **lib/a-models/**

* **group_model/**: `group.dart`, `calendar.dart`, `agenda.dart`
* **event/**: `event.dart`, `event_data_source.dart`, `event_group_resolver.dart`, `event_utils.dart`
* **recurrenceRule/**: custom recurrence logic for daily/weekly/monthly/yearly repetition with utilities and display helpers
* **notification_model/**: notifications, invitations, update statuses
* **user_model/**: `user.dart`

> **Purpose:** Typed models for events, groups, calendars, users, recurrence rules, and notifications.

---

### **lib/b-backend/api/**

* **auth/**: authentication flows (login, register, password recovery) + exceptions
* **event/**: event service layer and string utils
* **group/**: group services for creation, editing, invitations
* **user/**: user services
* **notification/**: notification handling and socket updates
* **socket/**: `socket_manager.dart`, `socket_events.dart` for real-time events
* **recurrenceRule/**: server-side recurrence helpers
* **blobUploader/**: image and file uploads
* **config/**: API client and constants

> **Purpose:** Backend API client and service layer for all major features.

---

### **lib/c-frontend/**

* **a-home-section/**: main home screen (`home_page.dart`)
* **b-calendar-section/**

  * **screens/calendar/**: calendar UI, app bar, and screen managers
  * **screens/group-screen/**:

    * **create-group/**: search bar, image picker, controllers
    * **edit-group/**: update flows, image picker, initialization
    * **group-settings/**, **invited-user/**, **show-groups/**
  * **group_functions/**: `group_manager.dart`, `group_service.dart`
  * **utils/**: search bar, selected users, shared widgets
* **c-event-section/**

  * **screens/actions/**: Add / Edit Event flows
  * **screens/repetition_dialog/**: dialogs for setting repetition rules
  * **event_screen/**: event detail view
* **d-log-user-section/**: login, register, splash, verify email, recover password
* **e-notification-section/**: notifications UI and controllers
* **f-settings-section/**: settings screen
* **g-agenda-section/**: agenda list screen
* **h-profile-section/**: profile screen
* **routes/**: app navigation routes
* **utils/**: user avatar utilities

> **Purpose:** Frontend UI, calendar, event, group management, notifications, profile, and routing.

---

### **lib/d-stateManagement/**

* **event/**: event data manager and notification helper
* **group/**: group state management
* **user/**: user presence and management
* **notification/**: socket-driven notification system
* **local/**: `LocaleProvider.dart` for i18n
* **theme/**: theme management and persistence

> **Purpose:** Central state hub for events, groups, notifications, users, and settings.

---

### **lib/e-drawer-style-menu/**

* Main scaffold, drawer navigation, horizontal tabs, contextual FAB

> **Purpose:** App shell with global navigation and quick access.

---

### **lib/f-themes/**

* Palette, shapes, theme utilities

> **Purpose:** Theming system for light, dark, and custom modes.

---

### **lib/l10n/**

* Localization files: `app_en.arb`, `app_es.arb`

> **Purpose:** Internationalization and multi-language support.

---

### **lib/g-docs/**

* Documentation and implementation guidelines, including AI integration plans.

---

### **lib/utils/init_main.dart** & **lib/main.dart**

* Application entry point and initialization.

---

# Key Capabilities (Plain English)

* **Authentication:** Secure account registration, login, and password recovery.
* **Groups:** Group creation, management, roles, and invitations.
* **Calendar:** Monthly, weekly, daily, and agenda-style calendar views.
* **Events:** Create, edit, and delete events with advanced recurrence.
* **Insights:** Future-ready visual analytics and reporting.
* **Notifications:** Real-time group and event updates via sockets.
* **Profiles & Settings:** User profile customization and preferences.
* **Uploads:** Image and file uploads for groups and events.
* **Themes & i18n:** Full dark/light mode and bilingual support (English, Spanish).
* **Real-time State:** Centralized state with live updates and user presence.

---

# Developer Pointers

* **Entry point:** `lib/main.dart`
* **Routing:** `c-frontend/routes/`
* **Calendar UI:** `c-frontend/b-calendar-section/screens/calendar/`
* **Events:** `c-frontend/c-event-section/screens/actions/`
* **Groups:** `c-frontend/b-calendar-section/screens/group-screen/`
* **API layer:** `b-backend/api/`
* **State management:** `d-stateManagement/`
* **Localization:** `l10n/`
* **Drawer navigation:** `e-drawer-style-menu/`

---

✨ With **Hexora**, your schedules transform into **connections, insights, and streamlined collaboration** — all in one unified platform.
