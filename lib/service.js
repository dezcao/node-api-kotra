const log = require('../lib/util').log('SERVICE:MODEL')
const response = require('../lib/response')

exports.mysqlSelect = async function (req, res, dbParams, sqlFileName, sqlId) {
  const myPool = req.app.get('pool');
  let re = null
  try {
    re = await myPool.doQueryFile(sqlFileName, { sql_id: sqlId, ...dbParams })
    res.json(response(200, re))
    return re
  } catch (err) {
    log(err)
    res.json(response(500))
  }
}

exports.mysqlUpdate = async function (req, res, dbParams, sqlFileName, sqlId) {
  const myPool = req.app.get('pool');
  let re = null
  try {
    re = await myPool.doQueryFile(sqlFileName, { sql_id: sqlId, ...dbParams })
    res.json(response(200))
  } catch (err) {
    log(err)
    res.json(response(500))
  }
}

exports.mysqlInsert = async function (req, res, dbParams, sqlFileName, sqlId) {
  const myPool = req.app.get('pool');
  let re = null
  try {
    re = await myPool.doQueryFile(sqlFileName, { sql_id: sqlId, ...dbParams })
    if (re.affectedRows === 0) {
      res.json(response('insert data failed'))
      return
    }
    res.json(response(200))
  } catch (err) {
    log(err)
    res.json(response(500))
  }
}
