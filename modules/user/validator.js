const Joi                           = require('joi');
const common                        = require('../../routes/commonfunction');
const apiReferenceModule            = 'user';

const getMessages = (req, res, next) => {
    console.log('inside get messagesssssss-->>', req.body);
  const schema = Joi.object().keys({
      access_token          : Joi.string().required()
  });

  if(common.validateFields(req.body, res, schema)) {
      req.body.apiReference = {
          module  : apiReferenceModule,
          api     : "getMessages"
      };
      req.body.lang = req.headers['content-language'] || 'en';
      common.userAuthentication(req, res, next);
  }
};

exports.getMessages = getMessages;