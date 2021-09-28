const Joi = require('joi');

const reservationResgisterSchema = Joi.object({
  svc_id: Joi.string().required(),
  shop_id: Joi.string().required(),
  member_id: Joi.string().required(),
  svc_type: Joi.string().required(),
  order_num: Joi.string().required(),
  pet_id: Joi.string().allow('').default(null),
  user_id: Joi.string().allow('').default(null),
  reserv_dt: Joi.string().required(),
  reserv_edt: Joi.string().allow('').default(null),
  reserv_stm: Joi.string().allow('').default(null),
  reserv_etm: Joi.string().allow('').default(null),
  reserv_status: Joi.string().allow('').default('rs01'),
  tot_price: Joi.string().allow('').default(null),
  deposit: Joi.string().required(),
  deposit_method: Joi.string().allow('').default(null),
  discount_amt: Joi.string().allow('').default(null),
  pay_price: Joi.string().allow('').default(null),
  commission: Joi.string().allow('').default(null),
  reserv_memo: Joi.string().allow('').default(null),
  confirm_dt: Joi.string().allow('').default(null),
  cancel_dt: Joi.string().allow('').default(null),
  cancel_memo: Joi.string().allow('').default(null),
  reserv_channel: Joi.string().allow('').default(null),
  reserv_option: Joi.array().allow('').default(null)
});

const reservOptionUpdateSchema = Joi.object({
  reserv_option_id: Joi.string().required(),
  reserv_id: Joi.string().required(),
  svc_id: Joi.string().allow('').default(null),
  shop_id: Joi.string().allow('').default(null),
  member_id: Joi.string().allow('').default(null),
  option_nm: Joi.string().allow('').default(null),
  option_price: Joi.string().allow('').default(null)
});

const reservationUpdateSchema = Joi.object({
  shop_id: Joi.string().required(),
  order_num: Joi.string().required(),
  svc_id: Joi.string().required(),
  member_id: Joi.string().required(),
  svc_type: Joi.string().allow('').default(null),
  pet_id: Joi.string().allow('').default(null),
  user_id: Joi.string().allow('').default(null),
  reserv_dt: Joi.string().allow('').default(null),
  reserv_edt: Joi.string().allow('').default(null),
  reserv_stm: Joi.string().allow('').default(null),
  reserv_etm: Joi.string().allow('').default(null),
  reserv_status: Joi.string().allow('').default(null),
  tot_price: Joi.string().allow('').default(null),
  deposit: Joi.string().allow('').default(null),
  deposit_method: Joi.string().allow('').default(null),
  discount_amt: Joi.string().allow('').default(null),
  pay_price: Joi.string().allow('').default(null),
  commission: Joi.string().allow('').default(null),
  reserv_memo: Joi.string().allow('').default(null),
  confirm_dt: Joi.string().allow('').default(null),
  cancel_dt: Joi.string().allow('').default(null),
  cancel_memo: Joi.string().allow('').default(null),
  reserv_channel: Joi.string().allow('').default(null),
  reserv_option: Joi.array().allow('').default(null)
});

const reservationPortfolioResgisterSchema = Joi.object({
  reserv_id: Joi.string().required(),
  svc_id: Joi.string().required(),
  shop_id: Joi.string().required(),
  user_id: Joi.string().required(),
  member_id: Joi.string().required(),
  pet_id: Joi.string().allow('').default(null),
  port_post: Joi.string().allow('').default(null),
  port_asset: Joi.array().allow('').default(null)
});

const reservationPortfolioUpdateSchema = Joi.object({
  user_id: Joi.string().required(),
  port_post: Joi.string().allow('').default(null),
  port_asset: Joi.array().allow('').default(null)
});

exports.reservationResgisterSchema = reservationResgisterSchema;
exports.reservOptionUpdateSchema = reservOptionUpdateSchema;
exports.reservationUpdateSchema = reservationUpdateSchema;
exports.reservationPortfolioResgisterSchema = reservationPortfolioResgisterSchema;
exports.reservationPortfolioUpdateSchema = reservationPortfolioUpdateSchema;
