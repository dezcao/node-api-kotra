/**
	Copyright (c) 2019 asdaisy
	Licensed under the Apache License, Version 2.0 (the “License”)
	You may not use this file except in compliance with the License.
	You may obtain a copy of the License at asdaisy@hanmail.net
	*/
const ogs = require('open-graph-scraper');
const im = require('imagemagick-stream');
const path = require('path');
const fs = require('fs');
const _ = require('lodash');
const ejs = require('ejs');
const crypto = require('crypto');
const base_62 = [...'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'];
const base_34 = [...'ABCDEFGHIJKLMNPQRSTUVWXYZ123456789'];
const numbers = [...'0123456789'];
const moment = require('moment');
const config = require('../conf/config');
const Reader = require('@maxmind/geoip2-node').Reader;
const dbBuffer = fs.readFileSync(path.resolve(__dirname, './GeoLite2-Country.mmdb'));
const reader = Reader.openBuffer(dbBuffer);

/*
Array.prototype.remove = function (key) {
		_.remove(this, (data) => { return data === key; });
};
*/

function log (name_space) {
  let log = require('debug')(config.log_prefix + name_space);
  log.log = console.log.bind(console);
  return log;
}

function extract_mention_id (str) {
  let ids = str.match(/<@.*?>/g);
  if (!ids) { return null; }
  ids = ids.map(data => {
    return data.replace(/<@(.*?)>/g, '$1');
  });
  return ids;
}

function bind_string (temp, values) {
  if (!values) return temp;
  temp = temp.replace(/:(\w+)/g, function (txt, key) {
    if (values.hasOwnProperty(key)) {
      return values[key];
    }
    return txt;
  });
  return temp;
};

/**
 * compile template using ejs engine
 */
function bind_ejs (temp, values) {
  if (!values) return temp;
  return ejs.compile(temp)(values);
};

// 62진수 임의 문자열을 만든다.
function mk_rand62 (len = 32) {
  let buf = [];
  for (let i = 0; i < len; i++) {
    let ch = base_62[getRandomInt(0, base_62.length)];
    buf.push(ch);
  }
  return buf.join('');
}

// 34진수 임의 문자열을 만든다.
function mk_rand34 (len = 32) {
  let buf = [];
  for (let i = 0; i < len; i++) {
    let ch = base_34[getRandomInt(0, base_34.length)];
    buf.push(ch);
  }
  return buf.join('');
}

/**
 * make random number string
 */
function mk_randNum (len = 4) {
  let buf = [];
  for (let i = 0; i < len; i++) {
    let ch = numbers[getRandomInt(0, numbers.length)];
    buf.push(ch);
  }
  return buf.join('');
}

// min (포함)과 max(불포함) 사이의 난수를 반환
function getRandomArbitrary (min, max) {
  return Math.random() * (max - min) + min;
}

// min(포함)과 max(불포함) 사이의 임의 정수를 반환
function getRandomInt (min, max) {
  return Math.floor(Math.random() * (max - min)) + min;
}

