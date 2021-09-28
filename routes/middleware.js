/**
  Copyright (c) 2019 asdaisy
  Licensed under the Apache License, Version 2.0 (the “License”)
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at asdaisy@hanmail.net
 */
const log = require('../lib/util').log('MIDDLEWARE');
const { no_auth_routes } = require('../conf/route_conf');
const redis = require('../lib/redis')
const response = require('../lib/response')

/**
 * This is a middleware function for common purpose,
 * ex) token authentication
 */
exports.authenticate = async function (req, res, next) {
  const auth_token = req.headers.auth_token
  if (!auth_token) {
    res.json(response(404))
    return;
  }
  let user = await redis.get(`user:${auth_token}`);
  if (user) {
    req.user_id = user.user_id;
    req.shop_id = user.shop_id;
  } else {
    res.json(response(404))
    return;
  }
  next();
};


