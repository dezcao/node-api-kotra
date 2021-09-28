const Joi = require('joi');

const memberSchema = Joi.object({
  shop_id: Joi.string().allow('',null).empty('').default(null),
  email: Joi.string().email().trim().required(),
  member_nm: Joi.string().required(),
  mobile: Joi.string().required().replace(/-/g, ''),
  member_pw: Joi.string().allow('',null).empty('').default(null),
  phone: Joi.string().allow('', null).replace(/-/g, '').empty('').default(null),
  address: Joi.string().allow('', null).empty('').default(null),
  address_detail: Joi.string().allow('', null).empty('').default(null),
  sex: Joi.string().pattern(/^[M|F]$/i).empty('').default(null),
  birthday: Joi.string().allow('', null).empty('').default(null),
  join_channel: Joi.string().allow('', null).empty('').default(null),
  push_yn: Joi.string().allow('', null).empty('').default(null),
  email_noti_yn: Joi.string().allow('', null).empty('').default(null)
});

const updateMemberSchema = Joi.object({
  shop_id: Joi.string().allow('',null).empty('').default(null),
  member_id: Joi.string().required(),
  member_nm: Joi.string().allow('', null).empty('').default(null),
  mobile: Joi.string().replace(/-/g, '').allow('', null).empty('').default(null),
  phone: Joi.string().allow('', null).replace(/-/g, '').empty('').default(null),
  sex: Joi.string().pattern(/^[M|F]$/i).allow('', null).empty('').default(null),
  birthday: Joi.string().allow('', null).empty('').default(null),
  address: Joi.string().allow('', null).empty('').default(null),
  address_detail: Joi.string().allow('', null).empty('').default(null),
  join_channel: Joi.string().allow('', null).empty('').default(null),
  push_yn: Joi.string().allow('', null).empty('').default(null),
  email_noti_yn: Joi.string().allow('', null).empty('').default(null)
});

const petSchema = Joi.object({
  shop_id: Joi.string().allow('',null).empty('').default(null),
  member_id: Joi.string().required(),
  pet_nm: Joi.string().required(),
  profile_asset_id: Joi.string().allow('', null).empty('').default(null),
  pet_type: Joi.string().required(),
  breed_id: Joi.string().allow('', null).empty('').default(null),
  birthday: Joi.string().allow('', null).empty('').default(null),
  sex: Joi.string().pattern(/^[M|F]$/i).empty('').default(null),
  weight: Joi.string().allow('', null).empty('').default(null),
  neutralization_yn: Joi.string().pattern(/^[Y|N]$/i).allow('', null).empty('').default(null),
  old_yn: Joi.string().pattern(/^[Y|N]$/i).allow('', null).empty('').default(null),
  memo: Joi.string().allow('', null).empty('').default(null)
});

const updatePetSchema = Joi.object({
  shop_id: Joi.string().allow('',null).empty('').default(null),
  pet_id: Joi.string().required(),
  pet_nm: Joi.string().allow('', null).empty('').default(null),
  pet_type: Joi.string().allow('', null).empty('').default(null),
  breed_id: Joi.string().allow('', null).empty('').default(null),
  birthday: Joi.string().allow('', null).empty('').default(null),
  sex: Joi.string().pattern(/^[M|F]$/i).allow('', null).empty('').default(null),
  weight: Joi.string().allow('', null).empty('').default(null),
  profile_asset_id: Joi.string().allow('', null).empty('').default(null),
  neutralization_yn: Joi.string().pattern(/^[Y|N]$/i).allow('', null).empty('').default(null),
  old_yn: Joi.string().pattern(/^[Y|N]$/i).allow('', null).empty('').default(null),
  memo: Joi.string().allow('', null).empty('').default(null)
});

exports.memberSchema = memberSchema;
exports.petSchema = petSchema;
exports.updateMemberSchema = updateMemberSchema;
exports.updatePetSchema = updatePetSchema