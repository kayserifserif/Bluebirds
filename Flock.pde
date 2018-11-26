class Flock {
  ArrayList<Tweet> tweets; // An ArrayList for all the tweets

  Flock() {
    tweets = new ArrayList<Tweet>(); // Initialize the ArrayList
  }

  void run() {
    for (Tweet t : tweets) {
      t.run(tweets);  // Passing the entire list of tweets to each tweet individually
    }
  }

  void addTweet(Tweet t) {
    tweets.add(t);
  }

}
