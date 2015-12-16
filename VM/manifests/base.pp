#-Global Execution params----

Exec {
          path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin:/usr/local/sbin:/sbin:/bin/sh",
          user => root,
		  #logoutput => true,
}

#--apt-update Triggers-----

exec { "apt-update":
    command => "sudo apt-get update -y",
}

Exec["apt-update"] -> Package <| |> #This means that an apt-update command has to be triggered before any package is installed

#--Hadoop configuration constants----

#$hconfig1 = '<?xml version="1.0" encoding="UTF-8"?>
#<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
#<configuration>
#<property>
#  <name>fs.default.name</name>
#  <value>hdfs://localhost:9000</value>
#</property>
#<property>
#  <name>hadoop.tmp.dir</name>
#  <value>/usr/local/hadoop/data</value>
#</property>
#</configuration>'
#
#$hconfig2 = '<?xml version="1.0"?>
#<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
# 
#<configuration>
#    <property>
#        <name>mapreduce.framework.name</name>
#        <value>yarn</value>
#    </property>
#</configuration>'
#
#$hconfig3 = '<?xml version="1.0" encoding="UTF-8"?>
#<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
# 
#<configuration>
#    <property>
#        <name>dfs.replication</name>
#        <value>3</value>
#    </property>
#</configuration>'
#
#$hconfig4 = '<?xml version="1.0"?>
#<configuration>
#    <property>
#        <name>yarn.nodemanager.aux-services</name>
#        <value>mapreduce_shuffle</value>
#    </property>
#    <property>
#        <name>yarn.nodemanager.aux-services.mapreduce_shuffle.class</name>
#        <value>org.apache.hadoop.mapred.ShuffleHandler</value>
#    </property>
#    <property>
#        <name>yarn.resourcemanager.resource-tracker.address</name>
#        <value>localhost:8025</value>
#    </property>
#    <property>
#        <name>yarn.resourcemanager.scheduler.address</name>
#        <value>localhost:8030</value>
#    </property>
#    <property>
#        <name>yarn.resourcemanager.address</name>
#        <value>localhost:8050</value>
#    </property>
#</configuration>'

#--Miscellaneous Execs-----

exec {"fix guest addition issues": #presumed to be necessary because of a vagrant bug regarding auto-mounting
     #command => "ln -s /opt/VBoxGuestAdditions-4.3.10/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions",
	 command => 'echo "#!/bin/sh -e" | tee /etc/rc.local && echo "mount -t vboxsf -o rw,uid=1000,gid=1000 vagrant /vagrant" | tee -a /etc/rc.local && echo "exit 0" | tee -a /etc/rc.local',
	 refreshonly => true,
	 #notify => Exec["restart system"]
}


#exec {"restart system":
#     command => "shutdown -r now",
#	 refreshonly => true,
#}

#exec {"set hadoop permissions":
#     command => "chown -R vagrant /usr/local/hadoop/",
#     user => root,
 	 #require => User["hduser"],
#     subscribe => Exec["install hadoop"],
 #    refreshonly => true,
#}

exec {"set kafka permissions":
     command => "chown -R vagrant /usr/local/kafka/",
     user => root,
     require => User["vagrant"],
 	 #require => User["hduser"],
     subscribe => Exec["install kafka"],
     refreshonly => true,
}

#exec {"set hadoop env":
#    environment => 'HOME=/home/vagrant',
#     command => 'echo "export HADOOP_HOME=/usr/local/hadoop" | tee -a .bashrc && echo "export JAVA_HOME=/usr" | tee -a .bashrc && echo "export HADOOP_OPTS=\"$HADOOP_OPTS -Djava.library.path=/usr/local/hadoop/lib/native\"" | tee -a .bashrc && echo "export HADOOP_COMMON_LIB_NATIVE_DIR=\"/usr/local/hadoop/lib/native\"" | tee -a .bashrc',
#     require => Package["default-jdk"],
#	 user => vagrant,
#     subscribe => Exec["install hadoop"],
#     refreshonly => true,
#}

