var express = require('express');
var bodyParser = require('body-parser')
var app = express();
var http = require('http')
var logging = require('./routes/logging');
app.use(express.static(__dirname));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }))
global.app = app;

require('./modules/database/service');
require('./modules/user');

let port = 3008;
var startServer = http.createServer(app).listen(port, () => {
    logging.log('into startServer')
});

process.on("uncaughtException", function (err) {
    logging.log("uncaughtException", err);
    startServer.close();
    try {
        connection.end(function (errPoll) {
            if (errPoll) {
                logging.log("errPoll inside")
            }
            logging.log("end poll")
        })
    } catch (error) {
        logging.log("errPoll", error)
    }
    setTimeout(function () {
        process.exit(0);
    }, 15000);
})