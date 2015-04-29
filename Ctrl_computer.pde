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
    ((Plane)v).body.init(this);
    v.terminal = new PVector(FRICTION/(1-FRICTION)*((Plane)v).engine.speed, FRICTION/(1-FRICTION)*v.gravity);

    origin = null;

    target = null;

    comp = new Input();

    v.col = color(160, 255, 128);
    ((Plane)v).engine.speed *= random(.9, 1.1);
    ((Plane)v).gun.firerate *= random(2, 2.4);
    ((Plane)v).engine.turnspd *= random(.8, 1.2);
    if (((Plane)v).gun instanceof MachineGun || ((Plane)v).gun instanceof ChainGun) {
      ((Plane)v).gun.multiplier = 0.7;
    } else if (((Plane)v).gun instanceof LaserBeam) {
      ((Plane)v).gun.multiplier = 0.2;
    } else if (((Plane)v).gun instanceof GrenadeLauncher) {
      ((Plane)v).gun.multiplier = 0.8;
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
      tempa -= vehicle.dir;
      if (tempa > PI)
        tempa -= 2*PI;
      else if (tempa < -PI)
        tempa += 2*PI;

      if (tempa < -((Plane)vehicle).engine.turnspd/2)
        comp.dirkey = -1;
      else if (tempa > ((Plane)vehicle).engine.turnspd/2)
        comp.dirkey = 1;

      if (abs(tempa) < 0.1){
        comp.zkey = true;
        if(((Plane)vehicle).gun instanceof LaserBeam || ((Plane)vehicle).gun instanceof ChainGun){
          if(((Plane)vehicle).gun.max())
            comp.zkey = false;
        }
      }

      float tempd = dist(0, 0, tempx, tempy);

      ((Plane)vehicle).gun.gain = -tempd/256;

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


      if (((Plane)vehicle).engine instanceof Jet) {
        if(tempd > 100 && abs(tempa) < .4)
          comp.xkey = true;
      } else if(((Plane)vehicle).engine instanceof Chaos) {
        if(tempd < 100)
          comp.xkey = true;
      } else if(((Plane)vehicle).engine instanceof Prop) {
        if(tempd < 200)
          comp.xkey = true;
      }

      ((Plane)vehicle).controls(comp);

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

  /*
   * Obsolete
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
  */

  // Cell override for better hit detection
  void update() {
    // Removes contoller from previously occupied cells
    for (Cell c : location)
      c.occupants.remove(this);
    // Clears occupied cells
    location.clear();

    int tlocx = floor(vehicle.pos.x/CELLSIZE);
    int tlocy = floor(vehicle.pos.y/CELLSIZE);
    for (float i = -vehicle.sizex/CELLSIZE-.5; i <= vehicle.sizex/CELLSIZE+.5; i++){
      int cx = int(i*cos(vehicle.dir));
      int cy = int(i*sin(vehicle.dir));
      Cell tempc = world.getCell(cx+tlocx, cy+tlocy);
      if(!location.contains(tempc)){
        location.add(tempc);
        tempc.occupants.add(this);
      }
    }

    for (float i = -vehicle.sizez/CELLSIZE-.5; i <= vehicle.sizez/CELLSIZE+.5; i++){
      int cx = int(i*sin(vehicle.dir)*sin(vehicle.roll));
      int cy = int(i*cos(vehicle.dir)*sin(vehicle.roll));
      Cell tempc = world.getCell(cx+tlocx, cy+tlocy);
      if(!location.contains(tempc)){
        location.add(tempc);
        tempc.occupants.add(this);
      }
    }
  }
};

