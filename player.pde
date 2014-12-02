final int maxLife = 16;
final int recoveryTime = 60;

// This is you
class Player extends Controller {
  int recovery;

  Player(Object v) {
    vehicle = v;
    location = new ArrayList();
    // Sets a static check size
    checkx = ceil(max(v.sizex, v.sizey, v.sizez)/CELLSIZE);
    checky = checkx;

    life = 16;
    recovery = 0;

    v.controller = this;

    v.col = color(0, 255, 255);
  }

  void tick() {
    vehicle.controls(lfkey, rtkey, upkey, dnkey, fkey);

    // Changes the hitbox to match the profile of the plane
    recheck();

    if (life != maxLife) {
      if (recovery == recoveryTime) {
        recovery = 0;
        life++;
        vehicle.col = color(0, 255*life/maxLife, 255*life/maxLife);
        world.bleed = (world.bleed & 0xffffff) | (int(128*(1-float(life)/maxLife)) << 24);
      } else {
        recovery++;
      }
    } else {
      recovery = 0;
    }


    ArrayList<Controller> collided = world.collide(this);
    for (Controller c : collided) {
      if (c instanceof BulletController) {
        if (c.origin instanceof Computer) {
          life--;
          vehicle.col = color(0, 255*life/maxLife, 255*life/maxLife);
          world.bleed = (world.bleed & 0xffffff) | (int(128*(1-float(life)/maxLife)) << 24);
          if (life == 0) {
            world.shake.add(signum(random(-1, 1))*random(32, 48), signum(random(-1, 1))*random(32, 48), 0);
            world.effects.add(new Explosion(vehicle.pos.x, vehicle.pos.y, random(240, 320)));
            world.removal.add(this);
          } else {
            world.shake.add(signum(random(-1, 1))*random(8, 16), signum(random(-1, 1))*random(8,16), 0);
            world.effects.add(new Explosion(vehicle.pos.x, vehicle.pos.y, random(32, 48)));
          }
          world.removal.add(c);
        }
      }
    }

    vehicle.tick();
    update();
  }

  void render() {
    pushMatrix();
    if (vehicle.pos.x < world.screenPos.x)
      translate(FIELDX*CELLSIZE, 0);
    else if (vehicle.pos.x > world.screenPos.x+width)
      translate(-FIELDX*CELLSIZE, 0);

    if (vehicle.pos.y < world.screenPos.y)
      translate(0, FIELDY*CELLSIZE);
    else if (vehicle.pos.y > world.screenPos.y+height)
      translate(0, -FIELDY*CELLSIZE);

    vehicle.render();

    popMatrix();
  }

  void recheck() {
    // Is this really worth the loss in efficiency?
    // Probably
    // stored sine and cosine functions to reduce computations
    float tempax = abs(cos(vehicle.dir));
    float tempay = abs(sin(vehicle.dir));
    // Tempy is the visible y profile of the vehicle relative to its local axis based off of the vehicles roll.
    // The visible x profile will always be vehicle.sizex since the plane's yaw is never changed. 
    float tempy = max(abs(cos(vehicle.roll)*vehicle.sizey), abs(sin(vehicle.roll)*vehicle.sizez));
    // Changes the hitbox to match the vehicle's profile
    checkx = ceil(max(tempax*vehicle.sizex, tempay*tempy)/CELLSIZE);
    checky = ceil(max(tempay*vehicle.sizex, tempax*tempy)/CELLSIZE);
  }
}

