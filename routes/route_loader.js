/**
  Copyright (c) 2019 asdaisy
  Licensed under the Apache License, Version 2.0 (the “License”)
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at asdaisy@hanmail.net
  */
const express = require('express');
const route_conf = require('../conf/route_conf').route_conf;
const log = require('../lib/util').log('ROUTE:LOADER');
const upload = require('../lib/upload')
const middleware = require('../routes/middleware')
const passport = require('passport')

const route_loader = {};
route_loader.init = function (app) {
  return initRoutes(app);
}

function initRoutes (app) {
  let router = express.Router();
  log('Routing Number => [%d]', route_conf.length);

  for (let route of route_conf) {
    let curModule = require(route.file);
    switch (route.type.toLowerCase()) {
      case 'get':
        if (route.auth) router.route(route.path).get(middleware.authenticate);
        router.route(route.path).get(curModule[route.method]);
        break;
      case 'post':
        if (route.auth) router.route(route.path).post(middleware.authenticate);
        router.route(route.path).post(curModule[route.method]);
        break;
      case 'multi':
        if (route.auth) router.route(route.path).post(middleware.authenticate);
        router.route(route.path).post(upload.any(), curModule[route.method]);
        break;
      case 'put':
        if (route.auth) router.route(route.path).put(middleware.authenticate);
        router.route(route.path).put(curModule[route.method]);
        break;
      case 'delete':
        if (route.auth) router.route(route.path).delete(middleware.authenticate);
        router.route(route.path).delete(curModule[route.method]);
        break;
      case 'all':
        if (route.auth) router.route(route.path).all(middleware.authenticate);
        router.route(route.path).all(curModule[route.method]);
        break;
      default:
        throw new Error('invalid routing type');
    }
    log('Routing Method [%s] [%s] [%s] Loaded.', route.file, route.path, route.method);
  }
  app.use('/', router);
}

module.exports = route_loader;

