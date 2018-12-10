// flocking code from https://processing.org/examples/flocking.html

class Tweet {

  // CONTENT
  processing.data.JSONObject status;
  String text;
  String[] text_split_white;
  String timestamp;
  String name;
  String username;

  // MOTION
  PVector position;
  PVector velocity;
  PVector acceleration;
  float maxforce = 0.03;    // Maximum steering force
  float maxspeed_expand = 1.0;
  float maxspeed_flock = 3.0;
  float maxspeed = maxspeed_flock;

  // ROTATION
  float theta;
  PVector rot1, rot2, rot3;
  PVector[] rot;
  int[] rot_x, rot_y;
  float min_x, max_x, min_y, max_y;

  // WEIGHTING
  float weight_sep_expand = 3.0;
  float weight_sep_flock = 1.5;
  float weight_sep = weight_sep_flock;
  float weight_ali_expand = 0.1;
  float weight_ali_flock = 1.5;
  float weight_ali = weight_ali_flock;
  float weight_coh_expand = 0.1;
  float weight_coh_flock = 1.5;
  float weight_coh = weight_coh_flock;

  // ANALYSIS
  String pattern_split =
    "(?<=\\s+)|(?=\\s+)";  // lookbehind and lookahead whitespace
  // from https://stackoverflow.com/questions/31273020/how-to-split-a-string-while-maintaining-whitespace
  //"|" +
  //"\\s+|(?=\\p{P})|(?<=\\p{P})";  // split punctuation
  //from https://stackoverflow.com/questions/24222730/split-a-string-and-separate-by-punctuation-and-whitespace
  String pattern_punc_white = "[\\p{P}|\\s]";  // match punctuation and whitespace
  String[] text_split;
  color c_normal = color(0, 0, 0);
  color c_top_word = color(0, 80, 80);

  // DISPLAY
  int state;  // 0 = bird, 1 = text
  float w;
  float h;
  int anim_start;
  int anim_delay = 5;

  // IMAGE
  float image_size = 30.0;

  // TEXT
  float leading = font_size_max*1.2;
  float para_width = 250.0;
  float para_height;
  float font_size;
  float font_size_increment = 0.5;
  float scale_factor = 1.0;
  float scale_factor_increment = 0.05;

  // HOVER
  float hover_padding = 25.0;
  boolean is_hovered = false;
  float alpha_faded = 50.0;
  float alpha_hovered = 100.0;

  // FEATURE
  int id;
  //float anchor_x;
  //float anchor_y;
  float feature_padding = 10.0;
  color c_featured = color(180, 10, 100);

  Tweet(processing.data.JSONObject status) {
    // content
    this.status = status;
    id = status.getInt("id");
    text = status.getString("text");
    text_split = text.split(pattern_split);
    timestamp = status.getString("timestamp");
    name = status.getString("name");
    username = status.getString("username");

    // motion
    position = new PVector(width/2, height/2);
    acceleration = new PVector(0, 0);
    velocity = PVector.random2D();

    // rotation
    rot = new PVector[4];
    rot_x = new int[4];
    rot_y = new int[4];

    // display
    state = 0;
    
    // text
    para_height = calculateMaxHeight();
  }