#exec {"configure hadoop  1":
 #    command => 'sed -i \'s/${JAVA_HOME}/\/usr/\' /usr/local/hadoop/etc/hadoop/hadoop-env.sh && sed -i \'/^export HADOOP_OPTS/ s/.$/ -Djava.library.path=$HADOOP_PREFIX\/lib"/\' /usr/local/hadoop/etc/hadoop/hadoop-env.sh && echo \'export HADOOP_COMMON_LIB_NATIVE_DIR=${HADOOP_PREFIX}/lib/native\' | tee -a /usr/local/hadoop/etc/hadoop/hadoop-env.sh',
  #   subscribe => Exec["install hadoop"],
 #    refreshonly => true,
#}

#exec {"configure hadoop 2":
#      command => 'echo \'export HADOOP_CONF_LIB_NATIVE_DIR=${HADOOP_PREFIX:-"/lib/native"}\' | tee -a /usr/local/hadoop/etc/hadoop/yarn-env.sh && echo \'export HADOOP_OPTS="-Djava.library.path=$HADOOP_PREFIX/lib"\' | tee -a /usr/local/hadoop/etc/hadoop/yarn-env.sh',
#      subscribe => Exec["install hadoop"],
#      refreshonly => true,
#}

#exec {"configure hadoop 3":
#      command => "echo \'${hconfig1}\' | tee /usr/local/hadoop/etc/hadoop/core-site.xml && echo '${hconfig2}' | tee /usr/local/hadoop/etc/hadoop/mapred-site.xml && echo '${hconfig3}' | tee /usr/local/hadoop/etc/hadoop/hdfs-site.xml && echo '${hconfig4}' | tee /usr/local/hadoop/etc/hadoop/yarn-site.xml",
#      subscribe => Exec["install hadoop"],
#      refreshonly => true,
#}
#exec {"configure hadoop 4" :
#      command => "sudo rm -rf /usr/local/hadoop/data && /usr/local/hadoop/bin/hadoop namenode -format",
#      subscribe => Exec["install hadoop"],
#      refreshonly => true,
#}

exec {"configure localhost ssh":
      command => "cat /dev/zero | ssh-keygen -q -N \"\" && cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys && chmod og-wx /home/vagrant/.ssh/authorized_keys",
      user => vagrant,
      refreshonly => true,
}

#exec {"configure spark logs":
 #     command => "sed -i 's/INFO, console/WARN, console/g' /usr/local/spark/conf/log4j.properties.template && mv /usr/local/spark/conf/log4j.properties.template /usr/local/spark/conf/log4j.properties",
#      subscribe => Exec["install spark"],
#      refreshonly => true,
#}

exec {"configure cassandra":
      command => 'sudo sed -i \'s/MAX_HEAP_SIZE=\"\${max_heap_size_in_mb}M\"/MAX_HEAP_SIZE=\"256M\"/g\' /etc/cassandra/cassandra-env.sh',
      subscribe => Exec["install cassandra"],
      refreshonly => true,
}

#exec {"install boto":
#      command => "pip install boto",
#      subscribe => Package["python-pip"],
#      refreshonly => true,
#}

#--Disabling IPv6 (for Hadoop)---

exec {"disable ipv6":
     command => "echo 'net.ipv6.conf.all.disable_ipv6 = 1' | tee -a /etc/sysctl.conf && echo 'net.ipv6.conf.default.disable_ipv6 = 1' | tee -a /etc/sysctl.conf && echo 'net.ipv6.conf.lo.disable_ipv6 = 1' | tee -a /etc/sysctl.conf",
      refreshonly => true,
}

#--Users and Groups---------------

