import com.datastax.driver.core.*;
import com.datastax.driver.core.policies.ConstantReconnectionPolicy;
import com.datastax.driver.core.policies.DCAwareRoundRobinPolicy;
import com.datastax.driver.core.policies.DefaultRetryPolicy;
import com.datastax.driver.core.policies.TokenAwarePolicy;
import kafka.consumer.ConsumerIterator;
import kafka.consumer.KafkaStream;
import kafka.javaapi.consumer.ConsumerConnector;
import org.apache.log4j.Logger;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

import java.util.UUID;

public class ConsumerThread implements Runnable {
    private ConsumerConnector consumer;
    private KafkaStream<byte[], byte[]> stream;
    private int threadNumber;
    private long delay;

    private static Cluster cluster;
    private static Session session;
    private final PreparedStatement followerTimeLine;
    private final PreparedStatement userTimeline;
    private final PreparedStatement tweetinsert;
    private final PreparedStatement getFollowers;

    public ConsumerThread(ConsumerConnector consumer, KafkaStream<byte[], byte[]> stream, int threadNumber, long delay) {
        this.consumer = consumer;
        this.threadNumber = threadNumber;
        this.stream = stream;
        this.delay = delay;

        this.cluster = Cluster
                .builder()
                .addContactPoint("127.0.0.1") // TODO : Configuration file
                .withRetryPolicy(DefaultRetryPolicy.INSTANCE)
                .withLoadBalancingPolicy(
                        new TokenAwarePolicy(new DCAwareRoundRobinPolicy("datacenter1"))) // TODO : Configuration file
                .withReconnectionPolicy(new ConstantReconnectionPolicy(100L))
                .build();

        this.session = cluster.connect("twitter");

        followerTimeLine = session.prepare(
                "INSERT INTO twitter.Timeline (tweetid, username) "
                        + "VALUES(?, ?);");

        userTimeline = this.session.prepare(
                "INSERT INTO twitter.Userline (tweetid, username) "
                        + "VALUES(?, ?);");
        tweetinsert = this.session.prepare(
                "INSERT INTO twitter.Tweets (tweetid, username, author, body) "
                        + "VALUES(?, ?, ?, ?);");

        String cqlStatement = "SELECT have_follower FROM twitter.BackwardFollowing WHERE username=?;";
        getFollowers = session.prepare(cqlStatement);
    }

    public void run() {
        ConsumerIterator<byte[], byte[]> it = stream.iterator();

        while (it.hasNext()) {
            String msg = new String(it.next().message());
            Logger.getRootLogger().info(System.currentTimeMillis() + ",Thread " + threadNumber + ": " + msg);

            try {
                JSONObject json = (JSONObject)new JSONParser().parse(msg);

                UUID uuid = UUID.fromString((String) json.get("tweetid"));
                insertTweetToCassandra(uuid, (String)json.get("username"), (String)json.get("author"), (String)json.get("body"));

            } catch (ParseException e){
                Logger.getRootLogger().error("Cannot parse JSON : " + e + " : " + msg );
            }
        }

        cluster.close();
        System.out.println("Shutting down Thread: " + threadNumber);
    }



    public Boolean insertTweetToCassandra(UUID tweetid, String username, String author, String tweet) {

        // Batching improves perfs as we remove a lot of RTT between cassandra and our consumer
        // Unlogged batch improves perf but if cassandra fails, tweet are going to be duplicate if cassandra fails
        BatchStatement bs = new BatchStatement(BatchStatement.Type.UNLOGGED);


        // get followers that follow username
        // SELECT have_follower FROM twitter.BackwardFollowing WHERE username=?


        BoundStatement boundStatementFollowers = new BoundStatement(getFollowers);
        ResultSet FollowersList = session.execute(boundStatementFollowers.bind(username));


        // Insert the tweet

        BoundStatement boundStatement = new BoundStatement(tweetinsert);
        bs.add(boundStatement.bind(tweetid,username, author,tweet));


        // Insert the tweet in the userline

        BoundStatement timelinebind = new BoundStatement(userTimeline);
        bs.add(timelinebind.bind(tweetid,username));

        // Insert the tweet in timelines


        for (Row row : FollowersList) {
            String follower = row.getString("have_follower");
            BoundStatement followertimelinebind = new BoundStatement(followerTimeLine);
            bs.add(followertimelinebind.bind(tweetid,follower));
        }

        this.session.execute(bs);
        return true;
    }
}