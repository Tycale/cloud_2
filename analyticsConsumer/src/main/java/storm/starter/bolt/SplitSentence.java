package storm.starter.bolt;

import java.text.BreakIterator;

import backtype.storm.topology.BasicOutputCollector;
import backtype.storm.topology.OutputFieldsDeclarer;
import backtype.storm.topology.base.BaseBasicBolt;
import backtype.storm.tuple.Fields;
import backtype.storm.tuple.Tuple;
import backtype.storm.tuple.Values;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

//There are a variety of bolt types. In this case, we use BaseBasicBolt
public class SplitSentence extends BaseBasicBolt {

    //Execute is called to process tuples
    @Override
    public void execute(Tuple tuple, BasicOutputCollector collector) {
        //Get the sentence content from the tuple
        String sentence = tuple.getString(0);

        try {
            JSONObject json = (JSONObject) new JSONParser().parse(sentence);

            String split[]= StringUtils.split((String)json.get("body"));

            //Iterate over each word and emit it to the output stream
            for (String word : split) {

                // if hashtag word
                if (word.startsWith("#")) {
                    // emit it

                    collector.emit(new Values(word));
                }
            }

        } catch (ParseException e) {
            Logger.getRootLogger().error("Cannot parse JSON : " + e + " : " + sentence);
        }


    }

    //Declare that emitted tuples will contain a word field
    @Override
    public void declareOutputFields(OutputFieldsDeclarer declarer) {
        declarer.declare(new Fields("word"));
    }
}