# simple-chat-model
* A simple yet comprehensive chat model built in mysql.
* An API built in Node.js to fetch all chat channels (one to one OR group) ,last sent messages and unread message count.


### chat model tables
* **users** - contains basic information like name, email, phone no , profile photo url of the users using chatapp.
* **channels** - contains entry of any new channel initiated by user. 
   * channel_id - channel id of any new channel
   * channel type  - IF 1 then its a group chat ELSE one to one
   * channel name -  contains name of group (only for channel type =1)
   * channel picture - contains group picture (only for channel type =1)
   * channel admin  - contains admin email (only for channel type =1)
   * channel status  - IF 1 then active ELSE inactive
   * creation datetime  - time of channel creation

* **user_channels** - contains entry of every user in a channel. 
   * user_channel_id - primary key for table
   * user_id  - Id of user in channel (FK references to users table)
   * channel_id -  channel id in which user is present (FK references to users channel)
   * status - user to channel status  (1 = active , 0 = in active)
   * last_read_msg_id  - msg id of last message ready by user in a channel
   * is_pinned - column to incorporate pinned functionality
   * created_at  - user to channel relationship created at time (useful for channel type = 1 where a person is later  added)

* **messages** - contains entry of every message sent in a channel by an user. 
   * message_id - primary key for table
   * user_id  - Id of the user who sent msg (FK references to users table)
   * channel_id - channel id in which user has sent the message
   * message text - text msg sent by a user in channel
   * creation_datetime  - datetime of msg creation
   * is_deleted - message deleted by user or not

* **channel_last_message** - contains entry of the last msg sent in every channel using **SQL trigger** wrote on
**messages** tables, This was done to reduce the complexity of sql query(**getConversations**)  which brings all user chanels and last msg by maintaining 1 to 1 relationship between chanels and last msg sent which otherwise for a large data set could lead to increase in response time, for more refer to the function *getConversations* in service.js
   * message_id - last msg sent Id in a channel,updated for every new msg sent by user in a channel.
   * channel_id  - channel (unique key) corresponding to which the latest msg is stored.


### API RESPONSE EXAMPLES

* SCENARIO - ONE TO ONE CONVERSATION 
   * user1 creates a channel to talk to user2 and sends a message.
   * new channel id 4 created in table - **channels** (ch)
   * two new rows inserted in  **user_channels** table, user1 - ch4 AND user2 - ch4
   * message_id is created in **messages**, user1 - ch4 - message text and copied in table **channel_last_message** as        
     channels latest message (message_id , channel_id) .
   * last_read_msg_id is updated to newly created message_id in **user_channels** corresponding to user1 - ch4 entry.

   * **API results for first page for USER1 when USER2 hasnt replied yet and channel has a single messsage**
   ```{
   "message": "Successful",
   "status": 200,
   "data": [
      {
         "channel_id": 4,  --- represents channel id
         "last_message_id": 1, --- last message sent id
         "channel_type": 0, --- channel type , 0 for one to one and 1 for group conversations
         "channel_picture": "user2 picture link", --- profile picture of the other user for channel type 0 and group photo for channel type 1
         "is_pinned": 0, --- pinned functionality key
         "message_text": "hey user2 how have you been?", --- message text to be shown
         "date_time": "2020-09-19T04:35:48.000Z", --- time of message creation
         "is_deleted": 0, --- delete functionlity key
         "last_sent_by_id": 1, --- Id of the user who sent last msg (useful for ch type 1)
         "last_sent_by_full_name": "user1", --- name of the user who sent last msg (useful for ch type 1)
         "label": "user2", --- label of the channel (username of the other user for ch type 0 and group name for ch type 1 )
         "unreadCount": 0 --- count of unread messages which of this scenario is 0, as user1 has sent a single text and there are no new messages in channel. 
      }
   ]
   }
   ```

   * user2 sees the message and replies with 2 new messages which updates the last_read_msg_id in **user_channels** for user2 - ch4 entry .
   * 2 messages_ids are created in **messages** for user2 - ch4 entry, which furthur updates the latest message of ch-4 in 
   **channel_last_message** .


   * **API results for first page for USER1 when USER2 has replied with 2 new messages which USER1 hasnt seen yet**
   ```{
   "message": "Successful",
   "status": 200,
   "data": [
      {
         "channel_id": 4,
         "last_message_id": 3,
         "channel_type": 0,
         "channel_picture": "user2 profile picture link",
         "is_pinned": 0,
         "message_text": "i am great how are you",
         "date_time": "2020-09-19T05:29:20.000Z",
         "is_deleted": 0,
         "last_sent_by_id": 2,
         "last_sent_by_full_name": "user2",   
         "label": "user2", 
         "unreadCount": 2   --- unread count is now 2 as there are 2 new unseen messages from user2 
      }
   ]
   }
   ```

   * user1 sees the message and replies with 5 new messages which updates the last_read_msg_id in **user_channels** for user1 - ch4 entry .
   * 5 new messages_ids are created in **messages** for user1 - ch4 entry, which furthur updates the latest message of ch-4 in 
   **channel_last_message** .

   * **API results for first page for USER2 when USER1 has replied with 5 new messages which USER2 hasnt seen yet**
   ```{
   "message": "Successful",
   "status": 200,
   "data": [
      {
         "channel_id": 4,
         "last_message_id": 8,
         "channel_type": 0,  --- one to one conv with user 1
         "channel_picture": "user1 profile picture link", --- profile picture of user1
         "is_pinned": 0,
         "message_text": "lets have a drink together",
         "date_time": "2020-09-19T05:44:48.000Z",
         "is_deleted": 0,
         "last_sent_by_id": 1,
         "last_sent_by_full_name": "user1", 
         "label": "user1",  --- label of the channel as user1
         "unreadCount": 5   --- 5 unread messages from user1
      }
   ]
   }
   ```
   * soon as the user2 reads all the messages , the last_read_msg_id is updated in **user_channels** for user2 - ch4 entry .
   * and the process continues.

