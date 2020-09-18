const Promise = require('bluebird');
const _ = require('underscore');
const user = require('./service');
const logging = require('../../routes/logging');

/**
 * getmessages function works in following steps
 * 1 - fetches latest message details  in all channels (+ group converstations name,photo etc  (channel_type = 1))
 * 2 - fetches the other participant of channel if channel is one to one (channel_type = 0) , so as to show the name of the person one is talking to.
 * 3 - fetches unread count of every channel for user
 * 4 - sends data in a comprehensive manner
 */

const getMessages = (payload) => {
  return new Promise((resolve, reject) => {
    Promise.coroutine(function* () {
      let conversations = yield user.getConversations(payload.apiReference, payload), user_id = payload.userInfo.user_id;
      logging.log('conversation---->>>', conversations);

      if (_.isEmpty(conversations)) return conversations;
      let oneToneChannels = _.pluck(_.where(conversations, { channel_type: 0 }), 'channel_id'), allChannels = _.pluck(conversations, 'channel_id');
      logging.log('one to one---->>>', oneToneChannels, '=--------->', allChannels);
      
      let tasks = [];
      tasks.push(user.getUsersIn1to1chanelExceptUser(payload.apiReference, { oneToneChannels, user_id }));
      tasks.push(user.getUnreadCountOfuserForAllChannels(payload.apiReference, { allChannels, user_id }));
      let result = yield Promise.all(tasks);

      logging.log('Result[0]----->', JSON.stringify(result[0]));
      logging.log('Result[1]----->', JSON.stringify(result[1]));

      let usersInChannelsMap = result[0], unreadCountMap = result[1];

      for (let conv of conversations) {
        conv.unreadCount = 0;
        if (conv.channel_type == 0 && usersInChannelsMap[conv.channel_id]) {
          conv.label = usersInChannelsMap[conv.channel_id].username;
          conv.channel_picture = usersInChannelsMap[conv.channel_id].channel_picture;
        }
        if (unreadCountMap[conv.channel_id]) {
          conv.unreadCount = unreadCountMap[conv.channel_id].unread_count
        }

      }
      logging.log('FINAL CHANNELS---->', JSON.stringify(conversations));
      return conversations
    })().then((data) => {
      resolve(data);
    }, () => {
      reject();
    });
  });
}

exports.getMessages = getMessages