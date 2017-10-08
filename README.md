# README

API for Simple tracker:
* Before running of the application please make sure you have all dependencies installed. 
Run the commands: bundle install, to get them.
* Also you need to run rails db:migrate  and rails db:migrate RAILS_ENV=test to migrate entities to your database.
* The command to run this app is: rails s - It runs the application on the local server at development mode
* Locally application is available on localhost:3000

Authentication requests::

* For user registration use:  POST '/api/registrations' with params keys: 'email', 'password', 'password_confirmation'. 
* To remove your account use: DELETE '/api/registrations' with params keys: 'email', 'authentication_token' 
* For a 'sign in' request use: POST '/api/sessions' with params keys: params: 'email', 'password'.
* For a 'sign out' request use: DELETE '/api/sessions' with params keys: 'email', 'authentication_token'.

For the authentication it uses 2 ruby gems:
* 'Devise' for the storage and the manipulation of user's data such as: (email, password, confirmation etc).
* 'Simple Token Authentication'(generation and storage of authentication_tokens for users).

How it works:
* immediately after registration, these libraries  generate and storage authentication token. 
If the the request is successful  you'll get the user email and an authentication token in the response body. 
Please include these  authentication token and email to headers of next requests.
You should use the following  header keys:
X-User-Token for the authentication token and X-User-Email for the user email. 
If the user is registered but authentication token is expired -
you should make a 'sign in' request with user email and password in params.
In the response body you'll get the user email and authenticated token.
Please include these  authentication token and email to the headers of next requests.   

To Create, Update or Delete an issue use following requests:
* POST '/api/issues' with following params keys 'title', 'description'('title', 'description' are required).
* PATCH '/api/issues/:id' ('title', 'description' are required).
* DELETE '/api/issues/:id'

The POST and PATCH above requests returns issue as json.

NOTE: For the above requests you need the regular registration only.

End points to assign an issue to yourself and change issue states:
* PATCH '/api/issues/:id/assign'. - assigns an issue to yourself
(Note: you can  not assign an issue to yourself if the issue is already assigned to someone else).
* PATCH '/api/issues/:id/set_state'. Params key: 'state_event'.
Allowed state events are: 'open_issue' - sets the state  as 'in_progress', 'close_issue' - sets the state  as 'resolved', 'stop_issue'- sets the state  as 'pending'.
 By default any issue has the state 'pending' 
(Note: you can't set states 'in_progress' and 'close_issue' if the issue doesn't have assignee. 
You can not unassign  an issue with one of these states as well).


For both above requests you need to have the manager access.

The end point to Show an issue is: GET '/api/issues/:id'
you'll get an issue as json. 
(This request is available for any registered user). 

The end point to get a list of issues is: GET '/api/issues'
(a manager can see all issues, a regular user can see issues created by themselves)
Both a manager and a regular user can filter issues by state passing state as params.
For it use the params key - 'filter'. Allowed values for the filtering are: 'pending', 'in_progress', 'resolved'. 
You can paginate response as well. For the pagination you need to pass following params keys:
'page' - the page sequence number, 'per_page' -  the number of objects to show.

Requirments:
* Ruby version 2.4.2
* DBMS PostgreSQL

Libraries:
* rails 5.1.4 - base
* devise + simple_token_authentication (registration and authentication)
* rolify - roles assigning
* state_machines-activerecord - state management
* pundit - authorisation
* will_paginate + api-pagination - pagination
* rspec - testing