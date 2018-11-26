import com.temboo.core.*;
import com.temboo.Library.Twitter.Search.*;

TembooSession session = new TembooSession(
  "katherine-yang", "climatechangedenial", "MNksrwJYgcp5BZfIvYMo67TBkIFwVlPp");

Tweet[] tweets;

Flock flock;

PFont font;

void setup() {
  size(1280, 720);
  runTweetsChoreo();
  flock = new Flock();
  for (Tweet t : tweets) {
    flock.addTweet(t);
  }

  font = createFont("data/LibreFranklin-Regular.ttf", 12);
  textFont(font);
}

// https://temboo.com/library/Library/Twitter/Search/Tweets/
void runTweetsChoreo() {
  Tweets tweetsChoreo = new Tweets(session);
  tweetsChoreo.setCredential("climatechangedenial");
  tweetsChoreo.setQuery("('climate change' OR 'global warming') (hoax OR conspiracy) -is:retweet");
  tweetsChoreo.setCount("100");
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
  flock.run();
}
