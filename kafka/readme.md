# Install


Create a new topic with partitions :

kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic tweetscassandra
kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic tweetsanalytics


# Configuration kafka

advertised.host.name=localhost
advertised.port=9092