final float COMPLIFE = 5;

// This is the enemy
class Computer extends Controller {

  Object target;
  Input comp;

  Computer(Object v) {
    vehicle = v;
    location = new ArrayList();
    // Sets a static check size
    checkx = ceil(max(v.sizex, v.sizey, v.sizez)/CELLSIZE);
    checky = checkx;

    maxLife = COMPLIFE;
    life = maxLife;

    v.controller = this;
    v.body.init(this);
    v.body.terminal = new PVector(FRICTION/(1-FRICTION)*v.engine.speed, FRICTION/(1-FRICTION)*v.body.gravity);

    origin = null;

    target = null;

    comp = new Input();

    v.col = color(160, 255, 128);
    v.engine.speed *= random(.9, 1.1);
    v.gun.firerate *= random(2, 2.4);
    v.engine.turnspd *= random(.8, 1.2);
    if (v.gun instanceof MachineGun || v.gun instanceof ChainGun) {
      v.gun.multiplier = 0.7;
    } else if (v.gun instanceof LaserBeam) {
      v.gun.multiplier = 0.2;
    } else if (v.gun instanceof GrenadeLauncher) {
      v.gun.multiplier = 0.8;
    }
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

      if (tempa < -vehicle.engine.turnspd/2)
        comp.dirkey = -1;
      else if (tempa > vehicle.engine.turnspd/2)
        comp.dirkey = 1;

      if (abs(tempa) < 0.1){
        comp.zkey = true;
        if(vehicle.gun instanceof LaserBeam || vehicle.gun instanceof ChainGun){
          if(vehicle.gun.max())
            comp.zkey = false;
        }
      }

      float tempd = dist(0, 0, tempx, tempy);

      comp.xkey = false;

      if (tempd > width+height) {
        if (abs(tempa) > 1)
          comp.upkey = 0;
        else {
          comp.upkey = 1;
        }
      } else {
        comp.upkey = 1;
      }


      if (vehicle.engine instanceof Jet) {
        if(tempd > 100 && abs(tempa) < .4)
          comp.xkey = true;
      } else if(vehicle.engine instanceof Chaos) {
        if(tempd < 100)
          comp.xkey = true;
      } else if(vehicle.engine instanceof Prop) {
        if(tempd < 200)
          comp.xkey = true;
      }

      vehicle.controls(comp);

      comp.reset();
    }
    // Changes the hitbox to match the profile of the plane
    recheck();

    ArrayList<Controller> collided = world.collide(this);
    for (Controller c : collided) {
      collide(c);
    }

    vehicle.tick();
    update();
  }

  void collide(Controller c) {    
    if (c.origin != null) {
      if (c.origin instanceof Player) {
        c.collide(this);
        vehicle.col = color(160, 255*life/maxLife, 128*life/maxLife);
        if (life <= 0) {
          world.shake.add(signum(random(-1, 1))*random(8, 16), signum(random(-1, 1))*random(8, 16), 0);
          world.effects.add(new Explosion(vehicle.pos.x, vehicle.pos.y, random(10, 16)*effectsDensity));
          world.removal.add(this);
          world.enemies--;
          if (world.enemies == 0) {
            world.difficulty++;
            for (int i = 0; i < world.difficulty; i++) {
              Object p;
              p = new Plane(random(world.redWing.pos.x+width/2, world.redWing.pos.x-width/2+FIELDX*CELLSIZE), 
              random(world.redWing.pos.y+height/2, world.redWing.pos.y-height/2+FIELDY*CELLSIZE), floor(random(1, NUMGUN+1)), floor(random(1, NUMBODY+1)), floor(random(1, NUMENG+1)));
              world.addition.add(new Computer(p));
              world.enemies++;
            }
          }
        }
      }
    }
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
};

