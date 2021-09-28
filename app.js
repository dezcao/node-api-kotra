/**
  Copyright (c) 2019 asdaisy
  Licensed under the Apache License, Version 2.0 (the “License”)
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at asdaisy@hanmail.net
  */
const express = require('express');
const path = require('path');
const favicon = require('serve-favicon');
const logger = require('morgan');
const cookieParser = require('cookie-parser');
const bodyParser = require('body-parser');
const cors = require('cors');
const useragent = require('express-useragent');
const nocache = require('nocache');
const route_loader = require('./routes/route_loader');
const common_authenticate = require('./routes/middleware').authenticate;
const config = require('./conf/config');
const Pool = require('./lib/pool');
const log = require('./lib/util').log('APP');


const app = express();
const myPool = new Pool(config.db_info);
app.set('pool', myPool);

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');
app.disable('x-powered-by');

// uncomment after placing your favicon in /public
// app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')));
// app.use(logger('dev'));  // Predefined Formats : [combined|common|dev|short|tiny]
app.use(express.static(path.join(__dirname, 'public'), config.static_options));
// app.use(express.static(config.upload_root_dir, config.static_options));
app.use(bodyParser.json()); // for parsing application/json
app.use(bodyParser.urlencoded({ extended: true })); // for parsing application/x-www-form-urlencoded
app.use(cookieParser());
app.use(nocache());
app.use(useragent.express());

// enable cors
const cors_opts = {
  'origin': '*',
  'methods': 'GET,PUT,POST,DELETE,OPTIONS',
  'allowedHeaders': 'Origin, Accept, Content-Type, Content-Length, X-Requested-With, auth_token, authorization, x-token',
  'exposedHeaders': 'Content-Disposition'

};
app.use(cors(cors_opts));

// middleware function call
// app.use(common_authenticate);

// set route path and function
route_loader.init(app);

// catch 404 and forward to error handler
app.use(function (req, res, next) {
  var err = new Error('Not Found');
  err.status = 404;
  next(err);
});

// error handler
app.use(function (err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.status = err.status || 500;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.type('application/json');
  res.status(res.locals.status);
  res.render('error');
});

process.on('unhandledRejection', (err) => {
  log('unhandledRejection : ' + err);
});
process.on('uncaughtException', function (err) {
  log('uncaughtException occured : ' + err);
});
process.on('SIGINT', function () {
  log('-------------------> SIGINT <-----------------------------');
  // Drain pool during shutdown (optional)
  // Only call this once in your application
  // -- at the point you want to shutdown and stop using this pool.
  myPool.pool.drain().then(function () {
    myPool.pool.clear();
  });
  process.exit(0);
});

module.exports = app;