#vagrant already preconfigs a user called 'vagrant'. However, you can add your own users as shown below. Refer to the puppet type reference documentation (docs.puppetlabs.com/references/latest/type.html) for additional details.
#user { "student":
#     name => "student",
#     ensure => present,
#     groups => ["sudo"]	 
#}

#--Hadoop Installation-----------
 
#exec { "install hadoop":
#    command => "wget http://perso.uclouvain.be/marco.canini/ingi2145/hadoop-2.6.0.tar.gz && tar -xzf hadoop-2.6.0.tar.gz && mv hadoop-2.6.0/ /usr/local && cd /usr/local && ln -s hadoop-2.6.0/ hadoop",
	#command => "wget http://blog.woopi.org/wordpress/files/hadoop-2.4.0-64bit.tar.gz && tar -xzf hadoop-2.4.0-64bit.tar.gz && mv hadoop-2.4.0/ /usr/local && cd /usr/local && ln -s hadoop-2.4.0/ hadoop",
 #   creates => "/usr/local/hadoop",
 #   require => Package["default-jdk"],
 #   timeout => 600,
 #   tries => 3,
 #   try_sleep => 60,
#}

#--Kafka Installation------------
#Change the permissions to the /usr/local/kafka?
exec { "install kafka":
    command => "wget http://perso.uclouvain.be/marco.canini/ingi2145/kafka_2.8.0-0.8.1.1.tgz && tar -xzf kafka_2.8.0-0.8.1.1.tgz && sudo mv kafka_2.8.0-0.8.1.1/ /usr/local && cd /usr/local && sudo ln -s kafka_2.8.0-0.8.1.1/ kafka",
    creates => "/usr/local/kafka",
    require => Package["default-jdk"],
    timeout => 600,
    tries => 3,
    try_sleep => 60,
}

#--Apache Spark Installation-----

#exec { "install spark":
 #   command => "wget http://perso.uclouvain.be/marco.canini/ingi2145/spark-1.4.1-bin-hadoop2.6.tgz && tar -xzf spark-1.4.1-bin-hadoop2.6.tgz && mv spark-1.4.1-bin-hadoop2.6/ /usr/local && cd /usr/local && ln -s spark-1.4.1-bin-hadoop2.6/ spark",
#  creates => "/usr/local/spark",
#    require => Package["default-jdk"],
#   timeout => 600,
#  tries => 3,
# try_sleep => 60,
#}

#--Cassandra Installation-----

exec { "install cassandra":
    command => 'echo "deb http://debian.datastax.com/community stable main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list && curl -L http://debian.datastax.com/debian/repo_key | sudo apt-key add - && sudo apt-get update && sudo apt-get install dsc20=2.0.11-1 cassandra=2.0.11 -y && sudo service cassandra stop && sudo rm -rf /var/lib/cassandra/data/system/* && sudo service cassandra start',
    creates => "/etc/cassandra",
    require => Package["default-jdk"],
    timeout => 600,
    tries => 3,
    try_sleep => 60,
}

#--Packages----

#package { "lubuntu-desktop":
#  ensure => present,
#  notify => Exec["fix guest addition issues"],
# install_options => ['--no-install-recommends'],
#}

package { "git":
   ensure => present,
}

package { "ssh":
   ensure => present,
}

#package { "eclipse":
#   ensure => present,
#}

#package { "maven2":
#   ensure => present,
#   require => Package["default-jdk"],
#}

#package { "python-pip":
#   ensure => present,
#}

package { "awscli":
   ensure => present
}

package { ["nodejs", "npm", "nodejs-legacy"]:
   ensure => present
}

package { "default-jdk":
   ensure => present,
}

#package { "memcached":
#  ensure => present
#}

package { "mongodb":
   ensure => purged
   #ensure => absent #If purged does not work
}

# change for the project HW2

exec{"overcommit":
    command => "sysctl vm.overcommit_memory=1 && echo \"vm.overcommit_memory=1\" >> /etc/sysctl.conf"
}

