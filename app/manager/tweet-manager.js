var app = require('../app');
var uuid = require('node-uuid');
var async = require('async');
var config = require('config');
var TimeUuid = require('cassandra-driver').types.TimeUuid;
var kafka = require('kafka-node'),
    Producer = kafka.Producer,
    HighLevelProducer = kafka.HighLevelProducer;




/* add a tweet*/
exports.newTweet = function(data, callback)
{
    data.tweetid = new TimeUuid().toString();

    // HINT:
    // The data object at this point contains the new tweeet
    // It has these attributes:
    // - tweetid
    // - username
    // - name <- this is the fullname of username
    // - body

    // Need to initiate the process that will insert the tweet into the database
    // and process the tweet for the analytics. These can run in parallel, hence
    // we suggest you use async.parallel.
    // This function in the end must call callback(err, data)


    // tweetsanalytics

    var client = new kafka.Client(config.get('Zookeeper.address'));
    var producer = new HighLevelProducer(client);
    producer.on('error', function(err){
        console.log("Error Zookeeper :" + err);
    });

    async.parallel([
        function(cb){
            var payloads = [
                { topic: 'tweetscassandra', messages: JSON.stringify(data), partition: 0 },
                { topic: 'tweetsanalytics', messages: JSON.stringify(data), partition: 0 },
            ];
            producer.on('ready', function () {
                producer.send(payloads, cb);
            });
        },
        function(cb){
            var insertTweet = "INSERT INTO twitter.Tweets (tweetid, username, author, body) VALUES(?, ?, ?, ?);";
            app.db.execute(insertTweet, [ data.tweetid, data.username, data.name, data.body ], function(e, result) {
                if (e != null) {
                    cb(null, result);
                }
                else{
                    callback(e, null);
                }
            });
        },
        function(cb){
            var insertUserline = "INSERT INTO twitter.Userline (tweetid, username) VALUES(?, ?);";
            app.db.execute(insertUserline, [ data.tweetid, data.username], function(e, result) {
                if (e != null) {
                    cb(null, result);
                }
                else{
                    callback(e, null);
                }
            });
        }
    ], function(error, res){ callback(error, res)});

};
