class Tweet {

  // MOTION
  PVector position;
  PVector velocity;
  PVector acceleration;
  float maxforce = 0.03;    // Maximum steering force
  float maxspeed_escape = 1.0;
  float maxspeed_flock = 3.0;
  float maxspeed = maxspeed_flock;
  
  // ANALYSIS
  //String[] top_words;
  //color c_normal = color(0, 0, 0);
  //color c_topic = color(200, 50, 50);

  // DISPLAY
  String text;
  float w = 250.0;
  float h = 250.0;
  //float z_back = -100.0;
  //float z_front = 100.0;
  float expand_padding = 50.0;

  // FOCUS
  float focus_padding = 10.0;
  boolean is_focused = false;
  float alpha_faded = 100.0;
  float alpha_focused = 255.0;

  // WEIGHTING
  float weight_sep_escape = 10.0;
  float weight_sep_flock = 1.5;
  float weight_sep = weight_sep_flock;
  float weight_ali_escape = 0.1;
  float weight_ali_flock = 2.0;
  float weight_ali = weight_ali_flock;
  float weight_coh_escape = 0.1;
  float weight_coh_flock = 2.5;
  float weight_coh = weight_coh_flock;

  Tweet(String text) {
    this.text = text;
    //position = new PVector(random(width), random(height));
    //position = new PVector(random(width), random(height), random(z_back, z_front));
    position = new PVector(width/2, height/2);
    //position = new PVector(width/2, height/2, 0);
    acceleration = new PVector(0, 0);
    //acceleration = new PVector(0, 0, 0);
    velocity = PVector.random2D();
    //velocity = PVector.random3D();
  }

  void run(ArrayList<Tweet> tweets) {
    flock(tweets);
    update();
    borders();
    checkMouse();
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
    //fill(0);
    if (is_focused) {
      fill(0, alpha_focused);
    } else {
      fill(0, alpha_faded);
    }
    pushMatrix();
    translate(position.x, position.y);
    //translate(position.x, position.y, position.z);
    text(text, 0, 0, w, h);
    //text(text, position.x, position.y, w, h);
    popMatrix();
  }

  // Wraparound
  void borders() {
    if (position.x < -w) position.x = width+w;
    if (position.y < -w) position.y = height+w;
    //if (position.z < z_back) position.z = z_front;
    if (position.x > width+w) position.x = -w;
    if (position.y > height+w) position.y = -w;
    //if (position.z > z_front) position.z = z_back;
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
    //PVector sum = new PVector(0, 0, 0);
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
      //return new PVector(0, 0, 0);
    }
  }

  // Cohesion
  // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
  PVector cohesion (ArrayList<Tweet> tweets) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    //PVector sum = new PVector(0, 0, 0);
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
      //return new PVector(0, 0, 0);
    }
  }

  void checkMouse() {
    if (mouseX > position.x - expand_padding && mouseX < position.x + w + expand_padding &&
      mouseY > position.y - expand_padding && mouseY < position.y + h + expand_padding) {
      if (mouseX > position.x - focus_padding && mouseX < position.x + w + focus_padding &&
        mouseY > position.y - focus_padding && mouseY < position.y + h + focus_padding) {
        is_focused = true;
      }
      weight_sep = weight_sep_escape;
      weight_ali = weight_ali_escape;
      weight_coh = weight_coh_escape;
      maxspeed = maxspeed_escape;
    } else {
      is_focused = false;
      weight_sep = weight_sep_flock;
      weight_ali = weight_ali_flock;
      weight_coh = weight_coh_flock;
      maxspeed = maxspeed_flock;
    }
  }
}