exec{ "add_swap":
    command => "sudo dd if=/dev/zero of=/swapfile1 bs=1024 count=2048576 && sudo chown root:root /swapfile1 && sudo chmod 0600 /swapfile1 && sudo mkswap /swapfile1 && sudo swapon /swapfile1 && sudo sh -c 'echo \"/swapfile1 none swap sw 0 0\" >> /etc/fstab'",
    onlyif => ["test ! -f /swapfile1"]
}

package { "nginx":
   ensure => present
}

exec { "gradle_install":
    command => "sudo add-apt-repository ppa:cwchien/gradle",
    timeout => 600,
    tries => 3,
    try_sleep => 60,
}

package { "gradle":
   require => Exec["gradle_install"],
   ensure => present
}

file { "id_rsa":
path => "/home/vagrant/.ssh/id_rsa",
mode => 600,
require => [Package["git"], Exec["overcommit"]],
owner => 'vagrant',
group => 'vagrant',
content => "-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAxVV6uYQMvht3K9w1UQYeDL9uPVcGjR6Sjr57yw/EUy5LqNBe
nwQSEO66lPw5btdWLHgG2sghg+zPNVfk8E6KDwUNOvzeqn9tNufdhJmnc99pHsn5
m/6tXe46Rs4OFbjtr0J2mipmXHlG/Lms27M453MsZpWgpOKzb4CBVK92E6nmc/YS
mAtiVgWSBbUlMgLxRtsNid6DxkSNoce5jcNzQBGu/maQwYYfzOFw3tdaQFwEeSna
OPZI2CQIOVkZKge1mqwS4DVOAeolPEAWRko3NwITWp2AQ1Z7WI9cza2K6gNNavio
YJmAbpai8jMPne/U9OOAjSPZyCHPHu79WcxYnQIDAQABAoIBADyYDuNAZRlLHcDe
EZEbq8aGUbeMLXrP1Hj4jNLBuKtCIAFqWmPBwDpq0+hDuu8KOG/XO2Oa6I+1+7qJ
jscrlsEd7/4Y/9ai4kpl0GOTOxQdmg3WP0tjXKDnMgXj5/dLndCfPAQC2QO0SdP4
v9eGpQaNGyk08OswoaCveQckCcHnc89nPDZR4oRAxGPW1tNZHQulGNUN2kVLQSvY
kOm9wDKdQOR92n1/tBTjODhZK6wa9b/dSVHunm5xtkH7yYn/0E0rYpohOjAX67VZ
kEoVxgLI9dXBNNYKVdWd9i+/8hiYTnhV0cP4WUy5rNrwCpBle9wyDPswABBRtts7
hLTcxJECgYEA4aYqsVUT0BxR4s1sBd9szAQVgM7NLTYjClzED8lICQLWuzmU/Zj/
muUh0zoNVYq2cYEs/8gO6gdNvGUHkKR0M8ZYWkXfCbsQfor0aaG7D3sVzlcoxg7I
WCProBlx2O+PWWGPb0AkeJGE37tqakKzdGDoHuVkTQYSoYeg1gAOFqMCgYEA3+BU
HIw2z1yEGWh7quwBDIV0Ou6UX9W4tc8xzkXzBRN8jHN4YyGt1TGKOU4QcTrhPPAc
5T0NoYMIaJU/HoGxF7kBi6cPbnF28A1HVA6tlTr+oYmzlnFsdBzUB25+iLRArG8g
IFLBSlsflUHqhBKFcbRsBlpKHi6SxqO95ZpZB78CgYEAqFGBCyKBUv2s/1doOsE8
sLpjJ+AbIJx/at1jyrrEJySc9K+xObIFCI/euWdWRvbfvK80199tcJjeHafnCrgB
jhVoFn6ELwgA98PDKYBgvt17mJ1fZs3kGAtDWftg9wdLkMq7aasZCW7TBOkSKg1z
O16GB3XpaaMcBq3bBYao+60CgYBqAZbSTbJGTdBfF5I3RLjabPa0UPQAzPpBXHKA
8a444RlAiAyhI/lj0alZqRUwCGlOqYOFKHuj1p/MpZ7VmyN30CpjLh+odCGVWTRF
IQ4gc2bOpp1axypLcLsVKcTQhkl5XMUhiQ3tX2h9DFE3aG23gW8FMwuVbwgg9rec
WJF/kQKBgQCF2iL9T04vqTcgEz8e2/XHA4JCPVH8LRe8NTLsocbEP/azrDD5QGcu
4MaJrqzWJ+1s3RaF8D97N0TEBBd5jS9ebxiP167TIr6iLa7ZZnSHPdc7W5T7eFTl
hCfIBC66nzyb2elO4efBw7LoyOVXUNcjcqgy7T4P5sKx64lfvvwqUg==
-----END RSA PRIVATE KEY-----"
}

