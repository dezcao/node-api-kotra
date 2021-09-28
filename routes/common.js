/**
  Copyright (c) 2019 asdaisy
  Licensed under the Apache License, Version 2.0 (the “License”)
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at asdaisy@hanmail.net
  */
const log = require('../lib/util').log('ROUTE:COMMON');
const config = require('../conf/config');
const util = require('../lib/util');
const redis = require('../lib/redis');
const response = require('../lib/response');
const { temp_mail } = require('../lib/mail');
const axios = require('axios');
const fs = require('fs');


/**
 * API 버전 정보과 user agent 정보를 가져온다.
 * @route get /
 */
const index = async function (req, res) {
  let agent = req.useragent;
  res.json(response(200, { app_name: config.app_name, app_version: config.app_version, agent }));
};

/**
 * Send verification code by email
 * @route post /sendmail
 * @param email: user email address
 */
const sendmail = async function (req, res) {
  let { email } = req.body;
  let from = 'Petme <master@petme.kr>'
  let subject = '[Petme] Verification code';
  let file = 'email.ejs';
  let auth_num = util.mk_randNum(5);
  let ip = req.ip ? req.ip.replace('::ffff:', '') : req.ip;
  let email_check_key = `email:${email}:${ip}`;
  let info = null;
  try {
    let check_email_count = await redis.get(email_check_key);
    if (!check_email_count) {
      redis.set(email_check_key, 1, 60 * 60 * 24);
    } else {
      if (check_email_count >= 10) {
        res.json(response(430));
        return;
      }
      redis.incr(email_check_key);
    }
    info = await temp_mail(email, from, subject, file, { auth_num });
    redis.set('email:' + auth_num, { email }, 60 * 10);
  } catch (err) {
    log(err);
    res.json(response(504));
  }
  res.json(response(200, info));
};

/**
 * 파일 업로드
 * req.files 은 업로드 필드의 파일 정보
 * 텍스트 필드가 있는 경우, req.body가 이를 포함
 * @route post /uploadimage
 */
const uploadimage = async function (req, res) {
  if (req.files && req.files.length > 0) {
    const myPool = req.app.get('pool');
    try {
      for (var i = 0; i < req.files.length; i++) {
        let dbParams = {
          asset_id: req.files[i].file_id,
          originalname: req.files[i].originalname,
          encoding: req.files[i].encoding,
          mimetype: req.files[i].mimetype,
          url: req.files[i].url,
          destination: req.files[i].destination,
          filename: req.files[i].filename,
          path: req.files[i].path,
          size: req.files[i].size
        }
        await myPool.doQueryFile('asset.sql', { sql_id: 'CREATE_ASSET', ...dbParams })
      }
      res.json(response(200, req.files));
    } catch (err) {
      log(err)
      res.json(response(500))
    }
  } else {
    res.json(response(415));
  }
};

/**
 * 접속 아이피의 국가 코드
 * @route get /getcountry
 */
const getCountry = async function (req, res) {
  let ip = req.ip.replace('::ffff:', '');
  let nation = await util.getNationByIp(ip);
  res.json(response(200, nation));
}

/**
 * 경도 위도 좌표를 이용하여 주소로 변환
 * @route post /geo2address
 * @param {string} x - 경도 좌표(longitude)
 * @param {string} y - 위도 좌표(latitude)
 */
const geo2address = async function (req, res) {
  let { x, y } = req.body;
  if (util.isNull(x) || util.isNull(y) || !Number(x) || !Number(y)) {
    res.json(response(401));
    return;
  }
  let config = {
    method: 'get',
    url: `http://dapi.kakao.com/v2/local/geo/coord2address.json?x=${x}&y=${y}`,
    headers: {
      'User-Agent': 'Petme Agent v1.0',
      'Cache-Control': 'max-age=0',
      'Authorization': 'KakaoAK 1b580389e626d8229af602765c66b2ac'
    }
  };
  try {
    let { data: { documents } } = await axios(config);
    if (documents.length === 0) {
      res.json(response(411));
    } else {
      res.json(response(200, documents[0]));
    }
  } catch (err) {
    res.json(response(502));
  }
};

