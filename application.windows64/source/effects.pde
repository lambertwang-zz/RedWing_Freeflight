/* Particle effects */

/*
  Effects:
 Spark
 Smoke
 Eclipse
 Explosion (compound effect)
 */

// Determines how long the shaking lasts for
final float shakeReduction = -0.95;

abstract class Particle {
  float size;
  float lifetime; // Initial life time in frames
  float remaining; // Remaining life time
  float xpos, ypos;
  color col; // Color

  Particle() {
  }

  void render() {
    if (xpos > world.screenPos.x-size && xpos < world.screenPos.x+size+width &&
      ypos > world.screenPos.y-size && ypos < world.screenPos.y+size+height)
      show();

    remaining--;
  }

  void show() {
  }
}

class Spark extends Particle { // Sparks are circles that fly some distance then fade
  float ang;

  Spark(float tx, float ty, float ts, color tcol, float tl, float ta) {
    xpos = tx;
    ypos = ty;
    size = ts; // Not physical size, but distance spark flies

      col = tcol;

    ang = ta;

    lifetime = tl;
    remaining = lifetime;
  }



  void show() {
    float temp = remaining/lifetime; // Slightly reduce computatuions
    stroke(col, 255*temp);
    strokeWeight(1.5);
    pushMatrix();
    translate(xpos, ypos);
    rotate(ang);
    translate(size*(1-temp), 0);
    noFill();
    ellipse(0, 0, 3, 3);
    popMatrix();
  }
}

class Smoke extends Particle { // Smoke is a circle that fades

  Smoke(float tx, float ty, float ts, color tcol, float tl) {
    xpos = tx;
    ypos = ty;
    size = ts;

    col = tcol;

    lifetime = tl;
    remaining = lifetime;
  }

  void show() {
    noStroke();
    fill(col, 255*remaining/lifetime);
    pushMatrix();
    translate(xpos, ypos);
    ellipse(0, 0, size, size);
    popMatrix();
  }
}

class Eclipse extends Particle { // Eclipse is a circle that dissolves into a crescent
  float ang;


  Eclipse(float tx, float ty, float ts, color tcol, float tl) {
    xpos = tx;
    ypos = ty;
    size = ts;

    ang = random(0, 2*PI);

    col = tcol;

    lifetime = tl;
    remaining = lifetime;
  }

  void show() {
    float temp = remaining/lifetime;
    noStroke();
    fill(col, 255*temp);
    pushMatrix();
    translate(xpos, ypos);
    rotate(ang);
    beginShape();
    bezierCircle(0, 0, size); 
    bezierCircleInv(0, size*temp, size*(1-temp)); // That's no moon
    endShape();
    popMatrix();
  }
}

class Explosion extends Particle { // Explosions are complex particles IE they solely consist of primitive particles
  ArrayList<Particle> parts;

  Explosion (float tx, float ty, float ts) {
    xpos = tx;
    ypos = ty;
    size = ts;

    parts = new ArrayList();

    for (int i = 0; i < size/8; i++)
      parts.add(new Smoke(xpos+random(-size, size), ypos+random(-size, size), random(size/4, size/2), color(0, 0, int(random(0, 255))), int(random(40, 60))));
    for (int i = 0; i < size/12; i++)
      parts.add(new Eclipse(xpos+random(-size/2, size/2), ypos+random(-size/2, size/2), random(size/4, size/2), color(int(random(0, 256)), 255, 255), int(random(30, 45))));
    for (int i = 0; i < size/6; i++)
      parts.add(new Spark(xpos+random(-size/2, size/2), ypos+random(-size/2, size/2), random(size, 2*size), color(int(random(0, 255)), 255, 255), int(random(30, 45)), random(0, 2*PI)));
    remaining = parts.size(); // Lifetime is number of particles remaining in the explosion
  }

  void render() { // Essentially same as renderEffects();
    for (Particle p : parts)
      p.render(); // Boom (Add "Sound effects" to ToDo list

    for (int i = parts.size ()-1; i >= 0; i--)
      if (parts.get(i).remaining == 0)
        parts.remove(i);

    remaining = parts.size();
  }
}

final float c = 4*(sqrt(2)-1)/3; // Constant to make circles with bezier curves

void bezierCircle(float x, float y, float r) {
  vertex(x, y+r);
  bezierVertex(x+c*r, y+r, x+r, y+c*r, x+r, y); // Go to Processing documentation or Wikipedia to learn how bezier curves work
  bezierVertex(x+r, y-c*r, x+c*r, y-r, x, y-r);
  bezierVertex(x-c*r, y-r, x-r, y-c*r, x-r, y);
  bezierVertex(x-r, y+c*r, x-c*r, y+r, x, y+r);
}

void bezierCircleInv(float x, float y, float r) {
  vertex(x, y+r);
  bezierVertex(x-c*r, y+r, x-r, y+c*r, x-r, y);
  bezierVertex(x-r, y-c*r, x-c*r, y-r, x, y-r);
  bezierVertex(x+c*r, y-r, x+r, y-c*r, x+r, y);
  bezierVertex(x+r, y+c*r, x+c*r, y+r, x, y+r);
}

