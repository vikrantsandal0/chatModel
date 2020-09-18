const Joi = require('joi');
const logging = require('./logging');
const _ = require('underscore');
const Promise = require('bluebird');
const database = require('./../modules/database/service');

const validateFields = (req, res, schema)=> {
  const validation = Joi.validate(req, schema);
  if (validation.error) {
    let errorName = validation.error.name;
    let errorReason = validation.error.details !== undefined ? validation.error.details[0].message : 'Parameter missing or parameter type is wrong';
    let response = {
      "message": 'Insufficient information was supplied. Please check and try again',
      "status": 100,
      "data": {}
    };
    logging.log("validateFields", errorReason)
    res.send(JSON.stringify(response));
    return false;
  }
  return true;
};

const userAuthentication = (req, res, next) => {
  Promise.coroutine(function* () {
    let sql = `SELECT user_id FROM users WHERE access_token = '${req.body.access_token}'  LIMIT 1 `;
    let result = yield database.mysqlQueryPromise(req.body.apiReference, 'Get user data', sql, []);
    logging.log('result-->', result)
    if (_.isEmpty(result)) {
      let response = {
        "message": 'Session expired. Please logout and login again.',
        "status": 101,
        "data": {}
      };
      return res.send(JSON.stringify(response));
    }
    return result;
  })().then((data) => {
    req.body.userInfo = data[0];
    next();
  }, (error) => {
    logging.log('error-->>userAuthentication', error)
  });
}
const createHashMap = (uniqueKey, array)=>{
  const hashObject = {};
  array.forEach(elem => {
    hashObject[elem[uniqueKey]] = elem;
  });
  return hashObject;
}

exports.validateFields = validateFields;
exports.userAuthentication = userAuthentication;
exports.createHashMap = createHashMap;