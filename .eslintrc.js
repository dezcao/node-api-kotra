// https://eslint.org/docs/user-guide/configuring
// see also: http://vuejs.kr/vue/eslint/2017/12/03/eslint-plugin-vue/

module.exports = {
  root: true,
  parserOptions: {
    parser: "babel-eslint",
  },
  env: {
    browser: true,
  },
  // https://github.com/vuejs/eslint-plugin-vue#priority-a-essential-error-prevention
  // consider switching to `plugin:vue/strongly-recommended` or `plugin:vue/recommended` for stricter rules.
  extends: [
    "standard"
  ],
  plugins: [
    "standard"
  ],
  // add your custom rules here
  rules: {
    // allow async-await
    'generator-star-spacing': 'off',
    'eol-last': 0,
    'no-multiple-empty-lines': 0,
    'indent': 1,
    'semi': 0,
    'no-trailing-spaces': 0,
    'no-tabs': 0,
    'no-new': 0,
    'no-unused-vars': 0,
    'camelcase': 0,
    // allow debugger during development
    'no-debugger': process.env.NODE_ENV === 'production' ? 'error' : 'off'
  }
}
