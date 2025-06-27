
We are gonna use 2 types of dto for the project 
    1 first type is gonna be used to communicate the DTO to the server but the server will have to convert this objectDTO into the objects.
        For sending data to the DB 
            For example
                Creating a user -> The user will have notifications_id this ids won't create the notification itself it will only address the relationship between the notification and the user object.

        For fetching data from the DB
            For example
                Fetching Data -> We can use objectsDTO in order to get the data from the DB,
                this will avoid uncessary data from the user object
                Different cases when we should use an objectDTO between a object with all the data.
                    Whenever we want to fetch data objects in these situations for example when we need to fetch data from the DB to retrieve notifications objects,
                    events objects, or any other data that we need the whole data, regardless of the relationship.

        2 How to manage the flow of the app.
            How do we mange the flow of the client input/front-end data in this case we can use provider, this provider object it's recommend to use the ids and interact with the ids instead of the whole value of the data so we can avoid any misunderstanding with the current data and the server data.

        
        3 How are we building the architecture of the app?
            In this case we're using MVC, we use models to create our objects then we proceed to use DTO to grab/fetch/update data with the controller this data is processed with the DTO and the sends to the DB where the DB will also has to filter any error.

        4 Implementation of AI in the app
            The basic idea of this inplementation is to pass data from the app to our AI system this system will provide a diverse analisys for my app,

        5 Implement the mobile app into a web app