package {"redis-server":
    ensure => present
}

exec{"run_redis":
  command => "sudo service redis-server start &&  sudo update-rc.d redis-server defaults",
  require => Package["redis-server"]
}

file { "default":
path => "/etc/nginx/sites-available/default",
mode => 644,
require => Package["nginx"],
owner => 'root',
group => 'root',
content => "upstream ribbit {
        server localhost:3002;
    }
server {
    listen       80;
    server_name  ribbit;

    location / {
        proxy_pass http://ribbit;
    }
}"
}

exec{"nginx_restart":
    command => "sudo service nginx restart",
    require => File["default"]
}

group { 'vagrant':
  name => "vagrant",
  ensure => present,
}

user {"vagrant":
  name => "vagrant",
  ensure => present,
  require => Group["vagrant"]
}

exec{"vagrant_home":
    command => "mkdir -p /home/vagrant/.ssh/ && chown -R vagrant:vagrant /home/vagrant/",
    onlyif => ["test ! -d /home/vagrant/"],
    require => User["vagrant"],
}

exec{"know_github":
  command => "echo \"github.com,204.232.175.90 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==\" >> .ssh/known_hosts",
  cwd => "/home/vagrant/",
  require => [Package["git"], Exec["vagrant_home"]]
}

exec{"git_clone_1":
    command => "chown -R vagrant:vagrant /home/vagrant/",
    user => "root",
    require => [User["vagrant"]],
}

exec{"git_clone":
    command => "git clone git@github.com:Tycale/cloud_2.git",
    cwd => "/home/vagrant/",
    user => "vagrant",
    require => [Exec["know_github"], File["id_rsa"], Exec["vagrant_home"], Exec["vagrant_home"], Exec["git_clone_1"]],
    onlyif => ["test ! -d /home/vagrant/cloud_2/"]
}

file{"config_zookeeper":
    path => "/etc/zoo.cfg",
    content => "
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/usr/local/var/run/zookeeper/data
clientPort=2181
maxClientCnxns=600
    "
}

file{"zookeeper_deamon":
    path => "/etc/init.d/zookeeper",
    mode => 755,
    content => "
#! /bin/sh
# /etc/init.d/blah
#

# Some things that run always
touch /var/lock/zookeeper

# Carry out specific functions when asked to by the system
case \"\$1\" in
  start)
     JAVA_OPTS=\"-Xms256m -Xmx256m\" /usr/local/kafka_2.8.0-0.8.1.1/bin/zookeeper-server-start.sh /etc/zoo.cfg >> /var/log/zoo.log 2>&1 &
    ;;
  stop)
    sudo pkill zookeeper-server-start.sh
    ;;
  *)
    echo \"Usage: /etc/init.d/zookeeper {start|stop}\"
    exit 1
    ;;
esac

exit 0
    "
}

