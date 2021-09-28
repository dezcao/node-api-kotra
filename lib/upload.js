/**
  Copyright (c) 2019 asdaisy
  Licensed under the Apache License, Version 2.0 (the “License”)
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at asdaisy@hanmail.net
 */
const util = require('./util');
const mime = require('./mime');
const conf = require('../conf/config');
const path = require('path');
const fs = require('fs');
const multer = require('multer')

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    let file_id = util.mk_rand62().toLowerCase();
    let sub_dir = path.join(file_id.substr(0, 1), file_id.substr(1, 2));
    let upload_dir = path.join(conf.upload_root_dir, sub_dir);
    if (!fs.existsSync(upload_dir)) {
      fs.mkdirSync(upload_dir, { recursive: true });
    }
    file.file_id = file_id;
    file.url = path.join('/', sub_dir);
    cb(null, upload_dir)
  },
  filename: function (req, file, cb) {
    let base_name = file.file_id + '.' + mime[file.mimetype];
    file.url = path.join(file.url, base_name);
    cb(null, base_name)
  }
})
const fileFilter = function (req, file, cb) {
  cb(null, !!mime[file.mimetype])
}
const upload = multer({ storage, fileFilter })

module.exports = upload;
