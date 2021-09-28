/**
  Copyright (c) 2019 asdaisy
  Licensed under the Apache License, Version 2.0 (the “License”)

  You may obtain a copy of the License at asdaisy@hanmail.net
  */
const log = require('../lib/util').log('ROUTE:USER');
const util = require('../lib/util');
const redis = require('../lib/redis');
const response = require('../lib/response');
const config = require('../conf/config');
const axios = require('axios').default;
const {
  userSchema,
  userLoginSchema,
  userFindEmailSchema,
  userChangePasswordSchema
} = require('../validator/userValidator');

/**
 * 사용자 로그인
 * @route post /user/login
 * @param {string} email* - 사용자 이메일
 * @param {string} user_pw* - 사용자 로그인 비밀번호
 * @param {string} keep_login - 로그인 유지 플래그
 * @param {string} model_nm - 로그인 디바이스 이름
 */
const loginUser = async function (req, res) {
  // validate parameter value
  let { error, value } = userLoginSchema.validate(req.body);
  if (error) {
    res.json(response(401, error));
    return;
  }

  // db에서 사용자 정보르 확인한다. -- 현재 디비가 없다.
  // const myPool = req.app.get('pool');
  // let re = null;
  // value.user_pw = util.sha256Hash(value.user_pw);
  // try {
  //   re = await myPool.doQueryFile('user.sql', {
  //     sql_id: 'LOGIN_USER',
  //     ...value
  //   });
  // } catch (err) {
  //   log(err);
  //   res.json(response(500));
  //   return;
  // }
  // if (!re || re.length === 0) {
  //   res.json(response(402));
  //   return;
  // }
  let re = {
    user_id: 'no_databae_dummy',
    username: '레디스만 넣은 테스트유저',
    role: 'admin'
  }
  // -- 디비가 없다.
  
  let auth_token = util.mk_rand62(64).toLowerCase();
  let ip = req.ip ? req.ip.replace('::ffff:', '') : req.ip;
  let ipObj = util.getNationByIp(ip);
  let nation_id = ipObj ? ipObj.isoCode : null;
  let { browser, os, version, source } = req.useragent;
  let { model_nm } = value;
  let { user_id } = re;
  try {
    // 14400 == 4시간 = 60*60*4
    redis.set(`user:${auth_token}`, re, config.session_timeout); // 60 * 30 * 12 * 12 -- 너무 기니까 짧게하자.
    // await myPool.doQueryFile('user.sql', {
    //   sql_id: 'INSERT_LOGIN_HISTORY',
    //   user_id,
    //   model_nm,
    //   os,
    //   browser,
    //   version,
    //   ip,
    //   nation_id
    // });
  } catch (err) {
    log(err);
    res.json(response(501));
    return;
  }
  res.json(response(200, { auth_token }));
};

/**
 * 사용자 등록
 * @route post /user/signup
 * @param {string} email* - 사용자 이메일
 * @param {string} user_pw* - 사용자 로그인 비밀번호
 * @param {string} user_nm* - 사용자 이름
 * @param {string} mobile* - 사용자 폰번호
 * @param {string} address - 사용자 주소
 * @param {string} address_detail - 사용자 상세주소
 * @param {string} shop_id - 상점아이디
 */
const signupUser = async function (req, res) {
  // validate parameter value
  let { error, value } = userSchema.validate(req.body);
  if (error) {
    res.json(response(401, error));
    return;
  }
  const myPool = req.app.get('pool');
  let re = null;
  let user_id = util.mk_rand62(32).toLowerCase();

  value.user_pw = util.sha256Hash(value.user_pw);
  value.user_id = user_id;

  let email_auth = await redis.get('email:' + value.auth_num);
  if (!email_auth || value.email !== email_auth.email) {
    res.json(response(407));
    return;
  }

  try {
    re = await myPool.doQueryFile('user.sql', {
      sql_id: 'SIGNUP_USER',
      ...value
    });
  } catch (err) {
    log(err);
    res.json(response(500));
    return;
  }
  if (re.affectedRows && re.affectedRows === 1) {
    // if (value.shop_id) { // 사원으로 등록
    //   value.user_level = 'ul02';
    //   try {
    //     re = await myPool.doQueryFile('shop.sql', { sql_id: 'REGISTER_USER_SHOP', ...value });
    //   } catch (err) {
    //     log(err);
    //     res.json(response(500));
    //     return
    //   }
    // }
    res.json(response(200, { user_id }));
  } else {
    res.json(response(403));
  }
};

/**
 * 사용자 정보 조회
 * @route get /user/info
 * @header {string} auth_token - 사용자 인증토큰
 */
const inquireUser = async function (req, res) {
  const auth_token = req.headers.auth_token;
  const myPool = req.app.get('pool');
  let user = null;
  let { shop_id = null } = req.query;
  let user_id = req.user_id;
  try {
    if (shop_id) {
      user = (
        await myPool.doQueryFile('user.sql', {
          sql_id: 'INQUIRE_USER',
          shop_id,
          user_id
        })
      )[0];
    } else {
      user = await redis.get(`user:${auth_token}`);
    }
  } catch (err) {
    log(err);
    res.json(response(501));
    return;
  }
  res.json(response(200, user));
};

