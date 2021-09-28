const Joi = require('joi');

const userSchema = Joi.object({
  email: Joi.string().email().trim().required(),
  user_pw: Joi.string().min(8).trim().required(),
  auth_num: Joi.string().trim().required(),
  user_nm: Joi.string().required().trim(),
  mobile: Joi.string().required().replace(/-/g, '').trim(),
  address: Joi.string().allow('').default(null),
  address_detail: Joi.string().allow('').default(null),
  shop_id: Joi.string().allow('').default(null)
});
const userLoginSchema = Joi.object({
  username: Joi.string().trim().required(),
  // email: Joi.string().email().trim().required(),
  user_pw: Joi.string().min(8).trim().required(),
  keep_login: Joi.string().allow('').default(null),
  model_nm: Joi.string().allow('').default(null)
});
const userFindEmailSchema = Joi.object({
  user_nm: Joi.string().trim().required(),
  mobile: Joi.string().replace(/-/g, '').trim().required()
});
const userChangePasswordSchema = Joi.object({
  email: Joi.string().email().trim().required(),
  new_user_pw: Joi.string().min(8).trim().required(),
  auth_num: Joi.string().trim().required()
});

exports.userSchema = userSchema;
exports.userLoginSchema = userLoginSchema;
exports.userFindEmailSchema = userFindEmailSchema;
exports.userChangePasswordSchema = userChangePasswordSchema;
