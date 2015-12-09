/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import backtype.storm.Config;
import backtype.storm.LocalCluster;
import backtype.storm.StormSubmitter;
import backtype.storm.spout.SchemeAsMultiScheme;
import backtype.storm.topology.TopologyBuilder;
import backtype.storm.tuple.Fields;
import org.apache.storm.redis.bolt.RedisStoreBolt;
import org.apache.storm.redis.common.config.JedisClusterConfig;
import org.apache.storm.redis.common.config.JedisPoolConfig;

import storm.kafka.*;
import storm.starter.bolt.*;

import com.typesafe.config.ConfigFactory;

import java.net.InetSocketAddress;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;


public class AnalyticsConsumer {

    public AnalyticsConsumer() throws Exception {

        com.typesafe.config.Config conf = ConfigFactory.load();

        String zooKeeper = conf.getString("Zookeeper.address");
        String topic = conf.getString("Kafka.topic");
        int workers = conf.getInt("App.nbWorkers");

        TopologyBuilder builder = new TopologyBuilder();

        BrokerHosts hosts = new ZkHosts(zooKeeper);
        SpoutConfig spoutConfig = new SpoutConfig(hosts, topic, "/" + topic, UUID.randomUUID().toString());
        spoutConfig.scheme = new SchemeAsMultiScheme(new StringScheme());
        spoutConfig.stateUpdateIntervalMs = 2000;
        KafkaSpout kafkaSpout = new KafkaSpout(spoutConfig);


        RedisStoreBolt storeBolt = null;
        if(conf.getString("Redis.configuration").equals("single")){
            JedisPoolConfig poolConfig = new JedisPoolConfig.Builder()
                    .setHost(conf.getString("Redis.host")).setPort(conf.getInt("Redis.port")).build();
            RedisBoltMapper storeMapper = new RedisBoltMapper();
            storeBolt = new RedisStoreBolt(poolConfig, storeMapper);
        } else if(conf.getString("Redis.configuration").equals("cluster")){
            Set<InetSocketAddress> nodes = new HashSet<>();
            for (String hostPort : conf.getString("addresses").split(",")) {
                String[] host_port = hostPort.split(":");
                nodes.add(new InetSocketAddress(host_port[0], Integer.valueOf(host_port[1])));
            }
            JedisClusterConfig clusterConfig = new JedisClusterConfig.Builder().setNodes(nodes)
                    .build();
            RedisBoltMapper storeMapper = new RedisBoltMapper();
            storeBolt = new RedisStoreBolt(clusterConfig, storeMapper);
        }

        builder.setSpout("spout", kafkaSpout, conf.getInt("App.kafka_parallel"));
        builder.setBolt("split", new SplitSentence(), conf.getInt("App.split_parallel")).shuffleGrouping("spout");
        builder.setBolt("counter", new RollingCountBolt(conf.getInt("App.top_in_seconds"), conf.getInt("App.emit_in_seconds")), conf.getInt("App.counter_parallel") ).fieldsGrouping("split", new Fields("word"));
        builder.setBolt("intermediateRanker", new IntermediateRankingsBolt(conf.getInt("App.top_n")), conf.getInt("App.intermediateRanker_parallel"))
                .fieldsGrouping("counter", new Fields("obj"));
        builder.setBolt("totalRanker", new TotalRankingsBolt(conf.getInt("App.top_n"))).globalGrouping("intermediateRanker");
        builder.setBolt("redis", storeBolt).globalGrouping("totalRanker");

        Config stormConf = new Config();
        //stormConf.setDebug(true);

        if(!conf.getBoolean("App.local")){
            stormConf.setNumWorkers(workers);
            StormSubmitter.submitTopologyWithProgressBar(conf.getString("App.topologyName"), stormConf, builder.createTopology());

        } else {
            stormConf.setMaxTaskParallelism(3);
            LocalCluster cluster = new LocalCluster();
            cluster.submitTopology(conf.getString("App.topologyName"), stormConf, builder.createTopology());
            Thread.sleep(365 * 24 * 60 * 60 * 1000);
            cluster.shutdown();
        }
    }

    public static void main(String[] args) throws Exception {
        new AnalyticsConsumer();
    }
}