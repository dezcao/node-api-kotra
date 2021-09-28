/**
  Copyright (c) 2019 asdaisy
  Licensed under the Apache License, Version 2.0 (the “License”)
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at asdaisy@hanmail.net
  */
const axios = require('axios');
const config = require('../conf/config');
const util = require('./util');

/**
 * sms 메시지 보내기
 * @param to - 수신인 폰번호
 * @param msg - sms 전송 내용
 * @param reserved_time - 예약 발송시간(YYYYMMDDhhmm - 12자리)
 */
async function sms (to, msg, reserved_time) {
  to = util.extractNum(to);
  let message_id = util.mk_randNum(8);
  try {
    let post_data = {
      usercode: config.sms_info.usercode,
      deptcode: config.sms_info.deptcode,
      messages: [{ to, message_id }],
      from: config.sms_info.from,
      text: msg,
      reserved_time
    };
    let req_opts = { headers: { 'Content-Type': 'application/json' } }
    let { data } = await axios.post(config.sms_info.api_url, post_data, req_opts);
    return data;
  } catch (err) {
    throw err;
  }
}

exports.sms = sms;
