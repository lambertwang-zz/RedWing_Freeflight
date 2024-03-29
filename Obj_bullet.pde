// Simple projectile 
final float BULLETVEL = 16;
final float BULLETDAM = 2.4;

final float CHAINVEL = 24;
final float CHAINDAM = 1.8;

final float GRENADEVEL = 15;
final float GRENADEGRAV = .08;
final float GRENADEDAM = 2.6;

class Bullet extends Object {

  Bullet(Object origin, PVector offset) {
    pos = new PVector(origin.pos.x, origin.pos.y);
    dir = origin.dir+offset.z;
    last = new PVector(origin.last.x-cos(dir)*BULLETVEL, origin.last.y-sin(dir)*BULLETVEL);
    col = origin.col;

    pos.add(offset.x*cos(dir)+offset.y*sin(dir), offset.x*sin(dir)+offset.y*cos(dir), 0);
    last.add(offset.x*cos(dir)+offset.y*sin(dir), offset.x*sin(dir)+offset.y*cos(dir), 0);
  }

  void tick() {
    if (pos.y < 0) { // Allows infinite translationg from ceiling to floor and side to side
      pos.y += FIELDY*CELLSIZE;
      last.y += FIELDY*CELLSIZE;
    }
    if (pos.y >= FIELDY*CELLSIZE) {
      pos.y -= FIELDY*CELLSIZE;
      last.y -= FIELDY*CELLSIZE;
    }
    if (pos.x < 0) {
      pos.x += FIELDX*CELLSIZE;
      last.x += FIELDX*CELLSIZE;
    }
    if (pos.x > FIELDX*CELLSIZE) {
      pos.x -= FIELDX*CELLSIZE;
      last.x -= FIELDX*CELLSIZE;
    }

    // Simple verlet integration for movement
    // Velocity is calculated from the delta of the last position and current position. 
    PVector temp = new PVector(pos.x, pos.y);
    pos.add(pos.x - last.x, pos.y - last.y, 0);
    last.set(temp.x, temp.y);
  }

  void render() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(dir);
    strokeWeight(2);
    stroke(col);
    line(0, 0, 16, 0);
    popMatrix();
  }
};

class BulletController extends Controller {  
  float damage;

  BulletController(Bullet b, Controller c, float d) {
    vehicle = b;
    life = 180;
    damage = d;

    location = new ArrayList();

    // Sets a static check size
    checkx = 0;
    checky = 0;

    b.controller = this;

    origin = c;
  }

  void tick() {
    life--;
    if (life <= 0) {
      world.removal.add(this);
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

  void collide(Controller c) {
    c.life -= BULLETDAM*damage;
    world.shake.add(signum(random(-1, 1))*random(4, 8), signum(random(-1, 1))*random(4, 8), 0);
    world.effects.add(new Explosion(c.vehicle.pos.x, c.vehicle.pos.y, random(4, 6)*effectsDensity));
    world.removal.add(this); 
  }
};

// Laser Beam

class Beam extends Object {
  PVector offset;

  Beam(Object origin, PVector offset) {
    pos = new PVector(origin.pos.x, origin.pos.y);
    dir = origin.dir+offset.z;
    this.offset = offset;
    pos = new PVector();
    pos.set(offset);
  }

  void tick() {
  }

  void render() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(dir);
    strokeWeight(2+sizex/200);
    stroke(frameCount%256, 255, 255);
    line(0, 0, sizex, 0);

    float xi = cos(dir);
    float yi = sin(dir);

    for (int i = (int)random(0, 32); i < sizex; i+= 128/effectsDensity) {
      world.effects.add(new Spark(pos.x+i*xi, pos.y+i*yi, random(8, 16), color(int(random(0, 255)), 255, 255), random(3, 4), random(0, 2*PI)));
    }


    popMatrix();
  }
};

class BeamController extends Controller {  
  float len;
  float damage;
  PVector offset;

  BeamController(Beam b, Controller c, float l, float d) {
    vehicle = b;
    life = l/4;
    damage = d;

    location = new ArrayList();

    b.controller = this;

    origin = c;

    len = 200+8*l;
    b.sizex = len;
    offset = b.offset;
  }

