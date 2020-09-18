const user                         = require('./controller');

const getMessages = (req, res) => {
    user.getMessages(req.body).then((data) => {
        return res.send(JSON.stringify({
            "message": 'Successful',
            "status": 200,
            "data": data
        }));
    }, (error) => {
        return res.send({
            "message": 'Some error occurred while executing.',
            "status": 400,
            "data": {}
        });
    });
}

exports.getMessages = getMessages