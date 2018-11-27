class Analyser {

  // CONTENT
  String[] texts;

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

  //Analyser(String[] statuses_array) {
  Analyser() {
    //this.statuses_array = statuses_array;
    texts = new String[statuses_array.size()];
    for (int i = 0; i < statuses_array.size(); i++) {
      JSONObject status = statuses_array.getJSONObject(i);
      texts[i] = status.getString("text");
    }
  }


  void generateTopWords() {
    // Set arguments for concordance
    HashMap conc_args = new HashMap();
    conc_args.put("ignoreCase", true);
    conc_args.put("ignoreStopWords", true);
    conc_args.put("ignorePunctuation", true);
    conc_args.put("wordsToIgnore", wordsToIgnore);

    // Create concordance
    String all_tweets = join(texts, "\n");
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
    text("TOP SECONDARY WORDS", pos.x, pos.y);
    for (int i = 0; i < top_words.length; i++) {
      text(top_words[i], pos.x, pos.y + (i+1)*list_padding);
    }
  }

  String[] getTopWords() {
    return top_words;
  }
}
