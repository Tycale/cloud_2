# Install


Create a new topic with partitions :

kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic tweetscassandra
kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic tweetsanalytics

#Floflo
/usr/local/Cellar/kafka/0.8.2.2/libexec/bin/zookeeper-server-start.sh zoo.cfg 
/usr/local/Cellar/kafka/0.8.2.2/libexec/bin/kafka-server-start.sh kafka.properties

