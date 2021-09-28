/**
  Copyright (c) 2019 asdaisy
  Licensed under the Apache License, Version 2.0 (the “License”)
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at asdaisy@hanmail.net
  */
const route_conf =
[
  { file: './common', type: 'get', path: '/', method: 'index', auth: false },
  { file: './common', type: 'multi', path: '/uploadimage', method: 'uploadimage', auth: false },
  { file: './common', type: 'post', path: '/sendmail', method: 'sendmail', auth: false },
  { file: './common', type: 'get', path: '/getcountry', method: 'getCountry', auth: false },
  { file: './common', type: 'post', path: '/geo2address', method: 'geo2address', auth: false },
  { file: './common', type: 'post', path: '/address2geo', method: 'address2geo', auth: false },
  { file: './common', type: 'post', path: '/random', method: 'getRandom', auth: false },
  { file: './common', type: 'get', path: '/comcode', method: 'comcode', auth: false },
  { file: './common', type: 'get', path: '/viewfile/:asset_id', method: 'viewFile', auth: false },

  // 사용자 관련 API
  { file: './user', type: 'post', path: '/user/signup', method: 'signupUser', auth: false },
  { file: './user', type: 'post', path: '/user/login', method: 'loginUser', auth: false },
  { file: './user', type: 'get', path: '/user/info', method: 'inquireUser', auth: true },
  { file: './user', type: 'get', path: '/user/logout', method: 'logoutUser', auth: true },
  { file: './user', type: 'get', path: '/user/findEmail', method: 'findUserEmail', auth: false },
  { file: './user', type: 'get', path: '/user/list', method: 'inquireUserList', auth: true },
  { file: './user', type: 'post', path: '/user/changePassword', method: 'changeUserPassword', auth: false },

];


exports.route_conf = route_conf;
