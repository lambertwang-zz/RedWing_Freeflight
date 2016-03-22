// Number of engine components (used for randomly generating planes)
final int NUMENG = 3;

abstract class Engine {
  // Amount of radians the vehicle is capable of changing its facing direction by in each frame
  float turnspd;
  float fturnspd;
  // speed is misleading, this actually refers to the change in velocity each frame while the plane is accelerating
  float speed;
  // Stored variable for base speed
  float fspeed;

  // Vehicle the engine is tied to
  Object platform;

  Engine() {
    turnspd = PI/60;
    speed = .2;
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

/**
 * Propeller
 * Turning  : ***
 * Speed    : ***
 * Special  : ***
 */
class Prop extends Engine {

  Prop(Object p) {
    platform = p;
    turnspd = PI/75;
    fturnspd = turnspd;
    speed = .2;
    fspeed = speed;
  }

  void render(float xplane) {
    beginShape();
    vertex(4, 0);
    vertex(2, .5*xplane);
    vertex(1.5, 3*xplane);
    vertex(1, 4*xplane);
    vertex(0, 4*xplane);
    vertex(-.5, 3*xplane);
    vertex(-1, .5*xplane);
    vertex(-4, 0);
    vertex(-1, -.5*xplane);
    vertex(-.5, -3*xplane);
    vertex(0, -4*xplane);
    vertex(1, -4*xplane);
    vertex(1.5, -3*xplane);
    vertex(2, -.5*xplane);
    endShape();
  }

  void turn(float d, float b) {
    platform.dir += d*turnspd*(1.5*b+1);
    platform.roll += d*turnspd*(1.5*b+1);
  }

  // Boost allows the plane to accelerate backwards
  void boost(boolean b) {
    if (b) {
      speed = -fspeed*.5;
      world.effects.add(new Spark(platform.last.x, platform.last.y, random(48, 64), color(int(random(0, 256)), 255, 255), random(20, 25)*effectsDensity, random(0, 2*PI)));
    } else {
      speed = fspeed;
    }
  }
};

/**
 * Jet Engine
 * Turning  : **
 * Speed    : *****
 * Special  : **
 */
class Jet extends Engine {
  float turnMult;

  Jet(Object p) {
    platform = p;
    turnspd = PI/105;
    fturnspd = turnspd;
    speed = .28;
    fspeed = speed;
  }

  void render(float xplane) {
    beginShape();
    vertex(4, 0*xplane);
    vertex(1, .5*xplane);
    vertex(-2, 4*xplane);
    vertex(-3, 4*xplane);
    vertex(-2, .5*xplane);
    vertex(-4, 0);
    vertex(-2, -.5*xplane);
    vertex(-3, -4*xplane);
    vertex(-2, -4*xplane);
    vertex(1, -.5*xplane);
    endShape();
  }

  void turn(float d, float b) {
    platform.dir += d*turnspd*(3*b+1);
    platform.roll += d*turnspd*(3*b+1);
  }

  // Boost is an afterburner that increases acceleration
  void boost(boolean b) {
    if (b) {
      speed = .36;
      turnspd = fturnspd/4;
      world.effects.add(new Smoke(platform.last.x, platform.last.y, random(1, 2), color(int(random(0, 255)), 255, 255), random(5, 8)*effectsDensity));
    } else {
      speed = fspeed;
      turnspd = fturnspd;
    }
  }
};

/**
 * Chaos Engine
 * Turning  : **
 * Speed    : ***
 * Special  : ****
 */
class Chaos extends Engine {
  int boostrate;
  int cooldown;


  Chaos(Object p) {
    platform = p;
    turnspd = PI/45;
    fturnspd = turnspd;
    speed = .22;
    fspeed = speed;
    boostrate = 180;
    cooldown = 0;
  }

  void render(float xplane) {
    beginShape();
    vertex(4, 0*xplane);
    vertex(1, .5*xplane);
    vertex(2.5, 3*xplane);
    vertex(0, 2.5*xplane);
    vertex(-1.5, .5*xplane);
    vertex(-4, 0);
    vertex(-1.5, -.5*xplane);
    vertex(0, -2.5*xplane);
    vertex(2.5, -3*xplane);
    vertex(1, -.4*xplane);
    endShape();
  }

  // Boost teleports the plane forwards and the plane lands facing the opposite direction
  void boost(boolean b) {
    if (b) {
      if (cooldown == 0) {
        // Turnspeed is halved while teleport is recharging
        turnspd /= 2;
        world.effects.add(new Explosion(platform.pos.x, platform.pos.y, random(3, 4)*effectsDensity));
        float cosd = cos(platform.dir);
        float sind = sin(platform.dir);
        // Explosions
        for (int i = 0; i < 128; i+=64/effectsDensity) {
          world.effects.add(new Explosion(platform.pos.x+i*cosd, platform.pos.y+i*sind, random(1, 2)));
        }
        platform.pos.set(platform.pos.x+cosd*128, platform.pos.y+sind*128);
        platform.last.set(platform.last.x+cosd*120, platform.last.y+sind*120);
        platform.dir += PI;
        world.effects.add(new Explosion(platform.pos.x, platform.pos.y, random(1, 2)*effectsDensity));
        cooldown = boostrate;
      }
    }
    if (cooldown != 0) {
      // Teleport requires some time to charge. 
      cooldown--;
      world.effects.add(new Eclipse(platform.last.x, platform.last.y, random(.5, 1), color(int(random(0, 256)), 255, 255), random(8, 12)*effectsDensity));
      if (cooldown == 0) {
        turnspd = fturnspd;
        world.effects.add(new Explosion(platform.pos.x, platform.pos.y, random(2, 3)*effectsDensity));
      }
    }
  }
};

