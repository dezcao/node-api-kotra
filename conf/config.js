/**
  Copyright (c) 2019 asdaisy
  Licensed under the Apache License, Version 2.0 (the “License”)
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at asdaisy@hanmail.net
  */
require('dotenv').config();
const path = require('path');

module.exports = {
  app_name: 'pm-erp-api',
  app_version: '0.1.0',
  server_port: 80,
  log_prefix: 'express:',
  upload_root_dir: '/root/assets/',
  session_timeout: 30 * 60 * 12 * 12, // unit seconds
  db_info: {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME,
    sqlPath: path.join(__dirname, '../sql'),
    multipleStatements: true,
    flags: [],
    charset: 'UTF8_GENERAL_CI',
    supportBigNumbers: true,
    bigNumberStrings: true,
    dateStrings: true,
    debug: false,
    reconnect: true, // for promise-mysql option
    autostart: true, // should the pool start creating resources, initialize the evictor, etc once the constructor is called
    max: 50, // maximum size of the pool
    min: 5, // minimum size of the pool
    useQueryCache: false
  },
  static_options: {
    etag: true,
    maxAge: '1d',
    lastModified: true
  },
  redis_info: {
    host: process.env.REDIS_HOST,
    port: process.env.REDIS_PORT,
    // password: process.env.REDIS_PASS // only serverside connection
  },
  mail_info: {
    host: process.env.MAIL_HOST,
    port: process.env.MAIL_PORT,
    user: process.env.MAIL_USER,
    pass: process.env.MAIL_PASS
  },
  sms_info: {
    usercode: process.env.SMS_USERCODE,
    deptcode: process.env.SMS_DEPTCODE,
    from: process.env.SMS_FROM,
    api_url: process.env.SMS_API_URL
  }
}


