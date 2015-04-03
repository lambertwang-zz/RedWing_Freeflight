final int NUMGUN = 3;

abstract class Gun {
  Object platform;
  int firerate; // The minimum number of frames between shots
  int cooldown; // The number of frames remaining before a shot can be made
  float multiplier;


  Gun() {
  }

  void shoot(boolean fire) {
  }

  void render() {
  }

  boolean max() {
    return false;
  }
}

class MachineGun extends Gun {

  MachineGun(int fire, Object p) {
    firerate = fire;
    cooldown = 0;
    platform = p;
    multiplier = 1;
  }


  void shoot(boolean fire) {
    if (fire)
      if (cooldown == 0) {
        Bullet b = new Bullet(platform);
        world.addition.add(new BulletController(b, platform.controller, multiplier));
        cooldown = firerate;
      }

    if (cooldown != 0)
      cooldown --;
  }
};

class LaserBeam extends Gun {
  float charge;
  boolean lastCharged = false;
  int cmax = 100;

  LaserBeam(Object p) {
    platform = p;
    multiplier = 1;
  }


  void shoot(boolean fire) {
    if (fire) {
      if (charge < cmax)
        charge ++;
    } else {
      if (charge > 20) {
        Beam b = new Beam(platform);
        world.addition.add(new BeamController(b, platform.controller, charge, multiplier));
      }
      charge = 0;
    }
  }

  void render() {
    if (charge > 5) {
      fill(frameCount%256, 255, 255);
      ellipse(32, 0, 5+charge/5, 5+charge/5);
    }
  }

  boolean max(){
    return charge > cmax*3/4;
  }
};

class GrenadeLauncher extends Gun {

  GrenadeLauncher(int fire, Object p) {
    firerate = fire;
    cooldown = 0;
    platform = p;
    multiplier = 1;
  }


  void shoot(boolean fire) {
    if (fire)
      if (cooldown == 0) {
        Grenade b = new Grenade(platform);
        world.addition.add(new GrenadeController(b, platform.controller, multiplier));
        cooldown = firerate;
      }

    if (cooldown != 0)
      cooldown --;
  }
};


class ChainGun extends Gun {
  int count;
  int cmax = 100;
  boolean firing = false;

  ChainGun(int fire, Object p) {
    firerate = fire;
    cooldown = 0;
    platform = p;
    multiplier = 1;
    count = 0;
  }

  void shoot(boolean fire) {
    if(!firing) {
      if (fire) {
        if (count < cmax)
          count ++;
      } else {
        if (count > 0){
          firing = true;
        }
      }
    } else {
      count -= 5;
      if(count < 0) {
        count = 0;
        firing = false;
      } else {
        if (cooldown == 0){
          Chain b = new Chain(platform);
          world.addition.add(new ChainController(b, platform.controller, multiplier));
          cooldown = firerate;
        }
      }
    }

    if (cooldown != 0)
      cooldown --;
  }

  void render() {
    if (count > 0) {
      fill(cmax-count, 192, 255);
      ellipse(32, 0, 10, 10);
    }
  }

  boolean max(){
    return count > cmax/2;
  }
};

