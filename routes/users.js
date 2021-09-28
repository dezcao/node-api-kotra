/**
  Copyright (c) 2019 asdaisy
  Licensed under the Apache License, Version 2.0 (the “License”)
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at asdaisy@hanmail.net
 */
const log = require('../lib/util').log('ROUTE:USERS');
const util = require('../lib/util');
const redis = require('../lib/redis');
const response = require('../lib/response');
const { userSchema } = require('../validator/userValidator');
const passport = require('passport')
const KakaoStrategy = require('passport-kakao').Strategy;
const axios = require('axios').default;
const ExcelJS = require('exceljs');

/**
 * get user info
 * @route get /user/:user_id
 * @param {string} user_id - 사용자 아이디
 */
const user = async function (req, res) {
  // validate parameter value
  let { error, value } = userSchema.validate(req.params);
  if (error) {
    log(error);
    res.json(response(401));
    return
  }
  const myPool = req.app.get('pool');
  console.log(req.cookies);
  let { user_id } = value;
  let re = null;
  try {
    re = await myPool.doQueryFile('users.sql', { sql_id: 'USER_INFO', user_id });
  } catch (err) {
    log(err);
    res.json(response(500));
    return
  }
  res.json(response(200, re));
};

/**
 * get user info
 * @route get /user/social/kakao
 * @param {string} user_id - 사용자 아이디
 */

const auth_kakao = passport.authenticate('kakao');

const kakao_callback = function (req, res, next) {
  passport.authenticate('kakao', function (err, user, info) {
    console.log(user);
    if (err) { return next(err); }
    if (!user) { 
      // 유저 없음.
      console.log('1888888888888888888888888888888')
      return res.redirect('/auth/kakao'); 
    }
    console.log('localhost : ', req.get('host'));
    res.cookie('accessToken', user.accessToken);
    // response.writeHead(200, {
    //   'Set-Cookie':[`accessToken=${user.accessToken}; Secure`,
    //   'HttpOnly=HttpOnly; HttpOnly']         
    // });


    res.json(user.profile);
    // res.redirect('/users')
  })(req, res, next);
};

const logout = async function (req, res, next) {
  // 카카오계정과 함께 로그아웃
  console.log(req.params.user_id);

  // case1. adminkey + user_id
  let url = `https://kapi.kakao.com/v1/user/unlink`;
  let rs = await axios({
    method: 'post', // you can set what request you want to be
    url: url,
    headers: {
      Authorization: 'KakaoAK ' + process.env.KAKAO_ADMIN_KEY
    },
    params: {
      'target_id_type': 'user_id',
      'target_id': req.params.user_id
    }

  })
  // case2. accesstoken logout redirect
  // let rs = await axios({
  //   method: 'post', //you can set what request you want to be
  //   url: url,
  //   // data: {id: varID},
  //   headers: {
  //     Authorization: 'Bearer ' + 'RvgZMMseVM1I4iy1ZrK5Vqz40P2pC1nPQ7M5pQopb7gAAAF5iOOA9g'
  //   }
  // })
  
  console.log('disconnect: ', rs);

  return res.redirect('/');
};

/**
 * get user list
 * @route get /users
 * @param {string} user_id - 사용자 아이디
 */
const users = async function (req, res) {
  let { search_field, search_value } = req.query;
  const myPool = req.app.get('pool');
  let re = null;
  try {
    re = await myPool.doQueryFile('users.sql', { sql_id: 'USER_LIST', search_field, search_value });
  } catch (err) {
    log(err);
    res.json(response(500));
    return
  }
  res.json(response(200, re));
};

const login = async function (req, res) {
  let headers = req.headers;
  console.log(headers)
  // todo. request_role 테스트용으로 임의전달중이므로, 실제 구현시 제거되어야 합니다.
  const { username, password } = req.body
  console.log(username, password);
  
  res.json(response(200, { headers, msg: 'hello login', token: username === 'editor' ? 'editor_token' : 'admin_token' }))
}
const info = async function (req, res) {
  const { token } = req.query
  console.log(token);
  // todo. 로직 아직 작성하지 않음.
  if (token === 'editor_token') {
    res.json(response(200, {
      roles: ['editor'],
      name: 'Shop Manager',
      avatar: 'https://wpimg.wallstcn.com/f778738c-e4f8-4870-b634-56703b4acafe.gif',
      introduction: 'I am a shop manager'
    }))
  } else {
    res.json(response(200, {
      roles: ['admin'],
      name: 'Super Admin',
      avatar: 'https://wpimg.wallstcn.com/f778738c-e4f8-4870-b634-56703b4acafe.gif',
      introduction: 'I am a super administrator'
    }))
  }
}
const register = async function (req, res) {
  const { user_name } = req.params
  console.log(user_name);

  
  res.json(response(200, {
    token: 'registed_token'
  }))
}

const user_logout = async function (req, res) {
  const { token } = req.params
  console.log('logout todo remove token ', token);

  res.json(response(200, {}))
}

const excel_upload = async function (req, res) {
  // {{ local testing
  // const workbook = new ExcelJS.Workbook();
  // let readed = await workbook.xlsx.readFile(__dirname +'\\user_test.xlsx');
  // console.log('workbook : ', readed.worksheets[2].getRow(7).values);
  // }}
  // read from a file
  if (req.files && req.files.length > 0) {
    const workbook = new ExcelJS.Workbook();
    try {
      for (var i = 0; i < req.files.length; i++) {
        let read = await workbook.xlsx.readFile(req.files[i].url);
        console.log(read.worksheets[0].getRow(1).values)
      }
      res.json(response(200, req.files));
    } catch (err) {
      log(err)
      res.json(response(500))
    }
  } else {
    res.json(response(415));
  }
}

exports.user = user;
exports.users = users;
exports.auth_kakao = auth_kakao;
exports.kakao_callback = kakao_callback;
exports.logout = logout;
exports.login = login;
exports.info = info;
exports.register = register;
exports.user_logout = user_logout;
exports.excel_upload = excel_upload;


