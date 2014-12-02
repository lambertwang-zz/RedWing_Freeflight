final float FRICTION = .9375; // 15 16ths
final float GRAVITY = .6;

// Plane is a standard plane with average turning and speed
class Plane extends Object {
  Plane(float x, float y) {
    pos = new PVector(x, y);
    last = new PVector(x, y);

    sizex = 32;
    sizey = 16;
    sizez = 32;
    dir = 0;
    roll = 0;

    turnspd = PI/45;
    speed = 1.2;
    terminal = new PVector(FRICTION/(1-FRICTION)*speed, FRICTION/(1-FRICTION)*GRAVITY);

    controller = null;

    firerate = 10;
    cooldown = 0;
    
    col = color(0, 0, 0);
  }

  void render() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(dir);
    noStroke();
    fill(col);
    /*
    For rendering the planes, two shapes are drawn:
     one for the wings and one for the body.
     The height of the shapes is scaled based off of the roll in order to 
     give the illusion that the planes are 2d silhouettes of 3d objects.
     */
    float xplane = sin(roll);
    float yplane = cos(roll);

    beginShape();
    vertex(32, 0);
    vertex(16, 4*xplane);
    vertex(12, 24*xplane);
    vertex(8, 32*xplane);
    vertex(0, 32*xplane);
    vertex(-4, 24*xplane);
    vertex(-8, 4*xplane);
    vertex(-32, 0);
    vertex(-8, -4*xplane);
    vertex(-4, -24*xplane);
    vertex(0, -32*xplane);
    vertex(8, -32*xplane);
    vertex(12, -24*xplane);
    vertex(16, -4*xplane);
    endShape();

    beginShape();
    vertex(32, 0);
    vertex(16, -10*yplane);
    vertex(4, -10*yplane);
    vertex(-16, -6*yplane);
    vertex(-28, -16*yplane);
    vertex(-32, -16*yplane);
    vertex(-32, 0);
    endShape();

    popMatrix();
  }
}

// The jet turns slowly and flies fast. It turns even slower when accelerating
class Jet extends Object {
  Jet(float x, float y) {
    pos = new PVector(x, y);
    last = new PVector(x, y);

    sizex = 32;
    sizey = 16;
    sizez = 32;
    dir = 0;
    roll = 0;

    turnspd = PI/60;
    speed = 1.6;
    terminal = new PVector(FRICTION/(1-FRICTION)*speed, FRICTION/(1-FRICTION)*GRAVITY);

    controller = null;

    firerate = 10;
    cooldown = 0;
    
    col = color(0, 0, 0);
  }

  void render() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(dir);
    noStroke();
    fill(col);

    float xplane = sin(roll);
    float yplane = cos(roll);

    beginShape();
    vertex(32, 0*xplane);
    vertex(8, 4*xplane);
    vertex(-16, 32*xplane);
    vertex(-24, 32*xplane);
    vertex(-16, 4*xplane);
    vertex(-32, 0);
    vertex(-16, -4*xplane);
    vertex(-24, -32*xplane);
    vertex(-16, -32*xplane);
    vertex(8, -4*xplane);
    endShape();

    beginShape();
    vertex(32, 0);
    vertex(16, -8*yplane);
    vertex(-16, -4*yplane);
    vertex(-32, -16*yplane);
    vertex(-32, 0);
    endShape();

    popMatrix();
  }

  void controls(boolean left, boolean right, boolean up, boolean down, boolean fire) {
    // Override in order to change turn speed when accelerating
    if (up)
      turnspd = PI/180;
    else
      turnspd = PI/60;
    super.controls(left, right, up, down, fire);
  }
}

