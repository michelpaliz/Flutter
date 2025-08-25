# Palmor

## Introduction

**Palmor** is more than just a calendar app — it’s about organizing work with care and collaboration.
Born from the spirit of *pal* (friend) and *amor* (love), Palmor helps teams, families, and small businesses manage schedules, events, and communication in a simple, connected way.

Whether you’re coordinating a family business, planning projects with your team, or just keeping track of daily life, Palmor combines **efficiency** with a touch of **human connection**.

---

## Features

### 🔐 Authentication

* Register, log in, verify email, and recover passwords.

### 👥 Groups

* Create groups with custom names and images.
* Add members by username.
* Assign roles to members.
* Manage group settings and membership.
* View your group list easily.

### 📅 Calendar

* Personal and shared group calendars.
* Monthly, weekly, and daily views.
* Agenda-style view for quick browsing.
* See group members at a glance.

### 🗓️ Events

* Add, edit, or delete events.
* Details: **title, start/end dates, location, description, notes**.
* Flexible repetition options:

  * Daily, Weekly, Monthly, Yearly (with intervals and end dates).

### 🔔 Notifications

* Real-time updates for group activity and events.
* Invitations and reminders powered by live sockets.

### 👤 Profile & Settings

* Personal profile with avatar.
* Theme customization (light/dark).
* Multi-language support (**English & Spanish**).

### 📤 File Uploads

* Upload images for groups and events.

### 🎨 Interface

* Smooth drawer-style menu.
* Floating action button (FAB) for quick actions.
* Clean, modern design with flexible themes.

---

✨ With Palmor, planning isn’t just about dates and tasks — it’s about staying connected with the people who matter most.
---

# High-level structure (what each top folder does)

* **lib/a-models/**

  * **group\_model/**: `group.dart`, `calendar.dart`, `agenda.dart`
  * **event/**: `event.dart`, `event_data_source.dart`, `event_group_resolver.dart`, `event_utils.dart`
  * **recurrenceRule/**: custom recurrence (weekly/daily/monthly/yearly) logic, utils, and display helpers
  * **notification\_model/**: user notifications (localization, invitation/update status)
  * **user\_model/**: `user.dart`
  * 👉 **Features:** typed models for events, groups, calendars, users; **rich recurrence rules**; notification data.

* **lib/b-backend/api/**

  * **auth/**: login, register, password flows + exceptions
  * **event/**: event services + string utils
  * **group/**: group services (create/edit/invite)
  * **user/**: user services
  * **notification/**: notification services
  * **socket/**: `socket_manager.dart`, `socket_events.dart` (real-time updates)
  * **recurrenceRule/**: server-side helpers
  * **blobUploader/**: image/file upload
  * **config/**: API client + constants
  * 👉 **Features:** API client layer for **auth**, **events**, **groups**, **users**, **notifications**, **file upload**, **real-time (sockets)**.

* **lib/c-frontend/**

  * **a-home-section/**: `home_page.dart`
  * **b-calendar-section/**

    * **screens/calendar/**: calendar UI and app bar/screen managers; appointment widgets
    * **screens/group-screen/**:

      * **create-group/**: search bar UI, image picker, controllers
      * **edit-group/**: update flows (image picker, init service)
      * **group-settings/**, **invited-user/**, **show-groups/**
    * **group\_functions/**: `group_manager.dart`, `group_service.dart`
    * **utils/**: loading, network, search bar, selected users, shared
  * **c-event-section/**

    * **screens/actions/**: full **Add / Edit Event** flows (inputs for title, dates, location, description, notes)
    * **screens/repetition\_dialog/**: dialogs for **Daily / Weekly / Monthly / Yearly** repetition (weekly day picker, intervals, until date)
    * **event\_screen/**: `event_detail.dart`
  * **d-log-user-section/**: login, register, splash, verify email, recover password
  * **e-notification-section/**: controllers, enums, UI for notifications
  * **f-settings-section/**: `settings.dart`
  * **g-agenda-section/**: `agenda_screen.dart`
  * **h-profile-section/**: `profile_screen.dart`
  * **routes/**: `appRoutes.dart`, `routes.dart`
  * **utils/**: `user_avatar.dart`
  * 👉 **Features:** **Calendar UI**, **Group management (create/edit/settings/invite/show)**, **Event CRUD with repetition**, **Auth screens**, **Notifications UI**, **Agenda**, **Profile**, **Settings**, **Routing**.

* **lib/d-stateManagement/**

  * **event/**: event data manager, notification helper
  * **group/**: group management
  * **user/**: presence + user management
  * **notification/**: base notifier + socket listener
  * **local/**: `LocaleProvider.dart`
  * **theme/**: theme management + preferences
  * 👉 **Features:** central state for **events/groups/users**, **live notifications**, **i18n**, **theme switching**.

* **lib/e-drawer-style-menu/**

  * Main scaffold, drawer, horizontal nav, contextual FAB
  * 👉 **Features:** app shell/navigation with drawer and FAB actions.

* **lib/f-themes/**

  * Palette, shape, themes, utilities
  * 👉 **Features:** theming system (light/dark/custom).

* **lib/l10n/**

  * `app_en.arb`, `app_es.arb`, localization glue
  * 👉 **Features:** **English & Spanish** localization.

* **lib/g-docs/**: project docs (AI\_Implementation, guidelines)

* **lib/utils/init\_main.dart** and **lib/main.dart**: app bootstrapping

---

# What the app can do (plain English)

* **Auth**: register, login, verify email, recover password.
* **Groups**: create groups, edit, set settings, invite members, assign roles, show group list, group profile dialogs.
* **Calendar**: full calendar view with appointments; app bar/screen managers; group calendars.
* **Events**: add/edit events with **title, start/end, location, description, notes**, plus **repetition** (daily/weekly/monthly/yearly with intervals, end dates, weekly day selection).
* **Agenda**: agenda-style list view.
* **Notifications**: user notifications + real-time updates via sockets; invitation/update status.
* **Profile & Settings**: user profile screen and app settings.
* **Uploads**: image/file uploads (e.g., group image).
* **Theming & i18n**: theme management and **EN/ES** localization.
* **Presence & State**: user presence tracking; centralized managers for events/groups/notifications.

---

# Quick pointers (where to look when coding)

* **Entry point**: `lib/main.dart` → routing in `c-frontend/routes/`.
* **Calendar UI**: `c-frontend/b-calendar-section/screens/calendar/`
* **Event flows**: `c-frontend/c-event-section/screens/actions/` and `.../repetition_dialog/`
* **Group flows**: `c-frontend/b-calendar-section/screens/group-screen/`
* **API layer**: `b-backend/api/*`
* **State mgmt**: `d-stateManagement/*`
* **Localization**: `l10n/*`
* **Drawer & Nav**: `e-drawer-style-menu/*`

---




