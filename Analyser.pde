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
  String[] word_list;
  TopWord[] top_words;

  // DISPLAY
  float margin = 30.0; 
  float x, y;
  float w, h;
  float list_padding = 20.0;

  Analyser() {
    // content
    texts = new String[statuses_array.size()];
    for (int i = 0; i < statuses_array.size(); i++) {
      processing.data.JSONObject status = statuses_array.getJSONObject(i);
      // get the text of each status and add it to the array
      texts[i] = status.getString("text");
    }
    word_list = new String[num_top_words];
    top_words = new TopWord[num_top_words];

    // display
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
      // add word string to an array
      word_list[i] = word;
      // create a TopWord object and add it to an array
      top_words[i] = new TopWord(word, x, y + (i+1)*list_padding);
    }

    w = 0.0;
    // find the maximum width of any top word
    for (String word : word_list) {
      if (textWidth(word) > w) {
        w = textWidth(word);
      }
    }
    h = num_top_words*list_padding;
  }

  void displayTopWords() {
    fill(c_system);
    textSize(font_size_max);
    text("TOP SECONDARY WORDS", x, y);

    // check mouse hover
    if (mouseX > x && mouseX < x + w &&
      mouseY > y && mouseY < y + h) {
      analyser_hovered = true;
    } else {
      analyser_hovered = false;
    }
    if (!mousePressed) {
      word_pressed = false;
    }

    // display words
    for (int i = 0; i < top_words.length; i++) {
      top_words[i].display();
    }
  }

  String[] getWordList() {
    return word_list;
  }
}
