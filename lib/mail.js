/**
  Copyright (c) 2019 asdaisy
  Licensed under the Apache License, Version 2.0 (the “License”)
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at asdaisy@hanmail.net
 */
const nodemailer = require('nodemailer');
const path = require('path');
const fs = require('fs');
const conf = require('../conf/config');
const util = require('./util');

let transporter = nodemailer.createTransport({
  host: conf.mail_info.host,
  port: conf.mail_info.port,
  pool: true,
  secure: true, // use TLS
  auth: {
    user: conf.mail_info.user,
    pass: conf.mail_info.pass 
  }
});

async function mail (to, from, subject, body) {
  let message = {
    to,
    from,
    subject,
    html: body
  };
  let info = await transporter.sendMail(message);
  return info;
}

async function temp_mail (to, from, subject, file, data) {
  let email_temp_path = path.join(__dirname, '../views/', file);
  let body = fs.readFileSync(email_temp_path, 'utf8');
  body = util.bind_ejs(body, data);
  let message = {
    to,
    from,
    subject,
    html: body
  };
  let info = await transporter.sendMail(message);
  return info;
}

exports.mail = mail;
exports.temp_mail = temp_mail;
