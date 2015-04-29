/* Particle effects */

/*
  Effects:
 Spark
 Smoke
 Eclipse
 Explosion (compound effect)
 */
 
final float expGain = -24;

// Determines how long the shaking lasts for
final float shakeReduction = -0.95;
float effectsDensity = 2.5; // range from 1 to 6 inclusive

abstract class Particle {
  float size;
  float lifetime; // Initial life time in frames
  float remaining; // Remaining life time
  float xpos, ypos;
  color col; // Color

  Particle() {
  }

  void render(boolean xsplit, boolean ysplit, boolean decay) {
    if (xsplit) {
      if (xpos > world.screenPos.x-size || xpos < world.screenPos.x+size+width){
        if(ysplit) {
          if(ypos > world.screenPos.y-size || ypos < world.screenPos.y+size+height){
            transShow(xsplit, ysplit);
          }
        } else if (ypos > world.screenPos.y-size && ypos < world.screenPos.y+size+height){
          transShow(xsplit, ysplit);
        }
      }
    } else {
      if(xpos > world.screenPos.x-size && xpos < world.screenPos.x+size+width){
        if(ysplit) {
          if(ypos > world.screenPos.y-size || ypos < world.screenPos.y+size+height){
            transShow(xsplit, ysplit);
          }
        } else if (ypos > world.screenPos.y-size && ypos < world.screenPos.y+size+height){
          transShow(xsplit, ysplit);
        }
      }
    }
    if (decay)
      remaining--;
  }

  void transShow(boolean xsplit, boolean ysplit){
    pushMatrix();
    if(xsplit){
      if(world.screenPos.x-xpos > world.hx){
        translate(world.x, 0);
      } else if(world.screenPos.x-xpos < -world.hx){
        translate(-world.x, 0);
      }
    }
    if(ysplit){
      if(world.screenPos.y-ypos > world.hy){
        translate(0, world.y);
      } else if(world.screenPos.y-ypos < -world.hy){
        translate(0, -world.y);
      }
    }
    show();
    popMatrix();
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
    translate(xpos, ypos);
    rotate(ang);
    translate(size*(1-temp), 0);
    noFill();
    ellipse(0, 0, 3, 3);
  }
};

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
    translate(xpos, ypos);
    ellipse(0, 0, size, size);
  }
};

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
    translate(xpos, ypos);
    rotate(ang);
    beginShape();
    bezierCircle(0, 0, size); 
    bezierCircleInv(0, size*temp, size*(1-temp)); // That's no moon
    endShape();
  }
};

class Explosion extends Particle { // Explosions are complex particles IE they solely consist of primitive particles
  ArrayList<Particle> parts;
  AudioSample expSound;

  Explosion (float tx, float ty, float ts) {
    xpos = tx;
    ypos = ty;
    size = ts;

    AudioSample tempAS = explosion[floor(random(0, 3))];
    tempAS.setGain(expGain-max(0, (64-ts)/4));
    tempAS.trigger();

    parts = new ArrayList();

    for (int i = 0; i < effectsDensity*size/32; i++)
      parts.add(new Smoke(xpos+random(-size, size), ypos+random(-size, size), random(size/4, size/2), color(0, 0, int(random(128, 255))), int(random(40, 60))));
    for (int i = 0; i < effectsDensity*size/40; i++)
      parts.add(new Eclipse(xpos+random(-size/2, size/2), ypos+random(-size/2, size/2), random(size/4, size/2), color(int(random(0, 255)), 255, 255), int(random(30, 45))));
    for (int i = 0; i < effectsDensity*size/16; i++)
      parts.add(new Spark(xpos+random(-size/2, size/2), ypos+random(-size/2, size/2), random(size, 2*size), color(int(random(0, 255)), 255, 255), int(random(30, 45)), random(0, 2*PI)));
    remaining = parts.size(); // Lifetime is number of particles remaining in the explosion
  }