  float calculateMaxHeight() {
    float max_height;
    textSize(font_size_max);
    // cursor
    float cursor_x = position.x;
    // line counter for calculating height
    int line = 0;
    for (int i = 0; i < text_split.length; i++) {
      String token = text_split[i];
      float token_w = textWidth(token);
      if (token.equals("\n") ||  // if token is new line
        (cursor_x + token_w > position.x + para_width &&  // if word overflows
        !token.equals(pattern_punc_white))) {  // except if punctuation or whitespace (keep attached to words) 
        cursor_x = position.x;  // reset cursor x to left
        line++;
      }
      cursor_x += token_w;
    }
    max_height = (line+1)*leading;
    return max_height;
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
    // give random velocity after release
    if (velocity.mag() == 0) {
      velocity = PVector.random2D();
    }
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    position.add(velocity);
    rot[0] = position;
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
    if (state == 0) {
      theta = velocity.heading() + radians(90);
      pushMatrix();
      translate(position.x, position.y);
      rotate(theta);
      //shape(bird_shape, position.x, position.y, image_size, image_size);
      image(bird, 0, 0, image_size, image_size);
      calculateRot();
      popMatrix();
    } else {
      // set sizes
      w = para_width * scale_factor;
      h = para_height * scale_factor;
      font_size = font_size_max * scale_factor;
      
      // set coordinates
      min_x = position.x;
      max_x = position.x + w;
      min_y = position.y;
      max_y = position.y + h;

      // draw background box
      drawBox();
      
      // draw text
      textSize(font_size);
      // set initial cursor to top left 
      float cursor_x = position.x;
      float cursor_y = position.y + leading;
      // line counter for calculating height
      int line = 0;
      for (int i = 0; i < text_split.length; i++) {
        String token = text_split[i];  // get current token (word/character)
        String[] token_split = RiTa.tokenize(token);
        float token_w = textWidth(token);  // calculate text width of token
        // set fill to normal color with alpha dependent on focus status
        if (is_hovered) fill(hue(c_normal), saturation(c_normal), brightness(c_normal), alpha_hovered);
        else fill(hue(c_normal), saturation(c_normal), brightness(c_normal), alpha_faded);
        
        for (String s : token_split) {
          for (String top_word : top_words) {
            if (s.toLowerCase().equals(top_word)) {  // check if token is contained in top words
              // set fill to top word color with alpha dependent on focus status
              if (is_hovered) fill(hue(c_top_word), saturation(c_top_word), brightness(c_top_word), alpha_hovered);
              else fill(hue(c_top_word), saturation(c_top_word), brightness(c_top_word), alpha_faded);
            }
          }
        }
        // move cursor to next line
        if (token.equals("\n") ||  // if token is new line
          (cursor_x + token_w > position.x + w &&  // if word overflows
          !token.equals(pattern_punc_white))) {  // except if punctuation or whitespace (keep attached to words) 
          cursor_x = position.x;  // reset cursor x to left
          line++;
          cursor_y = position.y + leading + line*leading;
        }
        text(token, cursor_x, cursor_y);
        cursor_x += token_w;
      }
    }
  }

  void calculateRot() {
    rot1 = new PVector(modelX(image_size, 0, 0), 
      modelY(image_size, 0, 0));
    rot[1] = rot1;
    rot2 = new PVector(modelX(0, image_size, 0), 
      modelY(0, image_size, 0));
    rot[2] = rot2;
    rot3 = new PVector(modelX(image_size, image_size, 0), 
      modelY(image_size, image_size, 0));
    rot[3] = rot3;
    for (int i = 0; i < 4; i++) {
      rot_x[i] = int(rot[i].x);
      rot_y[i] = int(rot[i].y);
    }
    min_x = min(rot_x);
    max_x = max(rot_x);
    min_y = min(rot_y);
    max_y = max(rot_y);
    w = max_x - min_x;
    h = max_y - min_y;
  }

  void drawBox() {
    if (featuring && featured_id == id) {
      noStroke();
      fill(hue(c_featured), saturation(c_featured), brightness(c_featured), alpha_faded);
      rect(position.x - feature_padding, position.y - feature_padding, w + feature_padding*2, h + feature_padding*2.2);
      fill(hue(c_normal), saturation(c_normal), brightness(c_normal), alpha_faded);
      text(name + " @" + username + " • " + timestamp, position.x, position.y - leading*1.5);
    }
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
    if (mouseX > min_x - hover_padding && mouseX < max_x + hover_padding &&
      mouseY > min_y - hover_padding && mouseY < max_y + hover_padding) {
      is_hovered = true;
      weight_sep = weight_sep_expand;
      weight_ali = weight_ali_expand;
      weight_coh = weight_coh_expand;
      maxspeed = maxspeed_expand;
      if (mousePressed) {
        if (!featuring) {
          featuring = true;  // activate
          featured_id = id;  // let only this tweet be dragged
          // create mouse anchor point in relation to top left corner
          //anchor_x = mouseX - position.x;
          //anchor_y = mouseY - position.y;
          anim_start = millis();
        }
        // let mouse drag tweet
        if (featuring && featured_id == id) {
          state = 1;
          h = leading;
          //position.x = mouseX - anchor_x;
          //position.y = mouseY - anchor_y;
          position.x = mouseX - w/2.0;
          position.y = mouseY - h/2.0 - leading*1.5;
          //if (millis() > anim_start + anim_delay && font_size < font_size_max) {
          if (millis() > anim_start + anim_delay && scale_factor < 1.0) {
            //font_size += font_size_increment;
            scale_factor += scale_factor_increment;
            anim_start = millis();
          }
        }
      } else {
        state = 0;
      }
    } else {
      is_hovered = false;
      state = 0;
      //font_size = font_size_min;
      scale_factor = 0.4;
      weight_sep = weight_sep_flock;
      weight_ali = weight_ali_flock;
      weight_coh = weight_coh_flock;
      maxspeed = maxspeed_flock;
    }
    // if mouse not pressed, turn featuring off
    if (!mousePressed) {
      featuring = false;
    }
  }
}
