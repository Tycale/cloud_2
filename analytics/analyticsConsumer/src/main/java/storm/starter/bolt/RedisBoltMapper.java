package storm.starter.bolt;

import backtype.storm.tuple.ITuple;
import org.apache.storm.redis.common.mapper.RedisDataTypeDescription;
import org.apache.storm.redis.common.mapper.RedisStoreMapper;
import storm.starter.tools.Rankable;
import storm.starter.tools.Rankings;

public class RedisBoltMapper implements RedisStoreMapper {
    private RedisDataTypeDescription description;
    private final String hashKey = "trendings";

    public RedisBoltMapper() {
        description = new RedisDataTypeDescription(
                RedisDataTypeDescription.RedisDataType.STRING);
    }

    @Override
    public RedisDataTypeDescription getDataTypeDescription() {
        return description;
    }

    @Override
    public String getKeyFromTuple(ITuple tuple) {
        return "trendings";
    }

    @Override
    public String getValueFromTuple(ITuple tuple) {
        //return tuple.getStringByField("counter");
        Rankings rankableList = (Rankings) tuple.getValue(0);
        StringBuilder res = new StringBuilder();
        for (Rankable rank: rankableList.getRankings()){
            String word = rank.getObject().toString();
            Long count = rank.getCount();
            res.append(word + "\t" + Long.toString(count) + "\n");
        }
        return res.toString();
    }
}