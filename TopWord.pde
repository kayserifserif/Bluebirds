class TopWord {
  String word;
  float x, y;
  float w, h;

  TopWord(String word, float x, float y) {
    this.word = word;
    this.x = x;
    this.y = y;
    w = textWidth(word);
    h = font_size_max;
  }

  void display() {
    if (mouseX > x && mouseX < x + w &&
      mouseY > y - font_size_max && mouseY < y + h) {
      fill(c_top_word);
    } else {
      fill(c_system);
    }
    text(word, x, y);
  }
}
