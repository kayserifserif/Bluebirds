// IMPORT
import com.temboo.core.*;
import com.temboo.Library.Twitter.Search.*;
import rita.*;
import java.util.*;

// TWEETS
TembooSession session = new TembooSession(
  "katherine-yang", "climatechangedenial", "MNksrwJYgcp5BZfIvYMo67TBkIFwVlPp");
String search_query = "('climate change' OR 'global warming') (hoax OR conspiracy) -is:retweet -'RT'";
int tweet_count = 100;
String[] statuses_array;
Tweet[] tweets_array;

// ANALYSIS
Analyser analyser;
String[] top_words;

// FLOCKING
Flock flock;

// DISPLAY
PFont font;
int font_size = 12;

void setup() {
  size(1280, 720);
  //size(1280, 720, P3D);
  //camera();
  //lights();

  // Get Tweets
  runTweetsChoreo();

  // Analyse Tweets
  analyser = new Analyser();
  analyser.generateTopWords();
  top_words = analyser.getTopWords();

  // Create flock
  flock = new Flock();
  for (int i = 0; i < statuses_array.length; i++) {
    String text = statuses_array[i];
    flock.addTweet(new Tweet(text, top_words));
  }
  //for (Tweet t : tweets_array) {
  //  flock.addTweet(t);
  //}

  // Set typography
  font = createFont("data/LibreFranklin-Regular.ttf", font_size);
  textFont(font);
}

// https://temboo.com/library/Library/Twitter/Search/Tweets/
void runTweetsChoreo() {
  Tweets tweetsChoreo = new Tweets(session);
  tweetsChoreo.setCredential("climatechangedenial");
  tweetsChoreo.setQuery(search_query);
  tweetsChoreo.setCount(tweet_count);
  TweetsResultSet tweetsResults = tweetsChoreo.run();
  String results_str = tweetsResults.getResponse();
  JSONObject results = parseJSONObject(results_str);
  JSONArray statuses = results.getJSONArray("statuses");
  statuses_array = new String[statuses.size()];
  tweets_array = new Tweet[statuses.size()];
  for (int i = 0; i < statuses.size(); i++) {
    JSONObject status = statuses.getJSONObject(i);
    String text = status.getString("text");
    statuses_array[i] = text;
    //tweets_array[i] = new Tweet(text, top_words);
  }
}

void draw() {
  background(255);
  flock.run();
  analyser.displayTopWords();
}
