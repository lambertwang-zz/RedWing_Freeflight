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

  void boost(boolean b) {
  }
}

class Prop extends Engine {
  Prop(Object p) {
    platform = p;
    turnspd = PI/60;
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

  void turn(int d, boolean b) {
    if (b) {
      platform.dir += d*turnspd*2.5;
      platform.roll += d*turnspd*2.5;
    } else {
      platform.dir += d*turnspd;
      platform.roll += d*turnspd;
    }
  }
}

class Jet extends Engine {
  float fspeed; // Speed (does not vary)
  float turnMult;
  float fturnspd; // Amount to multiply turnspeed

  Jet(Object p) {
    platform = p;
    turnspd = PI/105;
    fturnspd = turnspd;
    speed = 1.6;
    fspeed = speed;
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
      platform.dir += d*turnspd*4;
      platform.roll += d*turnspd*4;
    } else {
      platform.dir += d*turnspd;
      platform.roll += d*turnspd;
    }
  }

  void boost(boolean b) {
    if (b) {
      speed = 2;
      turnspd = fturnspd/4;
      world.effects.add(new Smoke(platform.pos.x+random(-8, 8), platform.pos.y+random(-8, 8), random(8, 12), color(int(random(0, 255)), 255, 255), int(random(20, 30))));
    } else {
      speed = fspeed;
      turnspd = fturnspd;
    }
  }
}

class Chaos extends Engine {
  int boostrate;
  int cooldown;
  float fturnspd;


  Chaos(Object p) {
    platform = p;
    turnspd = PI/30;
    fturnspd = turnspd;
    speed = 1.1;

    boostrate = 180;
    cooldown = 0;
  }

  void render(float xplane) {
    beginShape();
    vertex(64, 0*xplane);
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
      platform.dir += d*turnspd;
      platform.roll += d*turnspd;
    } else {
      platform.dir += d*turnspd;
      platform.roll += d*turnspd;
    }
  }

  void boost(boolean b) {
    if (b) {
      if (cooldown == 0) {
        turnspd /= 2;
        world.effects.add(new Explosion(platform.pos.x, platform.pos.y, random(24, 32)));
        float cosd = cos(platform.dir);
        float sind = sin(platform.dir);
        for(int i = 0; i < 512; i+=32) {
          world.effects.add(new Explosion(platform.pos.x+i*cosd, platform.pos.y+i*sind, random(10, 16)));
        }
        platform.pos.set(platform.pos.x+cosd*512, platform.pos.y+sind*512);
        platform.last.set(platform.last.x+cosd*480, platform.last.y+sind*480);
        platform.dir += PI;
        world.effects.add(new Explosion(platform.pos.x, platform.pos.y, random(24, 32)));
        cooldown = boostrate;
      }
    }
    if (cooldown != 0) {
      cooldown--;
    } else {
      turnspd = fturnspd;
    }
  }
}

