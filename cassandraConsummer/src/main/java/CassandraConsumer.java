import kafka.consumer.ConsumerConfig;
import kafka.consumer.KafkaStream;
import kafka.javaapi.consumer.ConsumerConnector;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;


public class CassandraConsumer {
    private final ConsumerConnector consumer;
    private final String topic;
    private ExecutorService executor;
    private long delay;

    /**
     *
     * @param zookeeper
     * @param groupId
     * @param topic
     */
    public CassandraConsumer(String zookeeper, String groupId, String topic, long delay) {
        consumer = kafka.consumer.Consumer.createJavaConsumerConnector(createConsumerConfig(zookeeper, groupId));
        this.topic = topic;
        this.delay = delay;
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
            executor.submit(new ConsumerThread(consumer, stream, threadNumber, delay));
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
        long delay = Long.parseLong(args[4]);
        CassandraConsumer example = new CassandraConsumer(zooKeeper, groupId, topic,delay);
        example.run(threads);

        Thread.sleep(24*60*60*1000);

        example.shutdown();
    }
}