// Number of body components (used for randomly generating planes)
final int GSNUMBODY = 1;

abstract class GSBody {
  // The vehicle the body is tied to
  Object platform;
  // The hitpoints of the vehicle
  float life;

  GSBody() {
  }

  void render(float yplane) {
  }

  void init(Controller c) {
  }

  // Not quite sure what this is
  void controlOverride() {
  }
}

class GSStandard extends GSBody {

  GSStandard(Object p) {
    platform = p;
    p.gravity = 0;
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
    ((Gunship)c.vehicle).engine.fturnspd *= 1.2;
    ((Gunship)c.vehicle).engine.turnspd = ((Gunship)c.vehicle).engine.fturnspd;
  }
};

