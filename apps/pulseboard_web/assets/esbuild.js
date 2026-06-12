const path = require('path');

module.exports = {
  entry: [
    path.join(__dirname, 'js/app.js'),
  ],
  bundle: true,
  target: 'es2017',
  outdir: path.join(__dirname, '..', 'priv', 'static', 'assets'),
  external: [],
  logLevel: 'info',
  loader: {
    '.js': 'js',
    '.css': 'css',
  },
};
