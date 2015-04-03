final int NUMBODY = 3;

abstract class Body {
  Object platform;
  float life;

  PVector terminal = new PVector(100, 100); // Terminal velocities in the x direction based off of speed and in the y direction based off of gravity
  float gravity = 1;

  Body() {
  }

  void render(float yplane) {
  }

  void init(Controller c) {
  }

  void controlOverride() {
  }
}

class Standard extends Body {

  Standard(Object p) {
    platform = p;
    gravity = .6;
  }

  void render(float yplane) {
    beginShape();
    vertex(32, 0);
    vertex(32, -4*yplane);
    vertex(16, -8*yplane);
    vertex(12, -10*yplane);
    vertex(4, -10*yplane);
    vertex(0, -8*yplane);
    vertex(-20, -4*yplane);
    vertex(-28, -16*yplane);
    vertex(-32, -16*yplane);
    vertex(-32, 0);
    endShape();
  }
};

class Heavy extends Body {
  Heavy(Object p) {
    platform = p;
    gravity = .8;
  }

  void render(float yplane) {
    beginShape();
    vertex(32, 0);
    vertex(28, -8*yplane);
    vertex(16, -8*yplane);
    vertex(8, -12*yplane);
    vertex(0, -8*yplane);
    vertex(-24, -8*yplane);
    vertex(-28, -16*yplane);
    vertex(-32, -16*yplane);
    vertex(-32, 8*yplane);
    vertex(-28, 8*yplane);
    vertex(-24, 0);
    vertex(-16, 0);
    vertex(-8, 4*yplane);
    vertex(24, 4*yplane);
    endShape();
  }

  void init(Controller c) {
    c.maxLife *= 1.25;
    c.life = c.maxLife;
  }
};

class Slim extends Body {
  Slim(Object p) {
    platform = p;
    gravity = .5;
  }

  void render(float yplane) {  
    beginShape();
    vertex(32, 0);
    vertex(8, -8*yplane);
    vertex(-24, -4*yplane);
    vertex(-36, -12*yplane);
    vertex(-32, 0);
    endShape();
  }
  
  void init(Controller c) {
    c.maxLife *= .8;
    c.life = c.maxLife;
  }
};

class Mellee extends Body {
  Mellee(Object p) {
    platform = p;
  }

  void render(float yplane) {  
    beginShape();
    vertex(32, 0);
    vertex(16, -8*yplane);
    vertex(-16, -4*yplane);
    vertex(-36, -16*yplane);
    vertex(-32, 0);
    vertex(-34, 4*yplane);
    vertex(-24, 0);
    endShape();
  }
};

class Reflector extends Body {
  Reflector(Object p) {
    platform = p;
  }

  void render(float yplane) {  
    beginShape();
    vertex(32, 0);
    vertex(16, -8*yplane);
    vertex(-16, -4*yplane);
    vertex(-36, -16*yplane);
    vertex(-32, 0);
    vertex(-34, 4*yplane);
    vertex(-24, 0);
    endShape();
  }
};

