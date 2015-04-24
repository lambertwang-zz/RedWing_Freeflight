// Gunhip is a heavily armored vehicle with two turrets
class Gunship extends Object {

  // Gunship specific fields
  Gun frontGun;
  Gun rearGun;
  GSBody body;
  GSEngine engine;

  Gunship(float x, float y, int g, int b, int e) {
    pos = new PVector(x, y);
    last = new PVector(x, y);

    sizex = 48;
    sizey = 32;
    sizez = 32;
    dir = 0;
    roll = 0;

    controller = null;

    col = color(0, 0, 0);
    g = 1;
    switch(g) {
    case 1: 
      frontGun = new MachineGun(10, this);
      rearGun = new MachineGun(10, this);
      break;
    case 2:
      frontGun = new LaserBeam(this);
      rearGun = new LaserBeam(this);
      break;
    case 3:
      frontGun = new ChainGun(2, this);
      rearGun = new ChainGun(2, this);
      break;
    case 4:
      frontGun = new GrenadeLauncher(20, this);
      rearGun = new GrenadeLauncher(20, this);
    }
    frontGun.offset.set(24, 32, PI/4);
    rearGun.offset.set(-24, 32, PI*3/4);

    switch(b) {
    case 1: 
      body = new GSStandard(this);
      break;
    }

    switch(e) {
    case 1: 
      engine = new GSProp(this);
      break;
    }
  }

  void render() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(dir);
    noStroke();
    /*
    For rendering the planes, two shapes are drawn:
     one for the wings and one for the body.
     The height of the shapes is scaled based off of the roll in order to 
     give the illusion that the planes are 2d silhouettes of 3d objects.
     */
    float xplane = sin(roll);
    float yplane = cos(roll);
    frontGun.render();
    rearGun.render();
    fill(col);
    engine.render(xplane);
    body.render(yplane);

    popMatrix();
  }

  // input sent from the controller
  void controls(GunshipInput i) {
    
    //engine.boost(i.xkey);
    // Turning (or technically, changing pitch)
    //engine.turn(i.dirkey, i.upkey);

    // Accelerating
    float mdir = atan2(i.vert, i.horiz);
    last.add(cos(mdir)*-engine.speed, sin(mdir)*-engine.speed, 0);
    //world.effects.add(new Smoke(last.x, last.y, random(4, 8), color(random(192, 256)), i.upkey*random(4, 8))); // Contrails

    frontGun.shoot(i.frontgun);
    rearGun.shoot(i.reargun);
  }
};



