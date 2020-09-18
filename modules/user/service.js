const Promise = require('bluebird');
const moment = require('moment');
const _ = require('underscore');
const logging = require('../../routes/logging');
const database = require('../database/service');
const common = require('../../routes/commonfunction');



const getConversations = (apiReference, payload) => {
  return new Promise((resolve, reject) => {
    Promise.coroutine(function* () {
      let sql = `SELECT utc.channel_id, 
          m.message_id AS last_message_id,
          c.channel_type,
          c.channel_picture,
          utc.is_pinned,
          m.message_text,
          m.creation_datetime as date_time,
          m.is_deleted ,
          u.user_id AS last_sent_by_id,
          u.username AS last_sent_by_full_name,
          (CASE WHEN c.channel_type = 1 THEN c.channel_name ELSE "" END) AS label
      FROM
         user_channels utc
          LEFT JOIN
          channels c ON c.channel_id = utc.channel_id AND c.channel_status = 1 
          LEFT JOIN
          channel_last_message cl ON cl.channel_id = c.channel_id 
          LEFT JOIN  
          messages m ON m.message_id = cl.message_id 
          LEFT JOIN
          users u ON u.user_id = m.user_id
      WHERE
          utc.user_id = ${payload.userInfo.user_id} AND m.message_id >= utc.last_read_msg_id
      ORDER BY  utc.is_pinned DESC, m.message_id DESC `;
      let result = yield database.mysqlQueryPromise(apiReference, 'get all channels', sql, []);
      return result;
    })().then((data) => {
      resolve(data);
    }, (error) => {
      logging.log2(apiReference, { ERROR: error, DATA: {} });
      reject(error);
    });
  });
}

const getUsersIn1to1chanelExceptUser = (apiReference, payload) => {
  return new Promise((resolve, reject) => {
    Promise.coroutine(function* () {
      if(_.isEmpty(payload.oneToneChannels))return {};
      let sql = `SELECT
            utc.channel_id, utc.user_id, utc.created_at, u.username, u.profile_photo as channel_picture, u.is_active
            FROM
            user_channels utc
            join users u
            on u.user_id = utc.user_id
            WHERE
            utc.channel_id in (?) AND utc.user_id not in (?) 
            ORDER BY utc.user_channel_id ` ;
      return yield database.mysqlQueryPromise(apiReference, 'get all users in one to one chanel except user_id', sql, [payload.oneToneChannels, payload.user_id]);
    })().then((data) => {
      if(_.isEmpty(data))return resolve({});
      let hashMap = common.createHashMap('channel_id', data);
      resolve(hashMap);
    }, (error) => {
      logging.log2(apiReference, { ERROR: error, DATA: {} });
      reject(error);
    });
  });
}
const getUnreadCountOfuserForAllChannels = (apiReference, payload) => {
  return new Promise((resolve, reject) => {
    Promise.coroutine(function* () {
      if (_.isEmpty(payload.allChannels)) return resolve({});
      let sql = `SELECT  utc.channel_id, COUNT(*) AS unread_count
        FROM
        user_channels  utc
                 LEFT JOIN
             messages m ON utc.channel_id = m.channel_id
        WHERE
            utc.channel_id IN (?) AND utc.user_id = ? AND m.message_id  > utc.last_read_msg_id 
        GROUP BY utc.channel_id ` ;
      return yield database.mysqlQueryPromise(apiReference, 'get all users in one to one chanel except user_id', sql, [payload.allChannels, payload.user_id]);
    })().then((data) => {
      let hashMap = common.createHashMap('channel_id', data);
      resolve(hashMap);
    }, (error) => {
      logging.log2(apiReference, { ERROR: error, DATA: {} });
      reject(error);
    });
  });
}




exports.getConversations = getConversations;
exports.getUsersIn1to1chanelExceptUser = getUsersIn1to1chanelExceptUser;
exports.getUnreadCountOfuserForAllChannels = getUnreadCountOfuserForAllChannels;