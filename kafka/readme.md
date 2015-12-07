# Install


Create a new topic with partitions :

kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic tweetscassandra
kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic tweetsanalytics


# Configuration kafka

advertised.host.name=localhost
advertised.port=9092

sudo /opt/kafka_2.10-0.9.0.0/bin/zookeeper-server-start.sh /home/vdbulcke/Documents/cloud_2/kafka/zoo.cfg 
sudo /opt/kafka_2.10-0.9.0.0/bin/kafka-server-start.sh /home/vdbulcke/Documents/cloud_2/kafka/kafka.properties 

