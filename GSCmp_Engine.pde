// Number of engine components (used for randomly generating planes)
final int GSNUMENG = 1;

abstract class GSEngine {
  // Amount of radians the vehicle is capable of changing its facing direction by in each frame
  float turnspd;
  float fturnspd;
  // speed is misleading, this actually refers to the change in velocity each frame while the plane is accelerating
  float speed;
  // Stored variable for base speed
  float fspeed;

  // Vehicle the engine is tied to
  Object platform;

  GSEngine() {
    turnspd = PI/45;
    speed = 1.2;
  }

  void render(float yplane) {
  }

  void turn(float d, float b) {
    platform.dir += d*turnspd;
    platform.roll += d*turnspd;
  }

  // Special move by the plane
  void boost(boolean b) {
  }
}

class GSProp extends GSEngine {

  GSProp(Object p) {
    platform = p;
    turnspd = PI/60;
    fturnspd = turnspd;
    speed = .5;
    fspeed = speed;
  }

  void render(float xplane) {
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
  }

  void turn(float d, float b) {
    platform.dir += d*turnspd*(1.5*b+1);
    platform.roll += d*turnspd*(1.5*b+1);
  }

};