/**
 * 사용자 로그아웃
 * @route get /user/logout
 * @header {string} auth_token - 사용자 인증토큰
 */
const logoutUser = async function (req, res) {
  const auth_token = req.headers.auth_token;
  try {
    redis.del(`user:${auth_token}`);
  } catch (err) {
    log(err);
    res.json(response(501));
    return;
  }
  res.json(response(200));
};

/**
 * 사용자 이름 및 폰번호를 이용하여 이메일 찾기
 * @route get /user/findEmail
 * @param {string} user_nm* - 사용자 이름
 * @param {string} mobile* - 사용자 폰번호
 */
const findUserEmail = async function (req, res) {
  // validate parameter value
  let { error, value } = userFindEmailSchema.validate(req.query);
  if (error) {
    res.json(response(401, error));
    return;
  }
  const myPool = req.app.get('pool');
  let re = null;
  try {
    re = (
      await myPool.doQueryFile('user.sql', {
        sql_id: 'FIND_USER_EMAIL',
        ...value
      })
    )[0];
    if (re) {
      re.email = util.maskingEmail(re.email);
      re.user_nm = util.maskingStr(re.user_nm);
      re.mobile = util.maskingStr(re.mobile);
      res.json(response(200, re));
    } else {
      res.json(response(411));
    }
  } catch (err) {
    log(err);
    res.json(response(500));
  }
};

/**
 * 사용자의 상점 리스트 조회
 * @route get /user/shoplist
 * @header {string} auth_token - 사용자 인증토큰
 */
const inquireUserShopList = async function (req, res) {
  const myPool = req.app.get('pool');
  let re = null;
  let { user_id } = req;
  try {
    re = await myPool.doQueryFile('user.sql', {
      sql_id: 'USER_SHOP_LIST',
      user_id
    });
  } catch (err) {
    log(err);
    res.json(response(500));
    return;
  }
  res.json(response(200, re));
};

/**
 * 해당 상점의 사용자 리스트 조회
 * @route get /user/list
 * @header {string} auth_token - 사용자 인증토큰
 * @param {string} shop_id - 상점아이디
 */
const inquireUserList = async function (req, res) {
  const { user_id } = req;
  let shop_id = util.isNull(req.query.shop_id)
    ? req.shop_id
    : req.query.shop_id;
  const myPool = req.app.get('pool');
  let re = null;
  try {
    re = await myPool.doQueryFile('user.sql', { sql_id: 'USER_LIST', shop_id });
  } catch (err) {
    log(err);
    res.json(response(500));
    return;
  }
  res.json(response(200, re));
};

/**
 * 유저 - 상점 연결 정보 등록
 * @route get /user/registerUserShop
 * @header {string} auth_token - 사용자 인증토큰
 * @param {string} shop_id - 상점 아이디
 * @param {string} user_id - 유저 아이디
 */
const registerUserShop = async function (req, res) {
  const myPool = req.app.get('pool');
  let { user_id = null, shop_id = null, user_level = null } = req.body;
  // let user_level = 'ul02';
  if (!user_id || !shop_id) {
    res.json(response(401));
    return;
  }
  let re = null;
  let user_status = 'us00';

  if (user_level === 'ul00') {
    user_status = 'us01';
  }

  try {
    re = await myPool.doQueryFile('shop.sql', {
      sql_id: 'REGISTER_USER_SHOP',
      user_id,
      shop_id,
      user_status,
      user_level
    });
  } catch (err) {
    console.log(err);
    log(err);
    res.json(response(500));
    return;
  }
  res.json(response(200, re));
};

/**
 * 사용자 비밀번호 변경
 * @route post /user/signup
 * @param {string} email* - 사용자 이메일
 * @param {string} new_user_pw* - 사용자 신규 비밀번호
 * @param {string} auth_num* - 인증번호
 */
const changeUserPassword = async function (req, res) {
  // validate parameter value
  let { error, value } = userChangePasswordSchema.validate(req.body);
  if (error) {
    res.json(response(401, error));
    return;
  }
  const myPool = req.app.get('pool');
  let re = null;
  try {
    let email_auth = await redis.get('email:' + value.auth_num);
    if (!email_auth || value.email !== email_auth.email) {
      res.json(response(407));
      return;
    }
    value.new_user_pw = util.sha256Hash(value.new_user_pw);
    re = await myPool.doQueryFile('user.sql', {
      sql_id: 'CHANGE_USER_PASSWORD',
      ...value
    });
  } catch (err) {
    log(err);
    res.json(response(500));
    return;
  }
  if (re.affectedRows && re.affectedRows === 1) {
    res.json(response(200));
  } else {
    res.json(response(416));
  }
};

exports.loginUser = loginUser;
exports.signupUser = signupUser;
exports.inquireUser = inquireUser;
exports.logoutUser = logoutUser;
exports.findUserEmail = findUserEmail;
exports.inquireUserShopList = inquireUserShopList;
exports.inquireUserList = inquireUserList;
exports.registerUserShop = registerUserShop;
exports.changeUserPassword = changeUserPassword;
