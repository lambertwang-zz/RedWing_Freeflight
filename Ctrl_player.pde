final float recoveryTime = 60;
final int stallTime = 90;
final float playerLife = 16;

// This is you
class Player extends Controller{
  int stall;
  Input input;

  ArrayList<Float> indicators;

  Player(Object v) {
    vehicle = v;
    location = new ArrayList();
    // Sets a static check size
    checkx = ceil(max(v.sizex, v.sizey, v.sizez)/CELLSIZE);
    checky = checkx;

    maxLife = playerLife;
    life = maxLife;
    stall = stallTime;
    indicators = new ArrayList();

    v.controller = this;
    ((Plane)v).body.init(this);
    origin = null;
    v.terminal = new PVector(FRICTION/(1-FRICTION)*((Plane)v).engine.speed, FRICTION/(1-FRICTION)*v.gravity);

    v.col = color(0, 255, 255);
  }

  void tick() {
    if(abs(vehicle.pos.x-vehicle.last.x) < vehicle.terminal.x/3) {
      if(stall > 0) {
        stall--;
      } else {
        if(abs(vehicle.dir-PI) > PI/2)
          vehicle.dir += 0.02;
        else
          vehicle.dir -= 0.02;
      }
    } else {
      stall = stallTime;
    }
    ((Plane)vehicle).controls(player);

    // Changes the hitbox to match the profile of the plane
    recheck();

    if (life < maxLife && stall > 0) {
      life += min(1/recoveryTime, maxLife-life);
      vehicle.col = color(0, 255*life/maxLife, 255*life/maxLife);
      // Bit level alpha change
      world.bleed = (world.bleed & 0xffffff) | (int(64*(1-life/maxLife)) << 24);
    }

    ArrayList<Controller> collided = world.collide(this);
    for (Controller c : collided) {
      collide(c);
    }

    vehicle.tick();
    update();
  }

  void collide(Controller c) {
    if (c.origin != null) {
      if (!(c.origin instanceof Player)) {
        c.collide(this);
        vehicle.col = color(0, 255*life/maxLife, 255*life/maxLife);
        world.bleed = (world.bleed & 0xffffff) | (int(64*(1-life/maxLife)) << 24);
        if (life <= 0) {
          world.shake.add(signum(random(-1, 1))*random(16, 32), signum(random(-1, 1))*random(16, 32), 0);
          world.effects.add(new Explosion(vehicle.pos.x, vehicle.pos.y, random(30, 40)*effectsDensity));
          world.removal.add(this);
          if(player == keyboard)
            world.overlayText = "R TO RESTART";
        }
      }
    }
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
    
    translate(vehicle.pos.x, vehicle.pos.y);
    if(stall <= 0){
      fill(0, 255, 255, (frameCount%60) > 30 ? 0 : 255);
      textFont(f12);
      text("STALLING", -38, 44);
    }
    noStroke();
    fill(0, 255, 255);
    for(float f: indicators){
      pushMatrix();
      rotate(f+PI);
      translate(64, 0);
      beginShape();
      vertex(2, 0);
      vertex(-2, 2);
      vertex(-2, -2);
      endShape();
      popMatrix();
    }
    indicators.clear();

    popMatrix();
  }

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

