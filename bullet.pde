final float BULLETVEL = 12;

class Bullet extends Object {

  Bullet(Object origin) {
    pos = new PVector(origin.pos.x, origin.pos.y);
    dir = origin.dir;
    last = new PVector(origin.last.x-cos(dir)*BULLETVEL, origin.last.y-sin(dir)*BULLETVEL);
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
    stroke(255, 128+128*controller.life/120);
    line(0, 0, 16, 0);
    popMatrix();
  }
}

class BulletController extends Controller {  
  BulletController(Bullet b, Controller c) {
    vehicle = b;
    life = 120;

    location = new ArrayList();

    // Sets a static check size
    checkx = 0;
    checky = 0;

    b.controller = this;
    
    origin = c;
  }

  void tick() {
    life--;
    if (life == 0) {
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
}

