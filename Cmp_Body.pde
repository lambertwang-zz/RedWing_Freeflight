// Number of body components (used for randomly generating planes)
final int NUMBODY = 3;

abstract class Body {
  // The vehicle the body is tied to
  Object platform;
  // The hitpoints of the vehicle
  float life;

  Body() {
  }

  void render(float yplane) {
  }

  void init(Controller c) {
  }

  // Not quite sure what this is
  void controlOverride() {
  }
}

/**
 * Standard Body
 * Durability : ***
 * Gravity    : ***
 * Increases turning speed
 */
class Standard extends Body {

  Standard(Object p) {
    platform = p;
    p.gravity = .6;
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

  void init(Controller c) {
    ((Plane)c.vehicle).engine.fturnspd *= 1.2;
    ((Plane)c.vehicle).engine.turnspd = ((Plane)c.vehicle).engine.fturnspd;
  }
};

/**
 * Heavy Frame
 * Durability : *****
 * Gravity    : **
 * Lots of life
 */
class Heavy extends Body {
  Heavy(Object p) {
    platform = p;
    p.gravity = .85;
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
    c.maxLife *= 1.3;
    c.life = c.maxLife;
  }
};

/**
 * Slim Body
 * Durability : **
 * Gravity    : ****
 * Increases speed
 */
class Slim extends Body {
  Slim(Object p) {
    platform = p;
    p.gravity = .5;
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
    ((Plane)c.vehicle).engine.fspeed *= 1.2;
    ((Plane)c.vehicle).engine.speed = ((Plane)c.vehicle).engine.fspeed;
  }
};

