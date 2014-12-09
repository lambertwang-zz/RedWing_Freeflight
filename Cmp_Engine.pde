abstract class Engine {
  float turnspd; // Amount of radians the vehicle is capable of changing its facing direction by in each frame
  float speed; // Name is misleading, actually refers to the change in velocity each frame while the plane is accelerating

  Object platform;

  Engine() {
    turnspd = PI/45;
    speed = 1.2;
  }

  void render(float yplane) {
  }

  void turn(int d, boolean b) {
    platform.dir += d*turnspd;
    platform.roll += d*turnspd;
  }
}

class Prop extends Engine {
  Prop(Object p) {
    platform = p;
    turnspd = PI/45;
    speed = 1.2;
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
}

class Jet extends Engine {
  Jet(Object p) {
    platform = p;
    turnspd = PI/60;
    speed = 1.6;
  }

  void render(float xplane) {
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
  }

  void turn(int d, boolean b) {
    if (b) {
      platform.dir += d*turnspd/3;
      platform.roll += d*turnspd/3;
    } else {
      platform.dir += d*turnspd;
      platform.roll += d*turnspd;
    }
  }
}

