# AUTHOR NAME:

CALENDAR BY MICHAEL PALIZ MORALES.

## Getting Started
This idea came out from a necessity of many companies that are always in the need of an application that can help them to work in a better manner/way of doing tasks more asynchronously and more efficiently.
The main reason that I decided to create this app is to help companies to have a better management for themselves and for their employees.
### Basic Usage
When we are talking about work we always want to have some sort of calendar for each specific project/task, but we also want our workers/co-workers to have a calendar. This app will help us to share a calendar for the group, this will enable the group to work asynchronously and make sure we are following the schedule that we got in our calendar.

A group is composed by a group of workers which will help them to work with an unique calendar, this is very simple, the group has a calendar where the members will be able to share the calendar. Therefore groups will have roles for each member of the group, each role will represent a function for the calendar and for the group. The roles are the following ones; administrator, co-administrator and member; administrators can add, remove and edit events, meanwhile co-administrators can only add events, and finally the members can only view the events.

### User features 
The user possess events, those events are used to create a unique calendar for the user.
### Group features
Groups are composed of different users which represent the groups itself, the purpose of the group is to create a way to communicate with  the members of the group with a calendar
### Calendar features
The calendar shows the events that the user wants to create
### Key features
A person can have multiple calendars associated but it can be notified by one calendar

## INITIAL VERSION OF THE CALENDAR APPLICATION  
### 1. introduction (Date: 2023-08-01 to 2023-08-23)  
The calendar itself has been created using a library from flutter and include Firestore to store the data of the calendar in this case we are talking about the events that a calendar posses. The events contains a time which is related of the time creation of the event.

### 2. Menu features (Date: 2023-08-01 to 2023-08-23)
The menu features are implemented in the calendar application, it contains a list of items, which are the following ones; Dashboard, NotesView, Settings and Log out.

- **Dashboard**: It will display a list of the Groups created by the user and also provide the functionality to create a group. There is an icon in the right corner of the view that will provide notifications.
- **NotesView**: This view display the default calendar that the user posses.
- **Settings**: This view will provide a sets of settings for the user, it's not yet finished.
- **Log out**: This view will provide a log out for the user.

### 3. Functionality for creating a group  (Date: 2023-08-01 to 2023-08-23)
This view will provide the functionality to create a group, to create a group, the user will need to put a name for the group, select the members for the group and specify the roles types for the group.