  void tick() {
    if (life < 0) {
      world.removal.add(this);
    }    
    vehicle.tick();
    update();
    life--;
  }

  // Update override because it's a laser beam
  void update() {
    vehicle.pos.set(origin.vehicle.pos.x, origin.vehicle.pos.y);
    vehicle.pos.add(offset.x*cos(vehicle.dir)+offset.y*sin(vehicle.dir), offset.x*sin(vehicle.dir)+offset.y*cos(vehicle.dir), 0);
    vehicle.dir = origin.vehicle.dir+offset.z;
    // Removes contoller from previously occupied cells
    for (Cell c : location)
      c.occupants.remove(this);
    // Clears occupied cells
    location.clear();
    // Adds cells in the x and y direction from the vehicle position to its array of occupied cells
    // Also adds this controller to the list of occupants for each cell
    for (float i = 0; i <= len; i += CELLSIZE) {
      Cell tempc = world.getCell(floor((vehicle.pos.x + i*cos(vehicle.dir))/CELLSIZE), floor((vehicle.pos.y + i*sin(vehicle.dir))/CELLSIZE));
      location.add(tempc);
      tempc.occupants.add(this);
    }
  }

  void render() {
    pushMatrix();
    vehicle.pos.set(origin.vehicle.pos.x, origin.vehicle.pos.y);
    vehicle.pos.add(offset.x*cos(vehicle.dir)+offset.y*sin(vehicle.dir), offset.x*sin(vehicle.dir)+offset.y*cos(vehicle.dir), 0);
    vehicle.render();

    popMatrix();
  }

  void collide(Controller c) {
    c.life -= damage*len/1024;
    for(int i = 0; i < effectsDensity; i++)
      world.effects.add(new Spark(c.vehicle.pos.x, c.vehicle.pos.y, random(8, 12), color(int(random(0, 255)), 255, 255), random(8, 12)*effectsDensity, random(0, 2*PI)));
  }
};

class Grenade extends Object {

  Grenade(Object origin, PVector offset) {
    pos = new PVector(origin.pos.x, origin.pos.y);
    dir = origin.dir+offset.z;
    dir += (abs(origin.dir-PI) > PI/2 ? -1 : 1)*0.2;
    roll = random(0, PI);
    last = new PVector(origin.last.x-cos(dir)*GRENADEVEL, origin.last.y-sin(dir)*GRENADEVEL);

    pos.add(offset.x*cos(dir)+offset.y*sin(dir), offset.x*sin(dir)+offset.y*cos(dir), 0);
    last.add(offset.x*cos(dir)+offset.y*sin(dir), offset.x*sin(dir)+offset.y*cos(dir), 0);
  }

  void tick() {
    if (pos.y < 0) { // Allows infinite translationg from ceiling to floor and side to side
      pos.y += FIELDY*CELLSIZE;
      last.y += FIELDY*CELLSIZE;
    }
    if (pos.y >= FIELDY*CELLSIZE) {
      pos.y -= FIELDY*CELLSIZE;
      last.y -= FIELDY*CELLSIZE;
    }
    if (pos.x < 0) {
      pos.x += FIELDX*CELLSIZE;
      last.x += FIELDX*CELLSIZE;
    }
    if (pos.x > FIELDX*CELLSIZE) {
      pos.x -= FIELDX*CELLSIZE;
      last.x -= FIELDX*CELLSIZE;
    }

    last.add(0, -GRENADEGRAV, 0);
    dir -= 0.1;
    roll -= 0.1;

    // Simple verlet integration for movement
    // Velocity is calculated from the delta of the last position and current position. 
    PVector temp = new PVector(pos.x, pos.y);
    pos.add(pos.x - last.x, pos.y - last.y, 0);
    last.set(temp.x, temp.y);
  }

  void render() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(dir);
    noStroke();
    fill(frameCount%256, 128, 128);
    float xr = cos(roll);
    float yr = sin(roll);
    beginShape();
    beginShape();
    vertex(8*xr, 2);
    vertex(2*xr, -8);
    vertex(-8*xr, -2);
    vertex(-2*xr, 8);
    endShape();
    fill(frameCount%256, 255, 255);
    beginShape();
    vertex(-8*yr, 2);
    vertex(2*yr, 8);
    vertex(8*yr, -2);
    vertex(-2*yr, -8);
    endShape();/*
    rect(-4, -8, 8, 16);
    fill(64, 128);
    rect(-5, -9, 10, 2);
    rect(-5, -3, 10, 6);
    rect(-5, 7, 10, 2);
    */
    popMatrix();
  }
};

