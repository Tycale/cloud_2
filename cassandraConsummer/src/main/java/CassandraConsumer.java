import kafka.consumer.ConsumerConfig;
import kafka.consumer.KafkaStream;
import kafka.javaapi.consumer.ConsumerConnector;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.logging.Logger;


public class CassandraConsumer {
    private final ConsumerConnector consumer;
    private final String topic;
    private ExecutorService executor;
    private String contactPoints;
    private String dcName;

    /**
     *
     * @param zookeeper
     * @param groupId
     * @param topic
     */
    public CassandraConsumer(String zookeeper, String groupId, String topic, String contactPoints, String dcName) {
        consumer = kafka.consumer.Consumer.createJavaConsumerConnector(createConsumerConfig(zookeeper, groupId));
        this.topic = topic;
        this.contactPoints = contactPoints;
        this.dcName = dcName;
    }

    public void shutdown() {
        if (consumer != null)
            consumer.shutdown();
        if (executor != null)
            executor.shutdown();
    }

    /**
     *
     * @param numThreads
     */
    public void run(int numThreads) {


        Map<String, Integer> topicCountMap = new HashMap<String, Integer>();
        topicCountMap.put(topic, new Integer(numThreads));
        Map<String, List<KafkaStream<byte[], byte[]>>> consumerMap = consumer.createMessageStreams(topicCountMap);
        List<KafkaStream<byte[], byte[]>> streams = consumerMap.get(topic);


        executor = Executors.newFixedThreadPool(numThreads);
        int threadNumber = 0;
        for (final KafkaStream<byte[], byte[]> stream : streams) {
            executor.submit(new ConsumerThread(consumer, stream, threadNumber, contactPoints, dcName));
            threadNumber++;
        }
    }

    /**
     * consumer
     *
     * @param zookeeper
     * @param groupId
     * @return
     */
    private static ConsumerConfig createConsumerConfig(String zookeeper, String groupId) {
        Properties props = new Properties();
        props.put("zookeeper.connect", zookeeper);
        props.put("auto.offset.reset", "largest");
        props.put("group.id", groupId);
        props.put("zookeeper.session.timeout.ms", "4000");
        props.put("zookeeper.sync.time.ms", "200");
        props.put("auto.commit.interval.ms", "1000");
        props.put("auto.commit.enable", "true");

        return new ConsumerConfig(props);
    }

    public static void main(String[] args) throws InterruptedException {
        String zooKeeper = args[0];
        String groupId = args[1];
        String topic = args[2];
        int threads = Integer.parseInt(args[3]);
        String contactPoints = args[4];
        String dcName = args[5];

        if(args.length != 6){
            System.err.println("Usage : java -jar casasndraConsumer.jar zookeeper_address kafka_group_id kafka_topic number_of_consumer_threads kafka_contactPoints kafka_datacenter_name");
            System.err.println("Exemple : java -jar casasndraConsumer.jar localhost:2181/ 0 tweetscassandra 1 127.0.0.1 datacenter1");
        }

        Logger.getGlobal().warning("Zookeeper : " + zooKeeper + " - groupID : " + groupId + " - topic : " + topic + " - threads: " + threads + " - contactPoints: " + contactPoints + " - datacenter name: " + dcName);

        CassandraConsumer threadedConsumers = new CassandraConsumer(zooKeeper, groupId, topic, contactPoints, dcName);
        threadedConsumers.run(threads);

        Thread.sleep(365*24*60*60*1000);
    }
}