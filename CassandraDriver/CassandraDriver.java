package driver.cassandra.cloud;

import com.datastax.driver.core.*;
import com.datastax.driver.core.policies.DCAwareRoundRobinPolicy;
import com.datastax.driver.core.policies.DefaultRetryPolicy;
import com.datastax.driver.core.policies.TokenAwarePolicy;
import com.datastax.driver.core.querybuilder.QueryBuilder;
import java.util.UUID;
import com.datastax.driver.core.utils.UUIDs;

public class CassandraDriver {
	public static Cluster cluster;
	public static Session session;
	public static ResultSet results;

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		
		
		//Row rows;

		// Connect to the cluster and keyspace "demo"
		cluster = Cluster
				.builder()
				.addContactPoint("127.0.0.1")
				.withRetryPolicy(DefaultRetryPolicy.INSTANCE)
				.withLoadBalancingPolicy(
						new TokenAwarePolicy(new DCAwareRoundRobinPolicy()))
				.build();
		session = cluster.connect("twitter");

		// TODO 
		// Call kafka driver and JSON parser here
		UUID uuids = com.datastax.driver.core.utils.UUIDs.timeBased();
		System.out.println(uuids.toString());
		insertTweetToCassandra(uuids , "exyxlaa", "Mary", "test driver cassandra tweet");
		// Clean up the connection by closing it
		cluster.close();
		

	}
	
	public static void insertTweetToCassandra(UUID tweetid, String username, String author, String tweet) {
		// get followers that follow username
		// SELECT have_follower FROM twitter.BackwardFollowing WHERE username=?
		Statement select = QueryBuilder.select().all().from("twitter", "BackwardFollowing")
				.where(QueryBuilder.eq("username", username));
		results = session.execute(select);
		
		
		PreparedStatement tweetinsert = session.prepare(
				"INSERT INTO twitter.Tweets (tweetid, username, author, body) "
            + "VALUES(?, ?, ?, ?);");
		BoundStatement boundStatement = new BoundStatement(tweetinsert);
		session.execute(boundStatement.bind(tweetid,username, author,tweet));
		
		PreparedStatement userTimeline = session.prepare(
				"INSERT INTO twitter.Userline (tweetid, username) "
        + "VALUES(?, ?);");
		BoundStatement timelinebind = new BoundStatement(userTimeline);
		session.execute(timelinebind.bind(tweetid,username));
		
		
		for (Row row : results) {
			
			String follower = row.getString("have_follower");
			PreparedStatement followerTimeLine = session.prepare(
					"INSERT INTO twitter.Timeline (tweetid, username) "
	        + "VALUES(?, ?);");
			BoundStatement followertimelinebind = new BoundStatement(followerTimeLine);
			session.execute(followertimelinebind.bind(tweetid,follower));
			
		}
		
		
		
		
		
		
	}

}