// min(포함)과 max(포함) 사이의 임의 정수를 반환
function getRandomIntInclusive (min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function __og (url) {
  return new Promise(function (resolve, reject) {
    const options = { 'url': url, 'timeout': 2000 };
    ogs(options, function (error, results) {
      if (error) { reject(error); } else { resolve(results); }
    });
  });
}

// function for scraping Open Graph and Twitter Card info off a site
async function og (url) {
  try {
    let re = await __og(url);
    let { success, requestUrl, data: { ogTitle, ogUrl, ogDescription, ogImage } } = re;
    if (!success) { return null; }
    if (!ogImage) { return null; }
    ogImage = ogImage.url
    if (!ogTitle) { ogTitle = requestUrl; }
    return { ogTitle, ogUrl, ogDescription, ogImage };
  } catch (err) {
    return null;
  }
}

function mk_thumb_path (p, width) {
  let dirname = path.dirname(p);
  let extname = path.extname(p);
  let basename = path.basename(p);
  basename = basename.replace(extname, '_x' + width + extname);
  return path.join(dirname, basename);
}

function mk_thumb (p, width = '200', quality = 90) {
  let out_file = mk_thumb_path(p, width);
  im(p).resize(width).quality(quality).to(out_file);
  return out_file;
}

function sha256Hash (key) {
  return crypto.createHash('sha256').update(key).digest('hex');
}

function getNationByIp (ip) {
  let nation = null
  try {
    nation = reader.country(ip).country
  } catch (err) {
    return null;
  }
  return nation
}

/**
 * Calculating the start index for paging processing
 * @param list_size - Row numbers per page
 * @param page_num - Request page number
 */
function paging (list_size, page_num) {
  list_size = Math.floor(Number(list_size));
  page_num = Math.floor(Number(page_num));
  list_size = !list_size || list_size <= 0 ? 10 : list_size;
  page_num = !page_num || page_num <= 0 ? 1 : page_num;
  let start_no = (page_num - 1) * list_size;
  return { list_size, start_no };
}

/**
 * Pad the string with the given character.
 * @param suffix - source string
 * @param count - Full String Length
 * @param char - padding character
 * @isLpad - Padding on the left side
 */
function pad (suffix, count, char, isLpad = false) {
  let buf = [];
  let cnt = count - suffix.length < 0 ? 0 : count - suffix.length;
  for (let i = 0; i < cnt; i++) {
    buf.push(char);
  }
  if (isLpad) {
    return buf.join('') + suffix;
  } else {
    return suffix + buf.join('');
  }
}

/**
 * Password verification (a combination of 8 or more characters and numbers + alphabetic + special characters)
 */
function valatePWD (pw) {
  if (!pw) { return false; }
  return /^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?&])[A-Za-z\d$@$!%*#?&]{8,}$/.test(pw)
}

/**
 * Gets the string of the current date and current time
 */
function now (f = 'YYYY-MM-DD HH:mm:ss') {
  return moment().format(f);
}

/**
 * Extracts numeric data from a given string.
 */
function extractNum (data) {
  let arr = data.split('');
  let buf = [];
  for (let x of arr) {
    if (numbers.indexOf(x) >= 0) {
      buf.push(x);
    }
  }
  return buf.join('');
}

/**
 * check null value
 */
function isNull (str) {
  if (typeof str === 'undefined' || str === null || str === '' || String(str).trim().length === 0) {
    return true;
  } else {
    return false;
  }
}

/**
 * 문자열의 중간부분을 마스킹 처리 
 */
function maskingStr (str) {
  if (isNull(str)) {
    return str;
  }
  let strLength = str.length;
  let startPos = Math.round(strLength * 0.3);
  let endPos = Math.round(strLength * 0.7);
  if (strLength === 2) { endPos = 2; }
  return str.substring(0, startPos) + ''.padEnd(endPos - startPos, '*') + str.substring(endPos);
}

/**
 * 이메일 형식의 데이터를 마스킹 처리
 */
function maskingEmail (str) {
  if (isNull(str)) {
    return str;
  }
  if (str.indexOf('@') === -1) {
    return str;
  }
  let temp = str.split('@');
  temp[0] = maskingStr(temp[0]);
  return temp[0] + '@' + temp[1];
}

exports.bind_string = bind_string;
exports.bind_ejs = bind_ejs;
exports.mk_rand62 = mk_rand62;
exports.mk_rand34 = mk_rand34;
exports.og = og;
exports.extract_mention_id = extract_mention_id;
exports.log = log;
exports.mk_thumb = mk_thumb;
exports.sha256Hash = sha256Hash;
exports.mk_randNum = mk_randNum;
exports.getNationByIp = getNationByIp;
exports.paging = paging;
exports.pad = pad;
exports.valatePWD = valatePWD;
exports.now = now;
exports.extractNum = extractNum;
exports.isNull = isNull;
exports.maskingStr = maskingStr;
exports.maskingEmail = maskingEmail;




