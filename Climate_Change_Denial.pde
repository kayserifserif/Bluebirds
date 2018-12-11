/****

An interactive visualisation of Tweets about climate change denial.

Instructions:
* Hover over birds to isolate them by changing their flocking behaviour.
* Hold down on birds to show their full Tweet.
* Hover over the a top word in the list to highlight Tweets containing that word.
* Hold down on a top word in the list to show full Tweets containing that word.

****/

import rita.*;
import java.util.*;
import java.text.*;

// SEARCH
String search_query = "(climate OR 'global warming')" +
  "(hoax OR conspiracy OR scam OR fake OR concept)" +
  "-is:retweet -'RT'";
int tweet_count = 100;

// AUTHENTICATION
String consumer_key, consumer_secret, access_token, access_secret;

// TWITTER4J
ConfigurationBuilder cb;
Twitter twitter;
AccessToken token;
Query query;
QueryResult query_result;

// TWEETS
Status[] statuses;
processing.data.JSONArray statuses_array;  // https://forum.processing.org/two/discussion/1537/jsonobject-is-ambiguous

// ANALYSIS
Analyser analyser;
String[] top_words;
boolean analyser_hovered;
String hovered_word = "";
boolean word_pressed;

// FLOCKING
Flock flock;
Tweet[] tweets_array;

// IMAGE
PShape bird;

// TEXT
PFont font;
float font_size_max = 12.0;
float font_size_min = 5.0;
SimpleDateFormat formatter;

// FEATURE
int featured_id;
boolean featuring = false;

// COLOR
color c_system, c_text, c_top_word, c_featured;
color c_bluebird;

void setup() {
  // settings
  size(1280, 720, P3D);
  colorMode(HSB, 360, 100, 100, 100);
  
  // color
  c_system = color(0, 0, 0, 50);
  c_text = color(0, 0, 0);
  c_top_word = color(0, 80, 80);
  c_featured = color(180, 10, 100, 50.0);
  c_bluebird = color(202.8, 88, 94.9);
  
  // text
  formatter = new SimpleDateFormat("MMM dd yyyy");

  // create tweets
  createTweets();

  // analyse tweets
  analyser = new Analyser();
  analyser.generateTopWords();
  top_words = analyser.getWordList();

  // create flock
  flock = new Flock();
  tweets_array = new Tweet[statuses_array.size()];
  for (int i = 0; i < statuses_array.size(); i++) {
    processing.data.JSONObject status = statuses_array.getJSONObject(i);
    tweets_array[i] = new Tweet(status);
    flock.addTweet(tweets_array[i]);
  }

  // set image
  bird = loadShape("Twitter_Logo_Blue.svg");

  // set typography
  font = createFont("data/LibreFranklin-Regular.ttf", font_size_max);
  textFont(font);
}

void createTweets() {
  // import authentication keys
  String[] properties = loadStrings("twitter4j.properties");
  consumer_key = split(properties[0], "=")[1];
  consumer_secret = split(properties[1], "=")[1];
  access_token = split(properties[2], "=")[1];
  access_secret = split(properties[3], "=")[1];
  
  // configuration
  // http://twitter4j.org/en/configuration.html
  cb = new ConfigurationBuilder();
  cb.setOAuthAccessToken(access_token)
    .setOAuthAccessTokenSecret(access_secret)
    .setOAuthConsumerKey(consumer_key)
    .setOAuthConsumerSecret(consumer_secret)
    .setDebugEnabled(true)
    .setTweetModeExtended(true);  // https://groups.google.com/forum/#!topic/twitter4j/5OtmkR8ap7I

  // set up Twitter
  TwitterFactory tf = new TwitterFactory(cb.build());
  twitter = tf.getInstance();
  query = new Query(search_query);
  query.setCount(tweet_count);
  try {
    query_result = twitter.search(query);
  } 
  catch (Exception e) {
    println(e);
  }
  List<Status> statuses_list = query_result.getTweets();
  //println(statuses_list);
  statuses = statuses_list.toArray(new Status[tweet_count]);  // http://javadevnotes.com/java-list-to-array-examples/
  statuses_array = new processing.data.JSONArray();

  // build array of statuses
  for (int i = 0; i < statuses.length; i++) {
    Status status_old = statuses[i];
    if (status_old != null) {
      String text = status_old.getText();
      text = text.replaceAll("(@\\w+ ){2,}(?=@)", "@… ");  // trim @ replies if more than two

      Date date = status_old.getCreatedAt();
      String timestamp = formatter.format(date);

      User user = status_old.getUser();
      String name = user.getName().trim();
      String username = user.getScreenName().trim();

      long id = status_old.getId();
      String url = "https://twitter.com/" + username + "/status/" + id;

      processing.data.JSONObject status_new = new processing.data.JSONObject();
      status_new.setInt("id", i);
      status_new.setString("text", text);
      status_new.setString("timestamp", timestamp);
      status_new.setString("name", name);
      status_new.setString("username", username);
      status_new.setString("url", url);

      statuses_array.setJSONObject(i, status_new);
    }
  }
}

void draw() {
  background(0, 0, 100);
  flock.run();
  analyser.displayTopWords();
}
