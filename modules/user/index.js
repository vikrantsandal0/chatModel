/**
 * Created by vikrant sandal on 18/09/2020.
 */
'use strict';
const validator = require('./validator');
const routeHandler = require('./routehandler');


app.post('/user/getMessages', validator.getMessages, routeHandler.getMessages);