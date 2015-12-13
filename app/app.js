var express = require('express');
var app = module.exports = express();
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var expressSession = require('express-session');
var RedisStore = require('connect-redis')(expressSession);
var assert = require('assert');
var AM = require('./manager/account-manager.js');
var TM = require('./manager/tweet-manager.js');
var cassandra = require('cassandra-driver');
var async = require('async');
var cluster = require('cluster');
var os = require('os');
var config = require('config');

////////////////////////////////////////////////////////////////////////////////

app.set('env', 'development');

////////////////////////////////////////////////////////////////////////////////
// MIDDLEWARE

var redisOptions = {
    host: config.get('Redis.host'),
    port: config.get('Redis.port'),
    prefix: config.get('Redis.prefix')
};

app.use(cookieParser());

var sessionStore = new RedisStore(redisOptions);

var expressSessionOptions = {
    secret: config.get('Session.secretToken'),
    store: sessionStore,
    maxAge: config.get('Session.maxAge'),
    resave: true,
    saveUninitialized: false
};

app.use(expressSession(expressSessionOptions));


// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

// serve static content from the public directory
app.use(express.static(path.join(__dirname, 'public')));

// parse the parameters of POST requests (available through `req.body`)
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

// routes
app.use('/', require('./routes.js'));

// catch 404 and forward to error handler
app.use(function(req, res, next) {
    var err = new Error('Not Found');
    err.status = 404;
    next(err);
});

////////////////////////////////////////////////////////////////////////////////
// ERROR HANDLERS

// development error handler, will print stacktrace
if (app.get('env') === 'development') {
    app.use(function(err, req, res, next) {
        res.status(err.status || 500);
        console.log('[' + err.status + '] ' + err.message);
        res.render('template', {
            title: 'Error',
            partial: 'error',
            message: err.message,
            error: err
        });
    });
}

// production error handler, no stacktraces leaked to user
app.use(function(err, req, res, next) {
    res.status(err.status || 500);
    res.render('template', {
        title: 'Error',
        partial: 'error',
        message: err.message,
        error: {}
    });
});

////////////////////////////////////////////////////////////////////////////////
// START APP

// 1) Connect to Cassandra
// 2) Start the HTTP server

var nbInstances = config.get('Cluster.nbInstances');

if (nbInstances < 0) {
  var cores = os.cpus().length;
}

else {
  var cores = nbInstances;
}

if (cluster.isMaster) {
  for (var i = 0; i < cores; i++) {
    cluster.fork();
  }
}
else {
  app.db = new cassandra.Client( { contactPoints : config.get('Cassandra.contactPoints') } );
  app.db.connect(function(err, result) {
      console.log('Connected.');

      var server = app.listen(config.get('App.port'), function () {
          var host = server.address().address;
          var port = server.address().port;
          console.log('Listening at http://%s:%s', host, port);
      });
  });
}
////////////////////////////////////////////////////////////////////////////////
