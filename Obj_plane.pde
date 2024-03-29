final float FRICTION = .9375; // 15 16ths
//final float FRICTION = 0.96875; // 31 32ths
final float GRAVITY = .6;


// Plane is a standard plane with average turning and speed
class Plane extends Object {

  // Plane specific fields
  Gun gun;
  Body body;
  Engine engine;

  Plane(float x, float y, int g, int b, int e) {
    pos = new PVector(x, y);
    last = new PVector(x, y);

    sizex = 32;
    sizey = 16;
    sizez = 32;
    dir = 0;
    roll = 0;

    controller = null;

    col = color(0, 0, 0);

    switch(g) {
    case 1: 
      gun = new MachineGun(8, this);
      break;
    case 2:
      gun = new LaserBeam(this);
      break;
    case 3:
      gun = new ChainGun(2, this);
      break;
    case 4:
      gun = new GrenadeLauncher(20, this);
    }
    gun.offset.set(32, 0, 0);

    switch(b) {
    case 1: 
      body = new Standard(this);
      break;
    case 2:
      body = new Heavy(this);
      break;
    case 3:
      body = new Slim(this);
      break;
    }

    switch(e) {
    case 1: 
      engine = new Prop(this);
      break;
    case 2:
      engine = new Jet(this);
      break;
    case 3:
      engine = new Chaos(this);
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
    gun.render();
    fill(col);
    engine.render(xplane);
    body.render(yplane);

    popMatrix();
  }

  // input sent from the controller
  void controls(Input input) {
    engine.boost(input.xkey);
    // Turning (or technically, changing pitch)
    engine.turn(input.dirkey, input.upkey);

    // Accelerating
    if (input.upkey > 0) {
      last.add(cos(dir)*-engine.speed*input.upkey, sin(dir)*-engine.speed*input.upkey, 0);
      world.effects.add(new Smoke(pos.x-cos(dir)*sizex, pos.y-sin(dir)*sizex, random(4, 8), color(random(192, 256)), input.upkey*random(4, 8))); // Contrails
    }

    gun.shoot(input.zkey);
  }
};

