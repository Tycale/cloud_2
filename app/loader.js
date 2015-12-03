var bodyParser = require('body-parser');
var cassandra = require('cassandra-driver');
var async = require('async');
var uuid = require('node-uuid');
var fs = require('fs');
var byline = require('byline');
var crypto = require('crypto');
var assert = require('assert');

var client = new cassandra.Client( { contactPoints : [ '127.0.0.1' ] } );
client.connect(function(err, result) {
    console.log('Connected.');
});

async.series([
    function connect(next) {
        client.connect(next);
    },
    function dropKeyspace(next) {
        var query = "DROP KEYSPACE IF EXISTS twitter;";
        client.execute(query, next);
    },
    function createKeyspace(next) {
        var query = "CREATE KEYSPACE IF NOT EXISTS twitter WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '3' };";
        client.execute(query, next);
    },
    function createUserTable(next) {
        var query = 'CREATE TABLE IF NOT EXISTS twitter.Users (' + 
                    'username varchar PRIMARY KEY,' + 
                    'name text,' + 
                    'pass text);';
        client.execute(query, next);
    },

    /////////
    // HINT: CREATE ALL YOUR OTHER TABLES HERE
    /////////

    function createFollowerTable(next) {
        var query = 'CREATE TABLE IF NOT EXISTS twitter.ForwardFollowing (' +
            'username text,' +
            'follower text,' +
            'date timestamp,' +
            'PRIMARY KEY (username, date))' +
            'WITH CLUSTERING ORDER BY (date DESC);';
        client.execute(query, next);
    },

    function createFollowingTable(next) {
        var query = 'CREATE TABLE IF NOT EXISTS twitter.BackwardFollowing (' +
            'username text,' +
            'have_follower text,' +
            'date timestamp,' +
            'PRIMARY KEY (username, date))' +
            'WITH CLUSTERING ORDER BY (date DESC);';
        client.execute(query, next);
    },

    function createTweetsTable(next) {
        var query = 'CREATE TABLE IF NOT EXISTS twitter.Tweets (' +
            'tweetid timeuuid,' +
            'username text,' +
            'author text,' +
            'created_at timestamp,' +
            'body text,' +
            'PRIMARY KEY (tweetid, created_at))' +
            'WITH CLUSTERING ORDER BY (created_at DESC);';
        client.execute(query, next);
    },

    function createTimelineTable(next) {
        var query = 'CREATE TABLE IF NOT EXISTS twitter.Timeline (' +
            'tweetid timeuuid,' +
            'date timestamp,' +
            'username text,' +
            'PRIMARY KEY (tweetid, date))' +
            'WITH CLUSTERING ORDER BY (date DESC);';
        client.execute(query, next);
    },

    function createUserlineTable(next) {
        var query = 'CREATE TABLE IF NOT EXISTS twitter.Userline (' +
            'tweetid timeuuid,' +
            'date timestamp,' +
            'username text,' +
            'PRIMARY KEY (tweetid, date))' +
            'WITH CLUSTERING ORDER BY (date DESC);';
        client.execute(query, next);
    },


    function insertUsers(next)
    {        
        /* private encryption & validation methods */
        // To insert same password "test" for all the users
        var generateSalt = function()
        {
            var set = '0123456789abcdefghijklmnopqurstuvwxyzABCDEFGHIJKLMNOPQURSTUVWXYZ';
            var salt = '';
            for (var i = 0; i < 10; i++) {
                var p = Math.floor(Math.random() * set.length);
                salt += set[p];
            }
            return salt;
        }
        
        var md5 = function(str) {
            return crypto.createHash('md5').update(str).digest('hex');
        }
        
        var saltAndHash = function(pass, callback)
        {
            var salt = generateSalt();
            callback(salt + md5(pass + salt));
        }
        
        var upsertUser = 'INSERT INTO twitter.Users (username, name, pass) '
            + 'VALUES(?, ?, ?);';
        var upsertForwardFollowing = 'INSERT INTO twitter.ForwardFollowing (username, follower, date) ' +
            'VALUES(?, ?, ?);';
        var upsertBackwardFollowing = 'INSERT INTO twitter.BackwardFollowing (username, have_follower, date) ' +
            'VALUES(?, ?, ?);';
        var u = byline(fs.createReadStream(__dirname + '/users.json'));
     
        u.on('data', function(line) {
            try {
                var obj = JSON.parse(line);
                saltAndHash("test", function(pass) {
                    obj.pass = pass;
                    client.execute(upsertUser,
                        [obj.username, obj.fullname, obj.pass],
                        afterExecution('Error: ', 'User ' + obj.username + ' upserted.'));
                    for (var i in obj.followers) {
                        /////////
                        // HINT: UPDATE USER RELATIONS TO USERS FOLLOWED BY USER obj
                        /////////
                        client.execute(upsertForwardFollowing,
                            [obj.username, obj.followers[i], new Date()],
                            afterExecution('Error: ', 'User ' + obj.username + ' following ' + obj.followers[i] + ' upserted. '));
                        client.execute(upsertBackwardFollowing,
                            [obj.followers[i], obj.username, new Date()],
                            afterExecution('Error: ', 'User ' + obj.followers[i] + ' has follower ' + obj.username + ' upserted.'));
                    }
                });
            } catch (err) {
                console.log("Error:", err);
            }
        });
        u.on('end', next);
    },
    function insertTweet(next)
    {
        var getFollowers = 'SELECT have_follower FROM twitter.BackwardFollowing WHERE username=?';
        var upsertTweet = 'INSERT INTO twitter.Tweets (tweetid, username, author, created_at, body) '
            + 'VALUES(?, ?, ?, ?, ?);';
        var upsertTimeline = 'INSERT INTO twitter.Timeline (username, date, tweetid) '
            + 'VALUES(?, ?, ?);';
        var upsertUserline = 'INSERT INTO twitter.Userline (username, date, tweetid) '
            + 'VALUES(?, ?, ?);';

        var t = byline(fs.createReadStream(__dirname + '/sample.json'));

        t.on('data', function(line) {
        try {
            var obj = JSON.parse(line);
            obj.tweetid = uuid.v1();
            obj.created_at = new Date(Date.parse(obj.created_at));
            client.execute(upsertTweet,
                    [obj.tweetid, obj.username, obj.name, obj.created_at, obj.text],
                    afterExecution('Error:', 'Tweet ' + obj.tweetid + ' upserted.'));

            /////////
            // HINT: UPDATE TIMELINES CONTAINING TWEET obj
            /////////

            client.execute(upsertUserline,
                    [obj.username, new Date(), obj.tweetid],
                    afterExecution('Error: ', 'Userline ' + obj.tweetid + ' upserted.'));


            client.execute(getFollowers, [obj.username], function(err, result) {
                assert.ifError(err);
                for(var i in result.rows){
                    console.dir(result.rows[i]);
                }
            },
                afterExecution('Error: ', 'Timeline : tweet ' + obj.tweetid + ' upserted to ' + obj.username +'.'));

        } catch (err) {
            console.log("Error:", err);
        }
        });
        t.on('end', next);        
    }
], afterExecution('Error: ', 'Tables created.'));

function afterExecution(errorMessage, successMessage) {
    return function(err, result) {
        if (err) {
            return console.log(errorMessage + err);
        } else {
            return console.log(successMessage);
        }
    }
}

