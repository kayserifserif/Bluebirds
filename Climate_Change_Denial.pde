// IMPORT
import com.temboo.core.*;
import com.temboo.Library.Twitter.Search.*;
import rita.*;
import java.util.*;
import java.text.*;

// TWEETS
TembooSession session = new TembooSession(
  "katherine-yang", "climatechangedenial", "MNksrwJYgcp5BZfIvYMo67TBkIFwVlPp");
String search_query = "('climate change' OR 'global warming') (hoax OR conspiracy) -is:retweet -'RT'";
int tweet_count = 100;
JSONArray statuses_array;

// TIMESTAMPS
SimpleDateFormat parser = new SimpleDateFormat("EEE MMM dd kk:mm:ss XX yyyy");
SimpleDateFormat formatter = new SimpleDateFormat("MMM dd yyyy");

// ANALYSIS
Analyser analyser;
String[] top_words;

// FLOCKING
Flock flock;
Tweet[] tweets_array;

// DISPLAY
PFont font;
int font_size = 12;

// FEATURE
int featured_id;
boolean featuring = false;

void setup() {
  size(1280, 720, P2D);
  colorMode(HSB, 360, 100, 100, 100);

  // get tweets
  runTweetsChoreo();

  // analyse tweets
  analyser = new Analyser();
  analyser.generateTopWords();
  top_words = analyser.getTopWords();

  // create flock
  flock = new Flock();
  tweets_array = new Tweet[statuses_array.size()];
  for (int i = 0; i < statuses_array.size(); i++) {
    JSONObject status = statuses_array.getJSONObject(i);
    //String text = status.getString("text");
    tweets_array[i] = new Tweet(status);
    flock.addTweet(tweets_array[i]);
  }

  // set typography
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
  statuses_array = new JSONArray();
  for (int i = 0; i < statuses.size(); i++) {
    JSONObject status = statuses.getJSONObject(i);
    
    String text = status.getString("text");
    String timestamp_input = status.getString("created_at");
    String timestamp;
    try {
      Date date = parser.parse(timestamp_input);
      timestamp = formatter.format(date);
    } catch(Exception e) {
      timestamp = "MMM dd yyyy";
    }
    JSONObject user = status.getJSONObject("user");
    String user_name = user.getString("name");
    String user_screen_name = "@" + user.getString("screen_name");
    
    JSONObject status_new = new JSONObject();
    status_new.setInt("id", i);
    status_new.setString("text", text);
    status_new.setString("timestamp", timestamp);
    status_new.setString("user_name", user_name);
    status_new.setString("user_screen_name", user_screen_name);
    
    statuses_array.setJSONObject(i, status_new);
  }
}

void draw() {
  background(0, 0, 100);
  flock.run();
  analyser.displayTopWords();
}
