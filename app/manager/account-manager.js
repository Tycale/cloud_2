var crypto 		= require('crypto');
var moment 		= require('moment');
var app = require('../app');
var _ = require('underscore');
var TimeUuid = require('cassandra-driver').types.TimeUuid;

var collectionName = "Users";
var getUser = "SELECT * FROM twitter.Users WHERE username=?";

var insertUser = "INSERT INTO twitter.Users (username, name, pass) "
            + "VALUES(?, ?, ?);";

// <<<<<<< HEAD
// // request for HINTS
// var getfollowerReq = "SELECT follower FROM twitter.ForwardFollowing WHERE username = ?";
// var getfollowingReq = "SELECT have_follower FROM twitter.BackwardFollowing WHERE username = ?";
// var ForwardFollowingReq = "INSERT INTO ";
// =======
//
// >>>>>>> 637c9558957ecbcdac4b4b747251847c2bca7f65
/* login validation methods */

exports.autoLogin = function(user, pass, callback)
{
	app.db.execute(getUser, [ user ], function(e, result) {
		if (result && result.rows.length > 0) {
			var o = result.rows[0];
			o.pass == pass ? callback(o) : callback(null);
		}
		else{
			callback(null);
		}
	});
};

exports.manualLogin = function(user, pass, callback)
{
	app.db.execute(getUser, [ user ], function(e, result) {
		if (result && result.rows.length == 0){
			callback('user-not-found');
		}
		else{
			var o = result.rows[0];
			validatePassword(pass, o.pass, function(err, res) {
				if (res){
					callback(null, o);
					console.log("Successful!")
				}
				else {
					callback('invalid-password');
				}
			});
		}
	});
};

/* record insertion, update & deletion methods */
exports.addNewAccount = function(newData, callback)
{
	app.db.execute(getUser, [newData.username], function(e, result){
		if (result && result.rows.length > 0){
			callback('username-taken');
		}
		else{
			saltAndHash(newData.pass, function(hash){
				newData.pass = hash;
				app.db.execute(insertUser, [newData.username, newData.fullname, newData.pass], callback);
			});
		}
	});
};

/* Return Following, Followers */

exports.getFollowers = function(username, callback) {
	// HINT:
	// Query the DB to obtain the list of followers of user identified by username
	// If the query is successful:
	// Invoke callback(null, followers) where followers is a list of usernames
	// If the query fails:
	// Invoke callback(e, null)
    var getfollowerReq = "SELECT follower FROM twitter.ForwardFollowing WHERE username = ?";
    app.db.execute(getfollowerReq, [ username ], function(e, result) {
        if (result && result.rows.length > 0) {
            callback(null, _(result.rows).pluck('follower'));
        }
        else{
            callback(e, null);
        }
    });
};

exports.getFollowing = function(username, callback) {
	// HINT:
	// Query the DB to obtain the list of followings account of user identified by username
	// If the query is successful:
	// Invoke callback(null, follows) where follows is a list of persons that are followed by the username
	// If the query fails:
	// Invoke callback(e, null)
    var getfollowingReq = "SELECT have_follower FROM twitter.BackwardFollowing WHERE username = ?";
    app.db.execute(getfollowingReq, [ username ], function(e, result) {
        if (result && result.rows.length > 0) {
            callback(null, _(result.rows).pluck('have_follower'));
        }
        else{
            callback(e, null);
        }
    });
};

/* Follow user */

exports.follow = function(follower, followed, callback)
{
	// HINT:
	// Query the DB to insert the new connection (following relation)
	// from user identified by follower and the user identified by followed
	// If the query is successful:
	// Invoke callback(null, follow) where follow is the username of person who is followed by follower
	// If the query fails:
	// Invoke callback(e, null)
    var insertForwardFollowing = "INSERT INTO twitter.ForwardFollowing (username, follower, date) VALUES(?, ?, ?)";
    var insertBackwardFollowing = "INSERT INTO twitter.BackwardFollowing (username, have_follower, date) VALUES(?, ?, ?)";
    var date = new Date();
    var queries = [
        { query: insertBackwardFollowing, params: [followed, follower, date]},
        { query: insertForwardFollowing, params: [follower, followed, date]},
        ];
    app.db.batch(queries, { prepare: true}, function(e) {
        if (e == null) {
            callback(null, follower);
        }
        else{
            callback(e, null);
        }
    });
};

/* Unfollow user */

