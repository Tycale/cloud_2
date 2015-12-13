# Install


Create a new topic with partitions :

/usr/local/kafka_2.8.0-0.8.1.1/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic tweetscassandra
/usr/local/kafka_2.8.0-0.8.1.1/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic tweetsanalytics

#Floflo
/usr/local/Cellar/kafka/0.8.2.2/libexec/bin/zookeeper-server-start.sh zoo.cfg 
/usr/local/Cellar/kafka/0.8.2.2/libexec/bin/kafka-server-start.sh kafka.properties


# Configuration kafka

advertised.host.name=localhost
advertised.port=9092

# cedric
sudo /opt/kafka_2.10-0.9.0.0/bin/zookeeper-server-start.sh /home/vdbulcke/Documents/cloud_2/kafka/zoo.cfg 
sudo /opt/kafka_2.10-0.9.0.0/bin/kafka-server-start.sh /home/vdbulcke/Documents/cloud_2/kafka/kafka.properties 


# To execute on the VM INGI-2145

apt-get update
apt-get install zookeeper
apt-get install default-jre
cd /tmp/ && wget "http://mirror.cc.columbia.edu/pub/software/apache/kafka/0.8.2.1/kafka_2.11-0.8.2.1.tgz"
mkdir -p ~/kafka && cd ~/kafka
tar -xvzf /tmp/kafka_2.11-0.8.2.1.tgz --strip 1
echo "export PATH=\$PATH:/root/kafka/bin" >> ~/.bashrc
source ~/.bashrc