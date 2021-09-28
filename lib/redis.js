/**
  Copyright (c) 2019 asdaisy
  Licensed under the Apache License, Version 2.0 (the “License”)
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at asdaisy@hanmail.net
  */
const config = require('../conf/config');
const Redis = require('ioredis');
const redis = new Redis(config.redis_info);

const get = async (key) => {
  try {
    let data = await redis.get(key);
    return JSON.parse(data);
  } catch (err) {
    throw err;
  }
};
const set = (key, data, ttl) => {
  if (ttl) {
    return redis.set(key, JSON.stringify(data), 'EX', ttl);
  } else {
    return redis.set(key, JSON.stringify(data));
  }
};
const del = (key) => {
  return redis.del(key);
};
const keys = async (key) => {
  let data = await redis.keys(key);
  return data;
};
const get_ttl = async (key) => {
  let data = await redis.ttl(key);
  return data;
};
const set_ttl = (key, ttl) => {
  return redis.expire(key, ttl);
};
const rename_key = (key, new_key) => {
  return redis.rename(key, new_key);
};
const update_key = async (key, data) => {
  let ttl = await get_ttl(key);
  if (ttl > 0) {
    return set(key, data, ttl);
  } else {
    return set(key, data);
  }
};
const lrange = async (key, start, end) => {
  let data = await redis.lrange(key, start, end);
  return data;
};
const lpush = (key, value) => {
  return redis.lpush(key, value);
};
const lpop = async (key) => {
  let data = await redis.lpop(key);
  return data;
};
const incr = (key) => {
  return redis.incr(key);
}
const decr = (key) => {
  return redis.decr(key);
}

exports.client = redis;
exports.get = get;
exports.set = set;
exports.del = del;
exports.keys = keys;
exports.get_ttl = get_ttl;
exports.set_ttl = set_ttl;
exports.rename_key = rename_key;
exports.update_key = update_key;
exports.lrange = lrange;
exports.lpush = lpush;
exports.incr = incr;
exports.decr = decr;
exports.lpop = lpop;




