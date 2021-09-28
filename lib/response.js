/**
  Copyright (c) 2019 asdaisy
  Licensed under the Apache License, Version 2.0 (the “License”)
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at asdaisy@hanmail.net
 */
const msg = {
  'ko': {
    200: '성공',
    401: '요청 파라미터 누락 혹은 유효하지 않은 입력값입니다.',
    402: '등록된 사용자가 없거나 혹은 비밀번호 오류입니다.',
    403: '중복된 사용자 정보 등록입니다.',
    404: '유효하지 않은 인증토큰',
    405: '유효하지 않은 계정주소',
    406: '등록되지 않은 계정정보',
    407: '유효하지 않은 이메일 인증 코드',
    408: '유효하지 않은 SMS 인증 코드',
    409: '이미 등록된 사용자 이메일',
    410: '유효하지 않은 2차 비밀번호',
    411: '등록된 정보가 없음',
    412: '계좌가 잠겨 있습니다.',
    413: '계좌 잔액이 부족합니다.',
    414: '이미 등록된 핸드폰번호입니다.',
    415: '업로드 할수 없는 파일 형식입니다.',
    416: '비밀번호 변경 오류입니다.',
    417: '중복된 상점 정보 등록입니다.',
    418: '중복된 회원 이메일입니다.',
    419: '모든 데이터가 이미 추가되어 있음',
    420: '변경된 정보가 없음',
    429: '등록된 파일 정보가 없음',
    430: '1일 이메일 전송 횟수를 초과했습니다.',
    431: '데이터의 갯수가 다름',
    432: '승인된 샵 정보가 없습니다.',
    433: '등록된 샵 정보가 없습니다.',
    500: '내부 디비 에러',
    501: '내부 인증 서버 에러',
    502: '내부 RPC 서버 에러',
    503: '내부 sms 서버 에러',
    504: '내부 email 서버 에러',
    505: '내부 개인키 오류',
    506: '디비 정합성 오류'
  },
  'en': {
    200: 'success',
    401: 'omitted request parameter or invalid parameter value',
    402: 'user not found or password error',
    403: 'Duplicate user information registration.',
    404: 'invalid auth token',
    405: 'invalid account address',
    406: 'unregistered account information',
    407: 'invalid email auth code',
    408: 'invalid sms auth code',
    409: 'already registered user email',
    410: 'invalid secondary password',
    411: 'not find registered info',
    412: 'account is locked',
    413: 'insufficient balance',
    414: 'already registered mobile phone number',
    415: 'not allowed upload file format',
    416: 'password change error',
    417: 'Duplicate store information registration.',
    418: 'Duplicate member email.',
    419: 'All data already added',
    420: 'No data to add',
    429: 'No registered file information',
    430: 'Exceeded number of email transfers per day.',
    431: 'The number of data is different.',
    432: 'No approved shop information',
    433: 'There is no registered shop information.',
    500: 'internal db error',
    501: 'internal session server error',
    502: 'internal rpc server error',
    503: 'internal sms server error',
    504: 'internal email server error',
    505: 'internal private key error',
    506: 'database consistency error'
  }
}

module.exports = (code, data, lang = 'ko') => {
  let res = {};
  res.ret_code = code;
  res.msg = msg[lang][code];
  if (data) {
    res.data = data;
  }
  return res;
}