class GrenadeController extends Controller {  
  float damage;

  GrenadeController(Grenade b, Controller c, float d) {
    vehicle = b;
    life = 90;
    damage = d;

    location = new ArrayList();

    // Sets a static check size
    checkx = 1;
    checky = 1;

    b.controller = this;

    origin = c;
  }

  void tick() {
    life--;
    if (life <= 0) {
      world.removal.add(this);
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

  void collide(Controller c) {
    c.life -= GRENADEDAM*damage;
    detonate();
    world.shake.add(signum(random(-1, 1))*random(4, 8), signum(random(-1, 1))*random(4, 8), 0);
    world.effects.add(new Explosion(c.vehicle.pos.x, c.vehicle.pos.y, 40));
    world.removal.add(this);
  }

  void detonate() {
    ArrayList<Controller> collateral = new ArrayList();
    checkx = 3;
    checky = 3;
    update();
    for(Cell c: location){
      for(Controller n: c.occupants){
        if(!collateral.contains(n)){
          if(origin instanceof Player) {
            if(!(n instanceof Player)){
              collateral.add(n);
            }
          } else if (n instanceof Player){
            collateral.add(n);
          }
        }
      }
    }
    for(Controller c: collateral){
      c.life -= GRENADEDAM*damage*.5;
    }
  }
};

class Chain extends Object {

  Chain(Object origin, PVector offset) {
    pos = new PVector(origin.pos.x, origin.pos.y);
    dir = origin.dir+random(-PI/8, PI/8)+offset.z;
    last = new PVector(origin.last.x-cos(dir)*CHAINVEL, origin.last.y-sin(dir)*CHAINVEL);

    pos.add(offset.x*cos(dir)+offset.y*sin(dir), offset.x*sin(dir)+offset.y*cos(dir), 0);
    last.add(offset.x*cos(dir)+offset.y*sin(dir), offset.x*sin(dir)+offset.y*cos(dir), 0);
  }

  void tick() {
    if (pos.y < 0) { // Allows infinite translationg from ceiling to floor and side to side
      pos.y += FIELDY*CELLSIZE;
      last.y += FIELDY*CELLSIZE;
    }
    if (pos.y >= FIELDY*CELLSIZE) {
      pos.y -= FIELDY*CELLSIZE;
      last.y -= FIELDY*CELLSIZE;
    }
    if (pos.x < 0) {
      pos.x += FIELDX*CELLSIZE;
      last.x += FIELDX*CELLSIZE;
    }
    if (pos.x > FIELDX*CELLSIZE) {
      pos.x -= FIELDX*CELLSIZE;
      last.x -= FIELDX*CELLSIZE;
    }

    // Simple verlet integration for movement
    // Velocity is calculated from the delta of the last position and current position. 
    PVector temp = new PVector(pos.x, pos.y);
    pos.add(pos.x - last.x, pos.y - last.y, 0);
    last.set(temp.x, temp.y);
  }

  void render() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(dir);
    strokeWeight(3);
    stroke(32, 255, 255);
    line(0, 0, CHAINVEL, 0);
    popMatrix();
  }
};

class ChainController extends Controller {  
  float damage;

  ChainController(Chain b, Controller c, float d) {
    vehicle = b;
    life = 40;
    damage = d;

    location = new ArrayList();

    // Sets a static check size
    checkx = 0;
    checky = 0;

    b.controller = this;

    origin = c;
  }

  void tick() {
    life--;
    if (life <= 0) {
      world.removal.add(this);
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

  void collide(Controller c) {
    c.life -= CHAINDAM*damage;
    world.shake.add(signum(random(-1, 1))*random(4, 8), signum(random(-1, 1))*random(4, 8), 0);
    world.effects.add(new Explosion(c.vehicle.pos.x, c.vehicle.pos.y, random(3, 4)*effectsDensity));
    world.removal.add(this);
  }
};

