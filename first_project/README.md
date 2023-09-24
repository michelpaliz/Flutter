# AUTHOR NAME:

CALENDAR BY MICHAEL PALIZ MORALES.

## Getting Started
This idea came out from a necessity of many companies that are always in the need of an application that can help them to work in a better manner/way of doing tasks more asynchronously and more efficiently.
The main reason that I decided to create this app is to help companies to have a better management for themselves and for their employees.

### Basic Usage
When we are talking about work we always have some sort of calendar or routine for each specific project/tasks, that is the reason companies needs to have a way for their workers/co-workers to have a way to handle this situation, and this is where this aplication came up with the idea to help companies to be able to share a better way to help companies with using a calendar, at the end this will enable the group to work asynchronously and make sure to follow the schedule.

### Group Usage and Functionality
A group is composed by members, this group is created by an administrator which will be the owner of the group, then the administrator/owner is able to add members by searching their names (username that are unique), then the administrator can select the roles for each member (roles are described more in detail in the roles section), with all of that in mind, groups also offers a diverse types of functionalities, there are three main functions for the group, one of them is creating events (Events are described more in detail in the events section), then the group section can also offer a view of settings (Settings are described more in its section),moreover there is also a way to show the list of the group's members that are displayed horizontally with their names 

To sum up groups are composed of different users which represent the groups itself, the purpose of the group is to create a way to communicate with  the members of the group with a calendar.

### User features 
The user possess events, those events are used to create a unique calendar for the user.

### Calendar features
The calendar shows the events that the user wants to create.

### Key features
A person can have multiple calendars associated but it can be notified by one calendar.

### Events 

An event is composed by a title, start date, end date, location, description, note and the repetition of the event.

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