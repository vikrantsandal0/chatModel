const logging = require('../../routes/logging');
const mysql = require('mysql');


const db_config = {
    host: 'localhost',
    connectionLimit: 10,
    user: "root",
    password: 'password',
    database: 'chatmodel',
    multipleStatements: true
};

const initializeConnectionPool = (db_config)=> {
    let numConnectionsInPool = 0;
    logging.log('CALLING INITIALIZE POOL--->>>');
    let conn = mysql.createPool(db_config);
    console.log('conn------->', conn);
    conn.on('connection', (connection)=> {
        numConnectionsInPool++;
        logging.log('NUMBER OF CONNECTION IN POOL : ', numConnectionsInPool);
    });
    conn.on('release', function (connection) {
        logging.log('Connection %d released', connection.threadId);
    });
    return conn;
}
connection = initializeConnectionPool(db_config);

const mysqlQueryPromise = (apiReference, event, queryString, params) => {
    return new Promise((resolve, reject) => {
        if (!apiReference) {
            apiReference = {
                module: "databaseService",
                api: "mysqlQueryPromise"
            }
        }
        let query = connection.query(queryString, params, (sqlError, sqlResult) => {
            logging.log2(apiReference, {
                EVENT: "Executing query " + event, QUERY: query.sql, SQL_ERROR: sqlError, SQL_RESULT: sqlResult,
                SQL_RESULT_LENGTH: sqlResult && sqlResult.length
            });
            if (sqlError || !sqlResult) {
                if (sqlError) {
                    if (sqlError.code === 'ER_LOCK_DEADLOCK' || sqlError.code === 'ER_QUERY_INTERRUPTED') {
                        setTimeout(module.exports.mysqlQueryPromise.bind(null, apiReference, event, queryString, params), 50);
                    } else {
                        return reject({ ERROR: sqlError, QUERY: query.sql, EVENT: event });
                    }
                }
            }
            return resolve(sqlResult);
        });
    });
}
exports.mysqlQueryPromise = mysqlQueryPromise;