* SCENARIO - GROUP CONVERSATION 
   * user3 creates a  group channel with user1 and user 2 and sends a message.
   * new group type (ch type = 1) channel id 5 created in table - **channels** (ch)
   * three new rows inserted in  **user_channels** table, user3 - ch5 AND user1 - ch5 AND user2 - ch5
   * new message_id is created in **messages**, user3 - ch5 - message text and copied in table **channel_last_message**  as channels latest message (message_id,channel_id).
   * last_read_msg_id is updated to newly created message_id in **user_channels** corresponding to user3 - ch5 entry.

   * **API results for first page for USER3 when no other participant has replied yet and channel has a single messsage**
   ```{
   "message": "Successful",
   "status": 200,
   "data": [
      {
         "channel_id": 5,
         "last_message_id": 9,
         "channel_type": 1,  --- group chat
         "channel_picture": "group pofile photo link",  --- group profile picture link
         "is_pinned": 0,
         "message_text": "guys up for dinner?",  --- group's latest msg
         "date_time": "2020-09-19T06:12:44.000Z",
         "is_deleted": 0,
         "last_sent_by_id": 3,
         "last_sent_by_full_name": "user3", --- groups latest message sender which is user3 iteself
         "label": "himachal lads", --- group label or name
         "unreadCount": 0  --- no unread count for user3 as there is only one msg in group sent by user3 itself
      }
   ]
   }
   ```

   * user1 sees the message and replies with 2 new messages which updates the last_read_msg_id in **user_channels** for user1 - ch5 entry .
   * 2 messages_ids are created in **messages** for user1 - ch5 entry, which furthur updates the latest message of ch-5 in 
   **channel_last_message** .
   * user2 still hasnt seen any of the messages sent by user3 or user1.


   * **API results for first page for USER2 when it hasnt seen any group messages yet**
   ```{
   "message": "Successful",
   "status": 200,
   "data": [
      {
         "channel_id": 5,
         "last_message_id": 11,
         "channel_type": 1,
         "channel_picture": "group pofile photo link",  --- group profile picture
         "is_pinned": 0,
         "message_text": "i will take a rain check this time",  --- last message sent text
         "date_time": "2020-09-19T06:21:22.000Z",
         "is_deleted": 0,
         "last_sent_by_id": 1,
         "last_sent_by_full_name": "user1",  --- last message user's username
         "label": "himachal lads",  --- group name
         "unreadCount": 3  --- 3 unread messages in group (1 from user3 and 2 from user1)
      },
      {
         "channel_id": 4,
         "last_message_id": 8,
         "channel_type": 0,
         "channel_picture": "user1 profile picture link",
         "is_pinned": 0,
         "message_text": "lets have a drink together",
         "date_time": "2020-09-19T05:44:48.000Z",
         "is_deleted": 0,
         "last_sent_by_id": 1,
         "last_sent_by_full_name": "user1",
         "label": "user1",
         "unreadCount": 0
      }
   ]
   }
   ```
   * user2 has two channels , a group chat containing user1,user2 AND one to one chat with user1 ,the channels are sorted with latest message ids. 
   * user2 sees all the messages and replies with 2 new messages in group which updates the last_read_msg_id in **user_channels** for user2 - ch5 entry .
   * 2 more messages_ids are created in **messages** for user2 - ch5 entry, which furthur updates the latest message of ch-5 in **channel_last_message** .

   * **API results for first page for USER3 who hasnt seen any messages apart from the first text it sent**
   ```{
   "message": "Successful",
   "status": 200,
   "data": [
      {
         "channel_id": 5,
         "last_message_id": 13,
         "channel_type": 1,
         "channel_picture": "group pofile photo link",
         "is_pinned": 0,
         "message_text": "sunday probably",  --- last message sent text
         "date_time": "2020-09-19T06:44:37.000Z",
         "is_deleted": 0,
         "last_sent_by_id": 2,
         "last_sent_by_full_name": "user2",  ---last message user's username
         "label": "himachal lads",
         "unreadCount": 4 --- 4 unread messages, 2 from user1 , 2 from user 2
      }
   ]
   }
   ```
   * soon as the user3 reads all the messages , the last_read_msg_id is updated in **user_channels** for user3 - ch5 entry .
   * and the process continues.

### ENHANCEMENTS
 * deleted texts by using existing **is_deleted** column in **messages** table.
 * pinned channels by using existing **is_pinned** column in **user_channels**.

 ### FOLDER STRUCTURE,LIBRARIES AND HOW TO USE
 * the complete structure has been built using Node.js, mysql and other libs like bluebird, underscore, joi etc.
 * modules -> user contains the parent API for fetching user channels
 * modules -> database contains mysql connectivity file
 * routes -> commonfunction.js contains API request body and user access token authentication
 * to run first import chatmodel.sql file -> npm install -> node server.js

### POSTMAN
[link](https://www.getpostman.com/collections/60914efab30f929c8bfd) 

## Authors

* **Vikrant Sandal** 

Read