/**
 * 주소에 해당하는 경도 위도 좌표
 * @route post /address2geo
 * @param {string} address - 주소
 */
const address2geo = async function (req, res) {
  let { address } = req.body;
  if (util.isNull(address)) {
    res.json(response(401));
    return;
  }
  let config = {
    method: 'get',
    url: `https://dapi.kakao.com/v2/local/search/address.json?query=${encodeURI(address)}&AddressSize=10`,
    headers: {
      'User-Agent': 'Petme Agent v1.0',
      'Cache-Control': 'max-age=0',
      'Authorization': 'KakaoAK 1b580389e626d8229af602765c66b2ac'
    }
  };
  try {
    let { data: { documents } } = await axios(config);
    if (documents.length === 0) {
      res.json(response(411));
    } else {
      res.json(response(200, documents[0]));
    }
  } catch (err) {
    log(err);
    res.json(response(502));
  }
};

/**
 * 임의 문자열 혹은 숫자를 만든다
 * @route post /random
 * @param {string} count - 생성할 난수의 개수, 기본값 10개
 * @param {string} type - S: 문자 영대/영소/숫자
 *                        E: 문자 34 영대/숫자, 구분안되는 문자[영문 O, 숫자 0]제외(추천인 코드용)
 *                        N: 숫자
 * @param {string} length - 임의 문자열의 자리수, 기본값: 32
 * @param {string} is_lowercase - 소문자 변환 여부
 */
const getRandom = async function (req, res) {
  try {
    let { count = 10, type = 'S', length = 32, is_lowercase = 'N' } = req.body;
    let fn = null;
    switch (type) {
      case 'S':
        fn = util.mk_rand62;
        break;
      case 'E':
        fn = util.mk_rand34;
        break;
      default:
        fn = util.mk_randNum;
        break;
    }
    let randomArray = [];
    for (let i = 0; i < count; i++) {
      let random = is_lowercase === 'N' ? fn(length) : fn(length).toLowerCase();
      randomArray.push(random);
    }
    res.json(response(200, randomArray));
  } catch (err) {
    console.log(err);
    res.json(response(417));
  }
}

/**
 * 공통코드 정보 조회
 * @route get /comcode
 * @param {string} code_type - 코드 타입
 */
const comcode = async function (req, res) {
  const { code_type } = req.query;
  const myPool = req.app.get('pool');
  let re = null;
  try {
    re = await myPool.doQueryFile('asset.sql', { sql_id: 'COMCODE', code_type });
  } catch (err) {
    log(err);
    res.json(response(500));
    return
  }
  res.json(response(200, re));
};

/**
 * Download the file corresponding to the account_id
 * @route get /viewfile/:asset_id
 * @param {string} asset_id - file asset id
 */
const viewFile = async function (req, res) {
  let asset_id = req.params.asset_id;
  const myPool = req.app.get('pool');
  let re = null;
  try {
    re = (await myPool.doQueryFile('asset.sql', { sql_id: 'GET_ASSET', asset_id }))[0];
  } catch (err) {
    log(err);
    res.json(response(500));
    return;
  }
  if (!re) {
    res.json(response(429));
    return;
  }
  res.set({
    'Content-Type': re.mimetype,
    'Content-Length': re.size
  });
  let readStream = fs.createReadStream(re.path);
  readStream.pipe(res);
  readStream.on('error', (err) => {
    log(err);
    res.json(response(429));
  });
}

exports.index = index;
exports.uploadimage = uploadimage;
exports.sendmail = sendmail;
exports.getCountry = getCountry;
exports.geo2address = geo2address;
exports.address2geo = address2geo;
exports.getRandom = getRandom;
exports.comcode = comcode;
exports.viewFile = viewFile;