file{"config_kafka":
    path => "/etc/kafka.properties",
    content => "
broker.id=0
port=9092
advertised.host.name=localhost
advertised.port=9092
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=/usr/local/var/lib/kafka-logs
num.partitions=1
num.recovery.threads.per.data.dir=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
log.cleaner.enable=false
zookeeper.connect=localhost:2181
zookeeper.connection.timeout.ms=6000
auto.create.topics.enable=true
    "
}

file{"kafka_deamon":
    path => "/etc/init.d/kafka",
    mode => 755,
    content => "
#! /bin/sh
# /etc/init.d/blah
#

# Some things that run always
touch /var/lock/kafka

# Carry out specific functions when asked to by the system
case \"\$1\" in
  start)
     sleep 40 && KAFKA_OPTS=\"-Xms256m -Xmx256m\" /usr/local/kafka_2.8.0-0.8.1.1/bin/kafka-server-start.sh /etc/kafka.properties >> /var/log/kafka.log 2>&1 &
    ;;
  stop)
    sudo pkill kafka-server-start.sh
    ;;
  *)
    echo \"Usage: /etc/init.d/kafka {start|stop}\"
    exit 1
    ;;
esac

exit 0
    "
}

exec{"kafka_topics":
  command => "/usr/local/kafka_2.8.0-0.8.1.1/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic tweetscassandra && /usr/local/kafka_2.8.0-0.8.1.1/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic tweetsanalytics && touch /home/vagrant/.topics",
  require => [Exec["launch_kafka"], Exec["vagrant_home"]],
  creates => "/home/vagrant/.topics"
}

exec {'ln_node':
    command => "ln -fs /usr/bin/nodejs /usr/bin/node",
    require => [Package["nodejs"], Package["nodejs-legacy"]],
    onlyif => ["test ! -f /usr/bin/node"]
}

exec{"update_npm":
  require => [Exec["kafka_topics"], Exec["ln_node"]],
  cwd => "/home/vagrant/cloud_2/app/",
  command => "sudo npm install -g npm && npm install",
  timeout => 1000,
  tries => 3,
  try_sleep => 60,
}

exec{"config_app":
  require => [Exec["update_npm"], Exec["install cassandra"]],
  cwd => "/home/vagrant/cloud_2/app/",
  command => "node loader.js",
  timeout => 700
}

file{"twitter_analytics":
    path => "/etc/init.d/twitter_analytics",
    mode => 755,
    content => "
#! /bin/sh
# /etc/init.d/blah
#

# Some things that run always
touch /var/lock/twitter_analytics

# Carry out specific functions when asked to by the system
case \"\$1\" in
  start)
    sleep 50 && cd /home/vagrant/cloud_2/analytics/analyticsConsumer/ && GRADLE_OPTS=\"-Xms256m -Xmx256m\" gradle run >> /var/log/analyticsConsumer.log 2>&1 &
    ;;
  stop)
    pkill analyticsConsumer
    ;;
  *)
    echo \"Usage: /etc/init.d/twitter_analytics {start|stop}\"
    exit 1
    ;;
esac

exit 0
    "
}

exec{"launch_twitter_analytics1":
    require => [Exec["kafka_topics"], Exec["config_app"]], 
    command => "sudo update-rc.d twitter_analytics defaults",
    tries => 3,
    try_sleep => 60,
    timeout => 480, 
}

exec{"launch_twitter_analytics_first_fail":
    require => [Exec["kafka_topics"], Exec["config_app"], Exec["launch_twitter_analytics1"]], 
    command => "sudo /etc/init.d/twitter_analytics start && sleep 180",
    tries => 3,
    try_sleep => 60,
    timeout => 480, 
}

exec{"launch_twitter_analytics":
    require => [Exec["kafka_topics"], Exec["config_app"], Exec["launch_twitter_analytics1"], Exec["launch_twitter_analytics_first_fail"]], 
    command => "sudo /etc/init.d/twitter_analytics start",
    tries => 3,
    try_sleep => 60,
    timeout => 480, 
}

