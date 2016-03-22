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
    p.gravity = .12;
  }

  void render(float yplane) {
    beginShape();
    vertex(4, 0);
    vertex(4, -.5*yplane);
    vertex(2, -1*yplane);
    vertex(1.5, -1.25*yplane);
    vertex(.5, -1.25*yplane);
    vertex(0, -1*yplane);
    vertex(-2.5, -.5*yplane);
    vertex(-3.5, -2*yplane);
    vertex(-4, -2*yplane);
    vertex(-4, 0);
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
    p.gravity = .17;
  }

  void render(float yplane) {
    beginShape();
    vertex(4, 0);
    vertex(3.5, -1*yplane);
    vertex(2, -1*yplane);
    vertex(1, -1.5*yplane);
    vertex(0, -1*yplane);
    vertex(-3, -1*yplane);
    vertex(-3.5, -2*yplane);
    vertex(-4, -2*yplane);
    vertex(-4, 1*yplane);
    vertex(-3.5, 1*yplane);
    vertex(-3, 0);
    vertex(-2, 0);
    vertex(-1, .5*yplane);
    vertex(3, .5*yplane);
    endShape();
  }

  void init(Controller c) {
    c.maxLife *= 1.2;
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
    p.gravity = .1;
  }

  void render(float yplane) {  
    beginShape();
    vertex(4, 0);
    vertex(1, -1*yplane);
    vertex(-3, -.5*yplane);
    vertex(-4.5, -1.5*yplane);
    vertex(-4, 0);
    endShape();
  }
  
  void init(Controller c) {
    c.maxLife *= .8;
    c.life = c.maxLife;
    ((Plane)c.vehicle).engine.fspeed *= 1.2;
    ((Plane)c.vehicle).engine.speed = ((Plane)c.vehicle).engine.fspeed;
  }
};

