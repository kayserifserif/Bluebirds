import com.temboo.core.*;
import com.temboo.Library.Twitter.Search.*;
import java.util.*;

TembooSession session = new TembooSession(
  "katherine-yang", "myFirstApp", "MNksrwJYgcp5BZfIvYMo67TBkIFwVlPp");

Tweet[] tweets;

PFont font;

void setup() {
  size(1280, 720);
  runTweetsChoreo();
  
  font = createFont("data/LibreFranklin-Regular.ttf", 12);
  textFont(font);
}

void runTweetsChoreo() {
  Tweets tweetsChoreo = new Tweets(session);
  tweetsChoreo.setCredential("climatechangedenial");
  TweetsResultSet tweetsResults = tweetsChoreo.run();
  String results_str = tweetsResults.getResponse();
  JSONObject results = parseJSONObject(results_str);
  JSONArray statuses = results.getJSONArray("statuses");
  tweets = new Tweet[statuses.size()];
  for (int i = 0; i < statuses.size(); i++) {
    String text = statuses.getJSONObject(i).getString("text");
    tweets[i] = new Tweet(text);
  }
}

void draw() {
  background(255);
  for (Tweet t : tweets) {
    t.update();
    t.display();
  }
}
