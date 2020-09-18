const moment = require('moment');

exports.log = function () {
      console.log.apply(console, arguments);
};

exports.log2 = function (apiReference, log) {
      try {
          log = JSON.stringify(log);
          console.log("-->" + moment(new Date()).format('YYYY-MM-DD hh:mm:ss.SSS') + " :----: " +
              apiReference.module + " :=: " + apiReference.api + " :=: " + log);
      } catch  (e) {

      }
  
};