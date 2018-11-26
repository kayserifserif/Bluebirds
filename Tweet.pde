class Tweet {
  String text;
  float x, y;
  float w = 250.0;
  float h = 250.0;
  float speed;
  
  Tweet(String text) {
    this.text = text;
    x = random(width);
    y = random(height);
    speed = random(0.5, 2.0);
  }
  
  void update() {
    x += speed;
    if (x > width) {
      x = -w;
    }
  }
  
  void display() {
    fill(0);
    text(text, x, y, w, h);
  }
}
