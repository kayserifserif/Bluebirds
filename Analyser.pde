class Analyser {

  // CONTENT
  String[] texts;

  // ANALYSIS
  String[] wordsToIgnore = {"rt", "//t", "https", "co", 
    "climate", "change", "global", "warming", 
    //"hoax", "conspiracy", "scam", "fake", "concept",
    "…"};

  // WORDS
  int num_top_words = 10;
  //String[] top_words = new String[num_top_words];
  String[] word_list;
  TopWord[] top_words;

  // DISPLAY
  float margin = 30.0; 
  float x, y;
  float list_padding = 20.0;
  float font_size;

  Analyser() {
    texts = new String[statuses_array.size()];
    for (int i = 0; i < statuses_array.size(); i++) {
      processing.data.JSONObject status = statuses_array.getJSONObject(i);
      texts[i] = status.getString("text");
    }
    word_list = new String[num_top_words];
    top_words = new TopWord[num_top_words];
    x = margin;
    y = margin;
  }

  void generateTopWords() {
    // set arguments for concordance
    HashMap conc_args = new HashMap();
    conc_args.put("ignoreCase", true);
    conc_args.put("ignoreStopWords", true);
    conc_args.put("ignorePunctuation", true);
    conc_args.put("wordsToIgnore", wordsToIgnore);

    // create concordance
    String all_tweets = join(texts, "\n");
    String all_tweets_sanitised = all_tweets.replaceAll("“|”", "\"").replaceAll("‘|’", "'");
    Map conc = RiTa.concordance(all_tweets_sanitised, conc_args);
    Set<String> tokens = conc.keySet();
    Iterator<String> iter = tokens.iterator();

    // get top words
    for (int i = 0; i < num_top_words; i++) {
      String word = iter.next();
      word_list[i] = word;
      top_words[i] = new TopWord(word, x, y + (i+1)*list_padding);
    }
  }

  void displayTopWords() {
    fill(c_system);
    textSize(font_size_max);
    text("TOP SECONDARY WORDS", x, y);
    for (int i = 0; i < top_words.length; i++) {
      //text(top_words[i], x, y + (i+1)*list_padding);
      top_words[i].display();
    }
  }

  String[] getWordList() {
    return word_list;
  }
}
