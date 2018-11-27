public class Tweet {

  // MOTION
  PVector position;
  PVector velocity;
  PVector acceleration;
  float maxforce = 0.03;    // Maximum steering force
  float maxspeed_expand = 1.0;
  float maxspeed_flock = 3.0;
  float maxspeed = maxspeed_flock;
  float expand_padding = 40.0;

  // WEIGHTING
  float weight_sep_expand = 10.0;
  float weight_sep_flock = 1.5;
  float weight_sep = weight_sep_flock;
  float weight_ali_expand = 0.1;
  float weight_ali_flock = 2.0;
  float weight_ali = weight_ali_flock;
  float weight_coh_expand = 0.1;
  float weight_coh_flock = 2.5;
  float weight_coh = weight_coh_flock;

  // ANALYSIS
  //String[] top_words;
  String pattern_split =
    "(?<=\\s+)|(?=\\s+)" +  // lookbehind and lookahead whitespace
    // from https://stackoverflow.com/questions/31273020/how-to-split-a-string-while-maintaining-whitespace
    "|" +
    "\\s+|(?=\\p{P})|(?<=\\p{P})";  // split punctuation
  // from https://stackoverflow.com/questions/24222730/split-a-string-and-separate-by-punctuation-and-whitespace
  String pattern_punc_white = "[\\p{P}|\\s]";  // match punctuation and whitespace
  String[] text_split;
  color c_normal = color(0, 0, 0);
  color c_top_word = color(0, 80, 80);

  // DISPLAY
  String text;
  float w = 250.0;
  float h;
  float leading = font_size*1.2;

  // FOCUS
  float focus_padding = 10.0;
  boolean is_hovered = false;
  float alpha_faded = 50.0;
  float alpha_hovered = 100.0;

  // FEATURE
  int id;
  float anchor_x, anchor_y;

  Tweet(int id, String text) {
    this.id = id;
    this.text = text;
    text_split = text.split(pattern_split);
    //this.top_words = top_words;

    position = new PVector(width/2, height/2);
    acceleration = new PVector(0, 0);
    velocity = PVector.random2D();
  }

  void run(ArrayList<Tweet> tweets) {
    flock(tweets);
    update();
    borders();
    checkHover();
    render();
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Tweet> tweets) {
    PVector sep = separate(tweets);   // Separation
    PVector ali = align(tweets);      // Alignment
    PVector coh = cohesion(tweets);   // Cohesion
    // Arbitrarily weight these forces
    sep.mult(weight_sep);
    ali.mult(weight_ali);
    coh.mult(weight_coh);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  // Method to update position
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    position.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    // Scale to maximum speed
    desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  void render() {
    // set initial cursor to top left 
    float cursor_x = position.x;
    float cursor_y = position.y;
    // line counter for calculating height
    int line = 0;
    for (int i = 0; i < text_split.length; i++) {
      String token = text_split[i];  // get current token (word/character)
      float token_w = textWidth(token);  // calculate text width of token
      // set fill to normal color with alpha dependent on focus status
      if (is_hovered) {
        fill(hue(c_normal), saturation(c_normal), brightness(c_normal), alpha_hovered);
      } else {
        fill(hue(c_normal), saturation(c_normal), brightness(c_normal), alpha_faded);
      }
      for (String s : top_words) {
        if (token.toLowerCase().equals(s)) {  // check if token is contained in top words
          // set fill to top word color with alpha dependent on focus status
          if (is_hovered) {
            fill(hue(c_top_word), saturation(c_top_word), brightness(c_top_word), alpha_hovered);
          } else {
            fill(hue(c_top_word), saturation(c_top_word), brightness(c_top_word), alpha_faded);
          }
        }
      }
      // move cursor to next line
      if (token.equals("\n") ||  // if token is new line
        (cursor_x + token_w > position.x + w &&  // if word overflows
        !token.equals(pattern_punc_white))) {  // except if punctuation or whitespace (keep attached to words) 
        cursor_x = position.x;  // reset cursor x to left
        line++;
        cursor_y = position.y + line*leading;
      }
      text(token, cursor_x, cursor_y);
      cursor_x += token_w;
    }
    h = (line+1)*leading;
  }

  // Wraparound
  void borders() {
    if (position.x < -w) position.x = width+w;
    if (position.y < -w) position.y = height+w;
    if (position.x > width+w) position.x = -w;
    if (position.y > height+w) position.y = -w;
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Tweet> tweets) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Tweet other : tweets) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<Tweet> tweets) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Tweet other : tweets) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      sum.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }

  // Cohesion
  // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
  PVector cohesion (ArrayList<Tweet> tweets) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Tweet other : tweets) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position); // Add position
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    } else {
      return new PVector(0, 0);
    }
  }

  void checkHover() {
    if (mouseX > position.x - expand_padding && mouseX < position.x + w + expand_padding &&
      mouseY > position.y - expand_padding && mouseY < position.y + h + expand_padding) {
      is_hovered = true;
      weight_sep = weight_sep_expand;
      weight_ali = weight_ali_expand;
      weight_coh = weight_coh_expand;
      maxspeed = maxspeed_expand;
      if (mousePressed) {
        if (!featuring) {
          featuring = true;
          featured_id = id;
          anchor_x = mouseX - position.x;
          anchor_y = mouseY - position.y;
          println(anchor_x, anchor_y);
        }
        if (featuring && featured_id == id) {
          //maxspeed = 0.0;
          position.x = mouseX - anchor_x;
          position.y = mouseY - anchor_y;
        }
      } else {
        if (velocity.mag() == 0) {
          velocity = PVector.random2D();
        }
      }
    } else {
      is_hovered = false;
      weight_sep = weight_sep_flock;
      weight_ali = weight_ali_flock;
      weight_coh = weight_coh_flock;
      maxspeed = maxspeed_flock;
    }
    if (!mousePressed) {
      featuring = false;
    }
  }
}
