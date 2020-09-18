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
**messages** tables, This was done to reduce the complexity of sql query(**getConversations**)  which brings all user chanels last msgs by maintaining 1 to 1 relationship between chanels and last msg sent which otherwise for a large data set could lead to increase in response time, for more refer to the function *getConversations* in service.js
   * message_id - last msg sent Id in a channel,updated for every new msg sent by user in a channel
   * channel_id  - channel (unique key) corresponding to which the latest msg is stored


### API REQUEST - RESPONSE EXAMPLES

* SCENARIO - ONE TO ONE CONVERSATION 
   * user1 creates a channel to talk to user2 and sends a message.
   * new channel id 4 created in table - **channels** (ch)
   * two new rows inserted in  **user_channels** table, user1 - ch4 AND user2 - ch4
   * message_id is created in **messages**, user1 - ch4 - message text and copied in table **channel_last_message** as        
     channels latest message (message_id , channel_id) .
   * last_read_msg_id is updated to newly created message_id in **user_channels** corresponding to user1 - ch4 entry.

   * **API results for first page for user1 when user2 hasnt replied yet and channel has a single messsage**
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
   **channel_last_message** 


   * **API results for first page for user1 when user2 has replied with 2 new messages which user1 hasnt seen yet**
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




Read

