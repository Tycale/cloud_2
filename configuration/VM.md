#  For launching from INGI2145

# As the VM does not hold enough memory, create a swap file first

sudo dd if=/dev/zero of=/swapfile1 bs=1024 count=1048576
sudo chown root:root /swapfile1
sudo chmod 0600 /swapfile1
sudo mkswap /swapfile1
sudo swapon /swapfile1
sudo sh -c 'echo "/swapfile1 none swap sw 0 0" >> /etc/fstab'

# Launch Zookeeper
cd configuration
nohup sudo /usr/local/kafka_2.8.0-0.8.1.1/bin/zookeeper-server-start.sh zoo.cfg &
cd ..

# Launch Kafka
cd configuration
nohup sudo KAFKA_OPTS="-Xmx256M -Xms128M" /usr/local/kafka_2.8.0-0.8.1.1/bin/kafka-server-start.sh kafka.properties &
cd ..

# Create topics on Kafka
/usr/local/kafka_2.8.0-0.8.1.1/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic tweetscassandra
/usr/local/kafka_2.8.0-0.8.1.1/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic tweetsanalytics

# Verify that cassandra is running
service cassandra status

# Install Redis
sudo apt-get install redis-server
sudo service redis-server start

# Install Gradle
sudo add-apt-repository ppa:cwchien/gradle
sudo apt-get update
sudo apt-get install gradle

# Install nginx
sudo apt-get install nginx
sudo cat << EOF > /etc/nginx/sites-available/default
upstream ribbit {
        server localhost:3002;
    }
server {
    listen       80;
    server_name  ribbit;

    location / {
        proxy_pass http://ribbit;
    }
}
EOF
sudo service nginx restart


# Launch the nodeJS clusterised application
cd app
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g npm
npm install
timeout 2m node loader.js
NODE_ENV="production" nohup npm start &
cd ..

# Launch the cassandraConsumer
cd analytics/cassandraConsumer
gradle
nohup ./exec.sh &
cd ../..

# Launch the analyticsConsumer
cd analytics/analyticsConsumer
gradle
nohup ./exec.sh &



