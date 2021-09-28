/**
  Copyright (c) 2019 asdaisy
  Licensed under the Apache License, Version 2.0 (the “License”)
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at asdaisy@hanmail.net
 */
const mysql = require('promise-mysql');
const genericPool = require('generic-pool');
const ejs = require('ejs');
const fs = require('fs');
const path = require('path');

class Pool {
  constructor (config) {
    config.queryFormat = function (query, values) {
      // Apply ejs context
      query = ejs.compile(query)(values);
      if (!values) return query;
      // Escaping query values
      query = query.replace(/:(\w+)/g, function (txt, key) {
        if (values.hasOwnProperty(key)) {
          return this.escape(values[key]);
        }
        return txt;
      }.bind(this));
      // Escaping query identifiers
      query = query.replace(/@(\w+)/g, function (txt, key) {
        if (values.hasOwnProperty(key)) {
          return this.escapeId(values[key]);
        }
        return txt;
      }.bind(this));
      console.log(query.trim());
      return query.trim();
    };
    const factory = {
      create: function () {
        return mysql.createConnection(config);
      },
      destroy: function (con) {
        con.end();
      }
    };
    let { autostart, max, min } = config;
    this.myPool = genericPool.createPool(factory, { autostart, max, min });
    this.config = config;
    this.query_cache = new Map();
  }

  get pool () {
    return this.myPool;
  }

  readQueryFile (file_name) {
    let query_file = path.join(this.config.sqlPath, file_name);
    let query = null;
    if (query_file.split('.').pop() !== 'sql') {
      query_file = query_file + '.sql';
    }
    if (this.config.useQueryCache && this.query_cache.get(query_file)) {
      return this.query_cache.get(query_file);
    }
    try {
      query = fs.readFileSync(query_file, 'utf8');
      if (this.config.useQueryCache) this.query_cache.set(query_file, query);
    } catch (err) {
      throw err;
    }
    return query;
  }

  async doQuery (query, values) {
    const con = await this.myPool.acquire(); // acquire connection - Promise is resolved
    let re = null;
    try {
      re = await con.query(query, values);
    } catch (err) {
      throw err;
    } finally {
      this.myPool.release(con); // return connection back to pool
    }
    return re;
  }

  async doQueryFile (file_name, values) {
    let query = null;
    try {
      query = this.readQueryFile(file_name);
      return await this.doQuery(query, values);
    } catch (err) {
      throw err;
    }
  }

  async doTrans (query, values) {
    const con = await this.pool.acquire();
    let rs = null;
    try {
      await con.beginTransaction();
      rs = await con.query(query, values);
      await con.commit();
    } catch (err) {
      await con.rollback();
      throw err;
    } finally {
      this.myPool.release(con);
    }
    return rs;
  }

  async doTransQueries (queriesData) {
    const con = await this.pool.acquire()
    let rs = null
    try {
      await con.beginTransaction();
      for (let i = 0; i < queriesData.length; i++) {
        let data = queriesData[i]
        let query = this.readQueryFile(data.queryFile);
        rs = await con.query(query, data.queryData);
      }
      await con.commit();
    } catch (err) {
      await con.rollback()
      throw err
    } finally {
      this.myPool.release(con)
    }
    return rs
  }

  async noTransQuery (con, file_name, values) {
    let rs = null
    try {
      let query = this.readQueryFile(file_name);
      rs = await con.query(query, values);
    } catch (err) {
      throw err
    }
    return rs
  }

  async doTransQueryFile (file_name, values) {
    let query = null;
    try {
      query = this.readQueryFile(file_name);
      return await this.doTrans(query, values);
    } catch (err) {
      throw err;
    }
  }
}

module.exports = Pool;
