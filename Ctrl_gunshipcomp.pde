final float GUNSHIPLIFE = 10;

// This is the enemy
class GunshipComp extends Controller {

  Object target;
  GunshipInput comp;

  GunshipComp(Object v) {
    vehicle = v;
    location = new ArrayList();
    // Sets a static check size
    checkx = ceil(max(v.sizex, v.sizey, v.sizez)/CELLSIZE);
    checky = checkx;

    maxLife = GUNSHIPLIFE;
    life = maxLife;

    v.controller = this;
    ((Gunship)v).body.init(this);
    v.terminal = new PVector(FRICTION/(1-FRICTION)*((Gunship)v).engine.speed, FRICTION/(1-FRICTION)*v.gravity);

    origin = null;

    target = null;

    comp = new GunshipInput();

    v.col = color(160, 255, 128);
    ((Gunship)v).engine.speed *= random(.9, 1.1);
    ((Gunship)v).rearGun.firerate *= random(2.4, 3.2);
    ((Gunship)v).frontGun.firerate *= random(2.4, 3.2);
    ((Gunship)v).engine.turnspd *= random(.8, 1.2);
    if (((Gunship)v).frontGun instanceof MachineGun || ((Gunship)v).frontGun instanceof ChainGun) {
      ((Gunship)v).frontGun.multiplier = 0.6;
      ((Gunship)v).rearGun.multiplier = 0.6;
    } else if (((Gunship)v).frontGun instanceof LaserBeam) {
      ((Gunship)v).frontGun.multiplier = 0.15;
      ((Gunship)v).rearGun.multiplier = 0.15;
    } else if (((Gunship)v).frontGun instanceof GrenadeLauncher) {
      ((Gunship)v).frontGun.multiplier = 0.7;
      ((Gunship)v).rearGun.multiplier = 0.7;
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
      if(tempx > width/2 || tempy > height/2)
        ((Player)world.redWing.controller).indicators.add(tempa);
      float tempfront = tempa-((Gunship)vehicle).frontGun.offset.z;
      float temprear = tempa-((Gunship)vehicle).rearGun.offset.z;

      if (tempfront > PI)
        tempfront -= 2*PI;
      else if (tempfront < -PI)
        tempfront += 2*PI;
      
      if (temprear > PI)
        temprear -= 2*PI;
      else if (temprear < -PI)
        temprear += 2*PI;

      if (abs(tempfront) < 0.1){
        comp.frontgun = true;
        if(((Gunship)vehicle).frontGun instanceof LaserBeam || ((Gunship)vehicle).frontGun instanceof ChainGun){
          if(((Gunship)vehicle).frontGun.max())
            comp.frontgun = false;
        }
      }

      if (abs(temprear) < 0.1){
        comp.reargun = true;
        if(((Gunship)vehicle).rearGun instanceof LaserBeam || ((Gunship)vehicle).rearGun instanceof ChainGun){
          if(((Gunship)vehicle).rearGun.max())
            comp.reargun = false;
        }
      }

      float tempd = dist(0, 0, tempx, tempy);

      if (tempd > 100) {
        comp.horiz = cos(tempa);
        comp.vert = sin(tempa);
      }

      ((Gunship)vehicle).controls(comp);

      comp.reset();
    }
    // Changes the hitbox to match the profile of the Gunship
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
          world.score++;
          if(world.score > world.hiscore){
            world.hiscore = world.score;
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
    // The visible x profile will always be vehicle.sizex since the Gunship's yaw is never changed. 
    float tempy = max(abs(cos(vehicle.roll)*vehicle.sizey), abs(sin(vehicle.roll)*vehicle.sizez));
    // Changes the hitbox to match the vehicle's profile
    checkx = ceil(max(tempax*vehicle.sizex, tempay*tempy)/CELLSIZE);
    checky = ceil(max(tempay*vehicle.sizex, tempax*tempy)/CELLSIZE);
  }
};

class GunshipInput {
  float vert = 0;
  float horiz = 0;
  float frontdir = 0;
  float reardir = 0;
  boolean frontgun = false;
  boolean reargun = false;

  GunshipInput() {
  }

  void reset() {
    vert = 0;
    horiz = 0;
    frontdir = 0;
    reardir = 0;
    frontgun = false;
    reargun = false;
  }
};

