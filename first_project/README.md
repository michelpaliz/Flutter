# AUTHOR: Michael Paliz Morales

## Introduction
The concept for this calendar application, aptly named "Calendar," stemmed from the common need for companies to streamline their task management processes in a more asynchronous and efficient manner. I embarked on creating this application with the primary goal of assisting companies in achieving better self-management and facilitating smoother collaboration among their employees.

## Basic Usage
In the realm of work, every project and task typically follows a specific schedule or routine. Consequently, organizations require a means for their employees to manage these schedules effectively. This is precisely where the "Calendar" application comes into play. It provides companies with a solution to enhance collaboration by utilizing a shared calendar, enabling teams to work asynchronously while adhering to their schedules.

## Group Usage and Functionality
Groups within the "Calendar" app are structured with an administrator, who serves as the group's owner. The administrator has the authority to add members by searching for their unique usernames. Additionally, the administrator can assign specific roles to each member, which are detailed further in the "Roles" section. Groups offer various functionalities, including event creation (explained in the "Events" section), settings management (detailed in its respective section), and displaying a horizontal list of group members along with their names.

In summary, groups are collections of diverse users representing the organization, aiming to facilitate communication through a shared calendar.

## User Features
Each user possesses their own set of events, which are used to construct their personalized calendar.

## Calendar Features
The calendar showcases the events that users have created, providing an organized view of their schedules.

## Key Features
A user can associate multiple calendars but will receive notifications from a single calendar.

## Events
An event within the "Calendar" app comprises various attributes, including a title, start date, end date, location, description, notes, and event repetition.

## Initial Version of the Calendar Application
### 1. Introduction (Date: August 1, 2023, to August 23, 2023)
The calendar application was developed using a Flutter library and incorporates Firestore to store calendar-related data, primarily focusing on events. Each event includes a timestamp corresponding to its creation time.

### 2. Menu Features (Date: August 1, 2023, to August 23, 2023)
The menu features have been integrated into the calendar application, featuring the following items: Dashboard, NotesView, Settings, and Log Out.

- **Dashboard**: This section displays a list of user-created groups and offers the option to create new groups. A notifications icon in the top-right corner provides updates.
- **NotesView**: This view presents the user's default calendar.
- **Settings**: The settings view is under development and will offer various configuration options for the user.
- **Log Out**: This view allows users to log out of the application.

### 3. Functionality for Creating a Group (Date: August 1, 2023, to August 23, 2023)
This view empowers users to create groups efficiently. To create a group, users must provide a name for the group, select members to include, and specify role types for the group members.
