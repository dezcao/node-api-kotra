## TOV express Framework.

## Install 
1. install pm2 super daemon and related library 
```shell
$ npm install -g pm2
$ npm install 
```
2. add environment setting to named .env
```shell
$ vi .env
DB_HOST = '127.0.0.1'
DB_PORT = 3306
DB_USER = 'db user'
DB_NAME = 'db name'
DB_PASS = 'db password'
REDIS_HOST = '127.0.0.1'
REDIS_PORT = 6379 
REDIS_PASS = 'redis server password'
MAIL_HOST = "smtp mail server <ip> or <address>"
MAIL_PORT = 465
MAIL_USER = "mail user email"
MAIL_PASS = "mail user password"
```
3. create sample database
```shell
$ mysql tov < tov.sql
```

4. start was daemon
```shell
$ pm2 start ./pm2.json
```
5. run lint or fix, [What is lint?](https://eslint.org/)
```shell
$ npm run lint
$ npm run fix
```
## SQL Query binding rules
### First, Apply ejs context
1. Escaping query values with :key
2. Escaping query identifiers with @key

* Numbers are left untouched
* Booleans are converted to true / false
* Date objects are converted to 'YYYY-mm-dd HH:ii:ss' strings
* Buffers are converted to hex strings, e.g. X'0fa5'
* Strings are safely escaped
* Arrays are turned into list, e.g. ['a', 'b'] turns into 'a', 'b'
* Nested arrays are turned into grouped lists (for bulk inserts), e.g. [['a', 'b'], ['c', 'd']] turns into ('a', 'b'), ('c', 'd')
* Objects that have a toSqlString method will have .toSqlString() called and the returned value is used as the raw SQL.
```
  var CURRENT_TIMESTAMP = { toSqlString: function() { return 'CURRENT_TIMESTAMP()'; } };
```
* Objects are turned into key = 'val' pairs for each enumerable property on the object. If the property's value is a function, 
  it is skipped; if the property's value is an object, toString() is called on it and the returned value is used.
```
  var post  = {id: 1, title: 'Hello MySQL'};
  console.log(sql); // INSERT INTO posts SET `id` = 1, `title` = 'Hello MySQL'
```
* undefined / null are converted to NULL
* NaN / Infinity are left as-is. MySQL does not support these, and trying to insert them as values will trigger MySQL errors until they implement support.