  void render(boolean xsplit, boolean ysplit, boolean decay) { // Essentially same as renderEffects();
    for (Particle p : parts)
      p.render(xsplit, ysplit, true); // Boom (Add "Sound effects" to ToDo list

    if(decay){
      for (int i = parts.size ()-1; i >= 0; i--) { // When effects time out, they are removed
        if (parts.get(i).remaining < 0) {
          Cell e = world.getCell(floor(parts.get(i).xpos/CELLSIZE), floor(parts.get(i).ypos/CELLSIZE));
          float magnitude = 32;
          if (parts.get(i) instanceof Smoke) {
            magnitude = size/3;
          } else if (parts.get(i) instanceof Spark) {
            magnitude = size/2;
          } else if (parts.get(i) instanceof Eclipse) {
            magnitude = 2*size;
          }
          e.col = color(hue(e.col), saturation(e.col) + min(255-saturation(e.col), int(random(magnitude, magnitude*1.2))), brightness(e.col));
          parts.remove(i);
        }
      }
  
      remaining = parts.size();
    }
  }
};

class Cloud extends Particle { // Cloud is a series of boxes that fade in and out
  PGraphics g;
  boolean fading = true;
  float[][] vertices;
  Cloud(float tx, float ty, float ts, float tl) {
    xpos = tx;
    ypos = ty;
    size = ts*32;

    lifetime = tl;
    remaining = lifetime*random(.1, .9);
    float sizeX = size, sizeY = size*3/4;
    
    vertices = new float[6][2];
    vertices[0][0] = random(0, sizeX/4);
    vertices[0][1] = random(0, sizeY/4);
    vertices[1][0] = random(sizeX*3/4, sizeX)  -vertices[0][0];
    vertices[1][1] = random(sizeY/2, sizeY*3/4)-vertices[0][1];
    vertices[2][0] = random(0, sizeX/4);
    vertices[2][1] = random(sizeY/4, sizeY/2);
    vertices[3][0] = random(sizeX/2, sizeX*3/4) -vertices[2][0];
    vertices[3][1] = random(sizeY*3/4, sizeY)   -vertices[2][1];
    vertices[4][0] = random(sizeX/4, sizeX/2);
    vertices[4][1] = random(sizeY/4, sizeY/2);
    vertices[5][0] = random(sizeX*3/4, sizeX)-vertices[4][0];
    vertices[5][1] = random(sizeY*3/4, sizeY)-vertices[4][1];
  }

  void show() {
    noStroke();
    translate(xpos, ypos);
    fill(255, 192*remaining/lifetime);
    rect(vertices[0][0], vertices[0][1], vertices[1][0], vertices[1][1]);
    rect(vertices[2][0], vertices[2][1], vertices[3][0], vertices[3][1]);
    rect(vertices[4][0], vertices[4][1], vertices[5][0], vertices[5][1]);
  }

  void render(boolean xsplit, boolean ysplit, boolean decay) {
    if (xsplit) {
      if (xpos > world.screenPos.x-size || xpos < world.screenPos.x+size+width){
        if(ysplit) {
          if(ypos > world.screenPos.y-size || ypos < world.screenPos.y+size+height){
            transShow(xsplit, ysplit);
          }
        } else if (ypos > world.screenPos.y-size && ypos < world.screenPos.y+size+height){
          transShow(xsplit, ysplit);
        }
      }
    } else {
      if(xpos > world.screenPos.x-size && xpos < world.screenPos.x+size+width){
        if(ysplit) {
          if(ypos > world.screenPos.y-size || ypos < world.screenPos.y+size+height){
            transShow(xsplit, ysplit);
          }
        } else if (ypos > world.screenPos.y-size && ypos < world.screenPos.y+size+height){
          transShow(xsplit, ysplit);
        }
      }
    }
    if(decay){
      if(remaining < 1 || remaining > lifetime){
          fading = !fading;
        }
  
      remaining += fading? -1: 1;
    }
    /*
    pushMatrix();
    translate(xpos, ypos);
    fill(0);
    text("X: "+xpos, 0, 0);
    text("Y: "+ypos, 0, 16);
    popMatrix();*/
  }
};

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