exports.unfollow = function(follower, followed, callback)
{
	// HINT:
	// Query the DB to delete the existing connection (following relation)
	// from user identified by follower and the user identified by followed
	// If the query is successful:
	// Invoke callback(null, follow) where follow is the username of person who is followed by follower
	// If the query fails:
	// Invoke callback(e, null)
    var deleteForwardFollowing = "DELETE FROM twitter.ForwardFollowing WHERE username=? AND follower=?";
    var deleteBackwardFollowing = "DELETE FROM twitter.BackwardFollowing WHERE username=? AND have_follower=?";
    var queries = [
        { query: deleteBackwardFollowing, params: [followed, follower]},
        { query: deleteForwardFollowing, params: [follower, followed]},
    ];
    app.db.batch(queries, { prepare: true}, function(e) {
        if (e == null) {
            callback(null, follower);
        }
        else{
            callback(e, null);
        }
    });
};


/* is Following */

exports.isFollowing = function(follower, followed, callback)
{
	// HINT:
	// Query to check if there is the following relation between two accounts.
	// If the query is successful:
	// Invoke callback(null, follow) where follower is the username of person who follows another one.
	// If the query fails:
	// Invoke callback(e, null)
    var isFollowingReq = "SELECT have_follower FROM twitter.BackwardFollowing WHERE username=? AND have_follower=?";
    app.db.execute(isFollowingReq, [ followed, follower ], function(e, result) {
        if (result && result.rows.length > 0) {
            callback(null, true);
        }
        else{
            callback(e, false);
        }
    });
};


/* get User tweets */

var getTweets = function(listTweetid, callback){
    var getTweetReq = "SELECT tweetid, username, author, body, dateOf(tweetid) AS created_at FROM twitter.Tweets WHERE tweetid IN ?";
    app.db.execute(getTweetReq, [ listTweetid ], function(e, result) {
        if (result && result.rows.length > 0) {
            callback(null, result.rows);
        }
        else{
            callback(e, null);
        }
    });
};

var getXLine = function(table, username, offset, callback, limit) {
    var offReq = '';
    if(limit != null){
        offReq = ' LIMIT ' + limit;
    }

    if (offset != 'null') {
        offReq = ' AND tweetid <  ' + offset;
    }

    var getTweetidReq = "SELECT tweetid FROM twitter." + table + " WHERE username=? " + offReq;
    app.db.execute(getTweetidReq, [ username ], function(e, result) {
        if (result && result.rows.length > 0) {
            var listTweetid = _(result.rows).map(function(n){return n.tweetid});
            getTweets(listTweetid, callback);
        }
        else{
            callback(e, null);
        }
    });
};

exports.getUserTimelines = function(username, offset, callback) {
	// HINT:
	// Query to get all the tweets from the followed accounts of a user indentified by username.
	// If the query is successful:
	// Invoke callback(null, tweets) where tweets are the feed from all followed accounts.
	// If the query fails:
	// Invoke callback(e, null)
    getXLine("Timeline", username, offset, callback, 10);
};

exports.getUserlines = function(username, callback) {
	// HINT:
	// Query to get all the tweets from the an account indentified by username.
	// If the query is successful:
	// Invoke callback(null, tweets) where tweets are all the tweet of the account identified by username.
	// If the query fails:
	// Invoke callback(e, null)
    getXLine("Userline", username, 'null', callback, null);
};

/* get User tweets */
exports.getUserInfo = function(username, callback) {
	// HINT:
	// Query to get information of a user indentified by username.
	// If the query is successful:
	// Invoke callback(null, userinfo).
	// If the query fails:
	// Invoke callback(e, null)

    var getUserInfoReq = "SELECT name FROM twitter.users WHERE username = ?";
    app.db.execute(getUserInfoReq, [ username ], function(e, result) {
        if (result.rows.length > 0) {
            callback(null, result.rows[0].name);
        }
        else{
            callback(e, null);
        }
    });
};

/* private encryption & validation methods */

var generateSalt = function()
{
	var set = '0123456789abcdefghijklmnopqurstuvwxyzABCDEFGHIJKLMNOPQURSTUVWXYZ';
	var salt = '';
	for (var i = 0; i < 10; i++) {
		var p = Math.floor(Math.random() * set.length);
		salt += set[p];
	}
	return salt;
};

var md5 = function(str) {
	return crypto.createHash('md5').update(str).digest('hex');
};

var saltAndHash = function(pass, callback)
{
	var salt = generateSalt();
	callback(salt + md5(pass + salt));
};

var validatePassword = function(plainPass, hashedPass, callback)
{
	var salt = hashedPass.substr(0, 10);
	var validHash = salt + md5(plainPass + salt);
	callback(null, hashedPass === validHash);
};
