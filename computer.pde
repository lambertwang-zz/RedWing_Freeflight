final int compLife = 4;

// This is the enemy
class Computer extends Controller {

  Object target;
  boolean up, left, right, fire;


  Computer(Object v) {
    vehicle = v;
    location = new ArrayList();
    // Sets a static check size
    checkx = ceil(max(v.sizex, v.sizey, v.sizez)/CELLSIZE);
    checky = checkx;

    life = compLife;

    v.controller = this;

    target = null;

    up = false;
    left = false;
    right = false;
    fire = false;

    v.col = color(160, 255, 128);
    v.turnspd *= random(1.6, 2.4);
    v.speed *= random(0.6, 1);
    v.firerate *= random(1.6, 2.4);
  }

  void tick() {
    if (world.redWing != null)
      target = world.redWing;
    if (target != null) {
      float tempx = target.pos.x-vehicle.pos.x;
      float tempy = target.pos.y-vehicle.pos.y;

      if (tempx > FIELDX*CELLSIZE/2)
        tempx -= FIELDX*CELLSIZE;
      else if (tempx < -FIELDX*CELLSIZE/2)
        tempx += FIELDX*CELLSIZE;

      if (tempy > FIELDY*CELLSIZE/2)
        tempy -= FIELDY*CELLSIZE;
      else if (tempy < -FIELDY*CELLSIZE/2)
        tempy += FIELDY*CELLSIZE;

      float tempa = atan2(tempy, tempx);
      tempa -= vehicle.dir;
      if (tempa > PI)
        tempa -= 2*PI;
      else if (tempa < -PI)
        tempa += 2*PI;

      if (tempa < -vehicle.turnspd/2)
        left = true;
      else if (tempa > vehicle.turnspd/2)
        right = true;

      if (abs(tempa) < 0.1)
        fire = true;

      if (dist(0, 0, tempx, tempy) > width+height) {
        if (abs(tempa) > 1)
          up = false;
        else up = true;
      } else
        up = true;

      vehicle.controls(left, right, up, false, fire);

      left = false;
      right = false;
      up = false;
      fire = false;
    }
    // Changes the hitbox to match the profile of the plane
    recheck();

    ArrayList<Controller> collided = world.collide(this);
    for (Controller c : collided) {
      if (c instanceof BulletController) {
        if (c.origin instanceof Player) {
          life--;
          vehicle.col = color(160, 255*life/compLife, 128*life/compLife);
          if (life == 0) {
            world.shake.add(signum(random(-1, 1))*random(6, 12), signum(random(-1, 1))*random(6, 12), 0);
            world.effects.add(new Explosion(vehicle.pos.x, vehicle.pos.y, random(60, 100)));
            world.removal.add(this);
            world.enemies--;
            if (world.enemies == 0) {
              world.addition.add(new Computer(new Plane(random(FIELDX*CELLSIZE), random(FIELDY*CELLSIZE))));
              world.enemies++;
            }
          } else {
            world.shake.add(signum(random(-1, 1))*random(2, 6), signum(random(-1, 1))*random(2, 6), 0);
            world.effects.add(new Explosion(vehicle.pos.x, vehicle.pos.y, random(16, 32)));
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
    if (vehicle.pos.x < world.screenPos.x-vehicle.sizex)
      translate(FIELDX*CELLSIZE, 0);
    else if (vehicle.pos.x > world.screenPos.x+width+vehicle.sizex)
      translate(-FIELDX*CELLSIZE, 0);

    if (vehicle.pos.y < world.screenPos.y-vehicle.sizez)
      translate(0, FIELDY*CELLSIZE);
    else if (vehicle.pos.y > world.screenPos.y+height+vehicle.sizez)
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

