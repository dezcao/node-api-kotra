const Joi = require('joi');

const shopSchema = Joi.object({
  shop_nm: Joi.string().required(),
  ceo_nm: Joi.string().required(),
  biz_num: Joi.string().required(),
  user_id: Joi.string().required(),
  svc_type: Joi.any().required(),
  phone: Joi.string().allow('').replace(/-/g, '').default(null),
  address: Joi.string().allow('').default(null),
  address_detail: Joi.string().allow('').default(null),
  shop_summery: Joi.string().allow('').default(null),
  homepage: Joi.string().allow('').default(null),
  longitude: Joi.string().allow('', null).default(null),
  latitude: Joi.string().allow('', null).default(null),
  biz_type: Joi.string().allow('', null).default(null)
  
});
const shopUpdateSchema = Joi.object({
  svc_type: Joi.any().required(),
  shop_nm: Joi.string().allow('', null).default(null),
  ceo_nm: Joi.string().allow('', null).default(null),
  shop_id: Joi.string().allow('', null).default(null),
  phone: Joi.string().allow('', null).replace(/-/g, '').default(null),
  address: Joi.string().allow('', null).default(null),
  address_detail: Joi.string().allow('', null).default(null),
  shop_desc: Joi.string().allow('', null).default(null),
  shop_summery: Joi.string().allow('', null).default(null),
  bank_cd: Joi.string().allow('', null).default(null),
  bank_num: Joi.string().allow('', null).default(null),
  homepage: Joi.string().allow('', null).default(null),
  add_svc_id: Joi.any().allow('', null).default(null),
  longitude: Joi.string().allow('', null).default(null),
  latitude: Joi.string().allow('', null).default(null),
  biz_type: Joi.string().allow('', null).default(null)
});
const shopAssetSchema = Joi.object({
  shop_asset_id: Joi.any().required(),
  main_asset_id: Joi.string().allow('').default(null),
  svc_type: Joi.string().required().default(null),
  shop_id: Joi.string().allow('').default(null)
});

const addShopSchema = Joi.object({
  shop_nm: Joi.string().required(),
  ceo_nm: Joi.string().required(),
  biz_num: Joi.string().required(),
  user_id: Joi.string().required(),
  phone: Joi.string().allow('').replace(/-/g, '').default(null),
  address: Joi.string().allow('').default(null),
  address_detail: Joi.string().allow('').default(null),
  shop_summery: Joi.string().allow('').default(null),
  shop_desc: Joi.string().allow('').default(null),
  homepage: Joi.string().allow('').default(null),
  longitude: Joi.string().allow('', null).default(null),
  latitude: Joi.string().allow('', null).default(null),
  svc_type: Joi.any().allow('', null).default(null)
});

exports.shopSchema = shopSchema;
exports.shopUpdateSchema = shopUpdateSchema;
exports.shopAssetSchema = shopAssetSchema;
exports.addShopSchema = addShopSchema