file{"twitter_cassandra":
    path => "/etc/init.d/twitter_cassandra",
    mode => 755,
    content => "
#! /bin/sh
# /etc/init.d/blah
#

# Some things that run always
touch /var/lock/twitter_cassandra

# Carry out specific functions when asked to by the system
case \"\$1\" in
  start)
    sleep 60 && cd /home/vagrant/cloud_2/analytics/cassandraConsumer/ && GRADLE_OPTS=\"-Xms512m -Xmx512m\" gradle run -Dexec.args=\"localhost:2181/ 0 tweetscassandra 1 127.0.0.1 datacenter1\" >> /var/log/cassandraConsumer.log 2>&1 &
    ;;
  stop)
    pkill cassandraConsumer
    ;;
  *)
    echo \"Usage: /etc/init.d/twitter_cassandra {start|stop}\"
    exit 1
    ;;
esac

exit 0
    "
}

exec{"launch_twitter_cassandra1":
    require => [Exec["kafka_topics"], Exec["config_app"]], 
    command => "sudo update-rc.d twitter_cassandra defaults",
    tries => 3,
    timeout => 480, 
    try_sleep => 60,
}

exec{"launch_twitter_cassandra":
    require => [Exec["kafka_topics"], Exec["config_app"], Exec["launch_twitter_cassandra1"]], 
    command => "sudo /etc/init.d/twitter_cassandra start ",
    tries => 3,
    timeout => 480, 
    try_sleep => 60,
}


file{"deamon_app":
    path => "/etc/init.d/ribbit",
    mode => 755,
    content => "
#! /bin/sh
# /etc/init.d/blah
#

# Some things that run always
touch /var/lock/ribbit

# Carry out specific functions when asked to by the system
case \"\$1\" in
  start)
    cd /home/vagrant/cloud_2/app/ && NODE_ENV=\"production\" npm start >> /var/log/ribbit.log 2>&1 &
    ;;
  stop)
    pkill node
    ;;
  *)
    echo \"Usage: /etc/init.d/ribbit {start|stop}\"
    exit 1
    ;;
esac

exit 0
    "
}

exec{"launch_app1":
    command => "sudo update-rc.d ribbit defaults",
    timeout => 480,
    tries => 3,
    try_sleep => 60,
}

exec{"launch_app":
    require => [Exec["launch_twitter_cassandra"], File["deamon_app"], Exec["run_redis"], Exec["launch_app1"]], 
    command => "sudo /etc/init.d/ribbit start",
    timeout => 480,
    tries => 3,
    try_sleep => 60,
}

exec{"launch_kafka1":
    require => [Exec["install kafka"], Exec["git_clone"], File["config_kafka"], File["kafka_deamon"], Exec["launch_zookeeper"]],
    command => "sudo update-rc.d kafka defaults",
    tries => 3,
    try_sleep => 60, 
}

exec{"launch_kafka":
    require => [Exec["install kafka"], Exec["git_clone"], File["config_kafka"], File["kafka_deamon"], Exec["launch_zookeeper"], Exec["launch_kafka1"]],
    command => "sudo /etc/init.d/kafka start",
    tries => 3,
    try_sleep => 60, 
}

exec{"launch_zookeeper1":
    require => [Exec["install kafka"], Exec["git_clone"], File["config_zookeeper"], File["zookeeper_deamon"]],
    command => "sudo update-rc.d zookeeper defaults",
    timeout => 480,
    tries => 3,
    try_sleep => 60,
}

exec{"launch_zookeeper":
    require => [Exec["install kafka"], Exec["git_clone"], File["config_zookeeper"], File["zookeeper_deamon"], Exec["launch_zookeeper1"]],
    command => "sudo /etc/init.d/zookeeper start",
    timeout => 480,
    tries => 3,
    try_sleep => 60,
}
