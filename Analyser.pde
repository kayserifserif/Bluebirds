class Analyser {
  
  // CONTENT
  String[] statuses_array;

  // ANALYSIS
  String[] wordsToIgnore = {"rt", "//t", "https", "co", "climate", "change", "hoax", "conspiracy", "global", "warming", "…"};

  // WORDS
  int num_top_words = 10;
  String[] top_words = new String[num_top_words];

  // DISPLAY
  float padding = 30.0; 
  PVector pos = new PVector(padding, padding);
  float list_padding = 20.0;
  color c = color(0, 50);
  
  Analyser(String[] statuses_array) {
    this.statuses_array = statuses_array;
  }

  void generateTopWords() {
    // Set arguments for concordance
    HashMap conc_args = new HashMap();
    conc_args.put("ignoreCase", true);
    conc_args.put("ignoreStopWords", true);
    conc_args.put("ignorePunctuation", true);
    conc_args.put("wordsToIgnore", wordsToIgnore);

    // Create concordance
    String all_tweets = join(statuses_array, "\n");
    String all_tweets_sanitised = all_tweets.replaceAll("“|”", "\"").replaceAll("‘|’", "'");
    Map conc = RiTa.concordance(all_tweets_sanitised, conc_args);
    Set<String> tokens = conc.keySet();
    Iterator<String> iter = tokens.iterator();

    // Get top words
    for (int i = 0; i < num_top_words; i++) {
      top_words[i] = iter.next();
    }
  }

  void displayTopWords() {
    fill(c);
    for (int i = 0; i < top_words.length; i++) {
      text(top_words[i], pos.x, pos.y + i*list_padding);
    }
  }

  String[] getTopWords() {
    return top_words;
  }
}
