import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class RedWing_Freeflight extends PApplet {


/* RedWing */
// Coded by Lambert Wang


/* 
 RedWing is a colorful 2d side-scrolling flying adventure.
 
 Heavily inspired by the game Luftrausers.
 */

/*
  How to play:
 Shoot enemies and avoid getting shot. 
 
 Controls:
 Left/Right Arrow Keys: Turn
 Up Arrow Key: Accelerate
 f Key: FIre
 */

World world;

public void setup() {
  // Drawing parameters
  colorMode(HSB);
  smooth();
  // Optimized for 60 fps
  frameRate(60);

  // 4:3
  //size(800, 600);
  //size(1024, 768);
  //size(1280, 960);

  // 16:9
  //size(800, 450);
  //size(1280, 720);
  //size(1266, 768);
  size(1440, 810);

  world = new World();
}

public void draw() {
  world.render();
}

abstract class Body {
  Object platform;
  float life;

  PVector terminal = new PVector(100, 100); // Terminal velocities in the x direction based off of speed and in the y direction based off of gravity
  float gravity = 1;

  Body() {
  }

  public void render(float yplane) {
  }

  public void init(Controller c) {
  }

  public void controlOverride() {
  }
}

class Standard extends Body {

  Standard(Object p) {
    platform = p;
    gravity = .6f;
  }

  public void render(float yplane) {
    beginShape();
    vertex(32, 0);
    vertex(32, -4*yplane);
    vertex(16, -8*yplane);
    vertex(12, -10*yplane);
    vertex(4, -10*yplane);
    vertex(0, -8*yplane);
    vertex(-20, -4*yplane);
    vertex(-28, -16*yplane);
    vertex(-32, -16*yplane);
    vertex(-32, 0);
    endShape();
  }
}

class Heavy extends Body {
  Heavy(Object p) {
    platform = p;
    gravity = .8f;
  }

  public void render(float yplane) {
    beginShape();
    vertex(32, 0);
    vertex(28, -8*yplane);
    vertex(16, -8*yplane);
    vertex(8, -12*yplane);
    vertex(0, -8*yplane);
    vertex(-24, -8*yplane);
    vertex(-28, -16*yplane);
    vertex(-32, -16*yplane);
    vertex(-32, 8*yplane);
    vertex(-28, 8*yplane);
    vertex(-24, 0);
    vertex(-16, 0);
    vertex(-8, 4*yplane);
    vertex(24, 4*yplane);
    endShape();
  }

  public void init(Controller c) {
    c.maxLife *= 1.25f;
    c.life = c.maxLife;
  }
}

class Slim extends Body {
  Slim(Object p) {
    platform = p;
    gravity = .5f;
  }

  public void render(float yplane) {  
    beginShape();
    vertex(32, 0);
    vertex(8, -8*yplane);
    vertex(-24, -4*yplane);
    vertex(-36, -12*yplane);
    vertex(-32, 0);
    endShape();
  }
  
  public void init(Controller c) {
    c.maxLife *= .8f;
    c.life = c.maxLife;
  }
}

class Mellee extends Body {
  Mellee(Object p) {
    platform = p;
  }

  public void render(float yplane) {  
    beginShape();
    vertex(32, 0);
    vertex(16, -8*yplane);
    vertex(-16, -4*yplane);
    vertex(-36, -16*yplane);
    vertex(-32, 0);
    vertex(-34, 4*yplane);
    vertex(-24, 0);
    endShape();
  }
}

class Reflector extends Body {
  Reflector(Object p) {
    platform = p;
  }

  public void render(float yplane) {  
    beginShape();
    vertex(32, 0);
    vertex(16, -8*yplane);
    vertex(-16, -4*yplane);
    vertex(-36, -16*yplane);
    vertex(-32, 0);
    vertex(-34, 4*yplane);
    vertex(-24, 0);
    endShape();
  }
}

abstract class Engine {
  float turnspd; // Amount of radians the vehicle is capable of changing its facing direction by in each frame
  float speed; // Name is misleading, actually refers to the change in velocity each frame while the plane is accelerating

  Object platform;

  Engine() {
    turnspd = PI/45;
    speed = 1.2f;
  }

  public void render(float yplane) {
  }

  public void turn(int d, boolean b) {
    platform.dir += d*turnspd;
    platform.roll += d*turnspd;
  }
}

class Prop extends Engine {
  Prop(Object p) {
    platform = p;
    turnspd = PI/30;
    speed = 1.2f;
  }

  public void render(float xplane) {
    beginShape();
    vertex(32, 0);
    vertex(16, 4*xplane);
    vertex(12, 24*xplane);
    vertex(8, 32*xplane);
    vertex(0, 32*xplane);
    vertex(-4, 24*xplane);
    vertex(-8, 4*xplane);
    vertex(-32, 0);
    vertex(-8, -4*xplane);
    vertex(-4, -24*xplane);
    vertex(0, -32*xplane);
    vertex(8, -32*xplane);
    vertex(12, -24*xplane);
    vertex(16, -4*xplane);
    endShape();
  }
}

class Jet extends Engine {
  Jet(Object p) {
    platform = p;
    turnspd = PI/45;
    speed = 1.6f;
  }

  public void render(float xplane) {
    beginShape();
    vertex(32, 0*xplane);
    vertex(8, 4*xplane);
    vertex(-16, 32*xplane);
    vertex(-24, 32*xplane);
    vertex(-16, 4*xplane);
    vertex(-32, 0);
    vertex(-16, -4*xplane);
    vertex(-24, -32*xplane);
    vertex(-16, -32*xplane);
    vertex(8, -4*xplane);
    endShape();
  }

  public void turn(int d, boolean b) {
    if (b) {
      platform.dir += d*turnspd/3;
      platform.roll += d*turnspd/3;
    } else {
      platform.dir += d*turnspd;
      platform.roll += d*turnspd;
    }
  }
}

abstract class Gun {
  Object platform;
  int firerate; // The minimum number of frames between shots
  int cooldown; // The number of frames remaining before a shot can be made
  float multiplier;


  Gun() {
  }

  public void shoot(boolean fire) {
  }

  public void render() {
  }
}

class MachineGun extends Gun {

  MachineGun(int fire, Object p) {
    firerate = fire;
    cooldown = 0;
    platform = p;
    multiplier = 1;
  }


  public void shoot(boolean fire) {
    if (fire)
      if (cooldown == 0) {
        Bullet b = new Bullet(platform);
        world.addition.add(new BulletController(b, platform.controller, multiplier));
        cooldown = firerate;
      }

    if (cooldown != 0)
      cooldown --;
  }
}

class LaserBeam extends Gun {
  float charge;

  LaserBeam(Object p) {
    platform = p;
    multiplier = 1;
  }


  public void shoot(boolean fire) {
    if (fire) {
      if (charge < 100)
        charge ++;
    } else if (charge > 5) {
      Beam b = new Beam(platform);
      world.addition.add(new BeamController(b, platform.controller, charge, multiplier));
      charge = 0;
    }
  }

  public void render() {
    if (charge > 5) {
      fill(frameCount%256, 255, 255);
      ellipse(32, 0, 5+charge/5, 5+charge/5);
    }
  }
}

// Contoller superclass refers to input method for manipulating the movement of vehicles
abstract class Controller {
  Object vehicle; // Object being controlled
  ArrayList<Cell> location; // List of cells occupied by the vehicle
  int checkx, checky; // Number of cells to check in each direction for collision

  float life; // Life or hitpoints remaining of the object
  float maxLife;

  Controller origin; // The controller that spawned this controller (Not always required)


  // Constructor
  Controller() {
  }

  // Updates the cell occupants and the plane location
  public void update() {
    // Removes contoller from previously occupied cells
    for (Cell c : location)
      c.occupants.remove(this);
    // Clears occupied cells
    location.clear();
    // Adds cells in the x and y direction from the vehicle position to its array of occupied cells
    // Also adds this controller to the list of occupants for each cell
    for (int i = floor (vehicle.pos.x/CELLSIZE)-checkx; i <= floor(vehicle.pos.x/CELLSIZE)+checkx; i++)
      for (int j = floor (vehicle.pos.y/CELLSIZE)-checky; j <= floor(vehicle.pos.y/CELLSIZE)+checky; j++) {
        Cell tempc = world.getCell(i, j);
        location.add(tempc);
        tempc.occupants.add(this);
      }
  }

  public void tick() {
  }

  // Draws the object
  public void render() {
  }

  // Resets the hitbox
  public void recheck() {
  }

  public void collide(Controller c) {
  }
}

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

    maxLife = 4;
    life = maxLife;

    v.controller = this;
    v.body.init(this);
    v.body.terminal = new PVector(FRICTION/(1-FRICTION)*v.engine.speed, FRICTION/(1-FRICTION)*v.body.gravity);

    origin = null;

    target = null;

    up = false;
    left = false;
    right = false;
    fire = false;

    v.col = color(160, 255, 128);
    v.engine.turnspd *= random(1.6f, 2.4f);
    v.engine.speed *= random(0.6f, 0.8f);
    v.gun.firerate *= random(1.6f, 2.4f);
    if (v.gun instanceof MachineGun) {
      v.gun.multiplier = random(0.6f, 0.8f);
    } else if (v.gun instanceof LaserBeam) {
      v.gun.multiplier = random(0.15f, 0.2f);
    }
  }

  public void tick() {
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
        left = true;
      else if (tempa > vehicle.engine.turnspd/2)
        right = true;

      if (abs(tempa) < 0.1f)
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
      collide(c);
    }

    vehicle.tick();
    update();
  }

  public void collide(Controller c) {    
    if (c.origin != null) {
      if (c.origin instanceof Player) {
        c.collide(this);
        vehicle.col = color(160, 255*life/maxLife, 128*life/maxLife);
        if (life <= 0) {
          world.shake.add(signum(random(-1, 1))*random(8, 16), signum(random(-1, 1))*random(8, 16), 0);
          world.effects.add(new Explosion(vehicle.pos.x, vehicle.pos.y, random(32, 48)));
          world.removal.add(this);
          world.enemies--;
          if (world.enemies == 0) {
            world.difficulty++;
            for (int i = 0; i < world.difficulty; i++) {
              Object p;
              p = new Plane(random(world.redWing.pos.x+width/2, world.redWing.pos.x-width/2+FIELDX*CELLSIZE), 
              random(world.redWing.pos.y+height/2, world.redWing.pos.y-height/2+FIELDY*CELLSIZE), floor(random(1, 3)), floor(random(1, 4)), floor(random(1, 3)));
              world.addition.add(new Computer(p));
              world.enemies++;
            }
          }
        }
      }
    }
  }

  public void render() {
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

  public void recheck() {
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

final float recoveryTime = 60;

// This is you
class Player extends Controller {
  Player(Object v) {
    vehicle = v;
    location = new ArrayList();
    // Sets a static check size
    checkx = ceil(max(v.sizex, v.sizey, v.sizez)/CELLSIZE);
    checky = checkx;

    maxLife = 16;
    life = maxLife;

    v.controller = this;
    v.body.init(this);
    origin = null;

    v.col = color(0, 255, 255);
  }

  public void tick() {
    vehicle.controls(lfkey, rtkey, upkey, dnkey, fkey);

    // Changes the hitbox to match the profile of the plane
    recheck();

    if (life < maxLife) {
      life += min(1/recoveryTime, maxLife-life);
      vehicle.col = color(0, 255*life/maxLife, 255*life/maxLife);
      // Bit level alpha change
      world.bleed = (world.bleed & 0xffffff) | (PApplet.parseInt(128*(1-life/maxLife)) << 24);
    }

    ArrayList<Controller> collided = world.collide(this);
    for (Controller c : collided) {
      collide(c);
    }

    vehicle.tick();
    update();
  }

  public void collide(Controller c) {
    if (c.origin != null) {
      if (c.origin instanceof Computer) {
        c.collide(this);
        vehicle.col = color(0, 255*life/maxLife, 255*life/maxLife);
        world.bleed = (world.bleed & 0xffffff) | (PApplet.parseInt(128*(1-life/maxLife)) << 24);
        if (life <= 0) {
          world.shake.add(signum(random(-1, 1))*random(16, 32), signum(random(-1, 1))*random(16, 32), 0);
          world.effects.add(new Explosion(vehicle.pos.x, vehicle.pos.y, random(120, 160)));
          world.removal.add(this);
        }
      }
    }
  }

  public void render() {
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

  public void recheck() {
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

// Simple projectile 
final float BULLETVEL = 12;

class Bullet extends Object {

  Bullet(Object origin) {
    pos = new PVector(origin.pos.x, origin.pos.y);
    dir = origin.dir;
    last = new PVector(origin.last.x-cos(dir)*BULLETVEL, origin.last.y-sin(dir)*BULLETVEL);
  }

  public void tick() {
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

  public void render() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(dir);
    strokeWeight(2);
    stroke(255, 192+64*controller.life/120);
    line(0, 0, 16, 0);
    popMatrix();
  }
}

class BulletController extends Controller {  
  float damage;

  BulletController(Bullet b, Controller c, float d) {
    vehicle = b;
    life = 120;
    damage = d;

    location = new ArrayList();

    // Sets a static check size
    checkx = 0;
    checky = 0;

    b.controller = this;

    origin = c;
  }

  public void tick() {
    life--;
    if (life <= 0) {
      world.removal.add(this);
    }
    vehicle.tick();
    update();
  }

  public void render() {
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

  public void collide(Controller c) {
    c.life -= 1.8f*damage;
    world.shake.add(signum(random(-1, 1))*random(4, 8), signum(random(-1, 1))*random(4, 8), 0);
    world.effects.add(new Explosion(c.vehicle.pos.x, c.vehicle.pos.y, random(16, 24)));
    world.removal.add(this);
  }
}

// Laser Beam

class Beam extends Object {

  Beam(Object origin) {
    pos = new PVector(origin.pos.x, origin.pos.y);
    dir = origin.dir;
  }

  public void tick() {
  }

  public void render() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(dir);
    strokeWeight(2+sizex/200);
    stroke(frameCount%256, 255, 255);
    line(24, 0, sizex, 0);

    float xi = cos(dir);
    float yi = sin(dir);

    for (int i = 32; i < sizex; i+= 32) {
      world.effects.add(new Spark(pos.x+i*xi, pos.y+i*yi, random(8, 16), color(PApplet.parseInt(random(0, 255)), 255, 255), PApplet.parseInt(random(6, 8)), random(0, 2*PI)));
    }


    popMatrix();
  }
}

class BeamController extends Controller {  
  float len;
  float damage;

  BeamController(Beam b, Controller c, float l, float d) {
    vehicle = b;
    life = l/4;
    damage = d;

    location = new ArrayList();

    b.controller = this;

    origin = c;

    len = 200+8*l;
    b.sizex = len;
  }

  public void tick() {
    if (life < 0) {
      world.removal.add(this);
    }    
    vehicle.tick();
    update();
    life--;
  }

  // Update override because it's a laser beam
  public void update() {
    vehicle.pos.set(origin.vehicle.pos.x, origin.vehicle.pos.y);
    vehicle.dir = origin.vehicle.dir;
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

  public void render() {
    pushMatrix();
    vehicle.pos.set(origin.vehicle.pos.x, origin.vehicle.pos.y);
    vehicle.render();

    popMatrix();
  }

  public void collide(Controller c) {
    c.life -= damage*len/1024;
    world.effects.add(new Explosion(c.vehicle.pos.x, c.vehicle.pos.y, random(8, 12)));
  }
}

final float FRICTION = .9375f; // 15 16ths
final float gravity = .6f;


// Plane is a standard plane with average turning and speed
class Plane extends Object {
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
      gun = new MachineGun(10, this);
      break;
    case 2:
      gun = new LaserBeam(this);
      break;
    }

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
    }
  }

  public void render() {
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
}

// Superclass Object is a body which exist in the world. 
// They must exist with a controller
abstract class Object {

  PVector pos; // Current position and previous frame position
  PVector last; // Last is used for verlet integration. See wikipedia for more information

  // Radii
  float sizex; // Tail to nose /2
  float sizey; // Wingspan /2
  float sizez; // Bottom to top
  float dir; // Direction plane is facing in radians
  float roll; // The roll of the plane in radians (aka rotation about the local x axis)

  Controller controller; // Controller related to the object

  int col; // Color of the object
  
  // Plane specific fields
  Gun gun;
  Body body;
  Engine engine;

  // Constructor
  Object() {
  }

  public void tick() {
    // Ensures dir is always between 0 and 2*PI
    if (dir < 0) 
      dir += 2*PI; 
    dir %= 2*PI;
    // Same for roll
    if (roll < 0) 
      roll += 2*PI; 
    roll %= 2*PI;

    // Makes the roll level out
    if (dir < PI/2 || dir > 3*PI/2) { // Checks if vehicle is facing right
      if (roll < PI) // If nose is pitched up, roll will be between 0 and PI
          roll *= 0.98f; // In this case, roll approaches 0
      else // If nose is pitched down, roll will be between PI and 2*PI
      roll = (roll - 2*PI)*.98f; // Otherwise, roll approaches 2*PI
    } else { // If plane is facing left
      roll = PI + (roll - PI)*.98f; // Roll will approach PI
    }

    if (pos.y < 0) { // Allows infinite translation from ceiling to floor and side to side
      pos.y += FIELDY*CELLSIZE; // IE you can fly off one side of the screen and re-appear on the other
      last.y += FIELDY*CELLSIZE; // There is no visual feedback when this happens due to the screen scrolling and rendering with the plane
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

    // Gravity
    last.add(0, -body.gravity*(1-abs(pos.x - last.x)/body.terminal.x), 0); // As the x velocity increases, the plane generates lift, and gravity has less of an effect

    // Simple verlet integration for movement
    // Velocity is calculated from the delta of the last position and current position. 
    PVector temp = new PVector(pos.x, pos.y);
    pos.add(FRICTION*(pos.x - last.x), FRICTION*(pos.y - last.y), 0);
    last.set(temp.x, temp.y);
  }

  public void render() {
  }

  // input sent from the controller
  public void controls(boolean left, boolean right, boolean up, boolean down, boolean fire) {
    // Turning (or technically, changing pitch)
    if (left) {
      engine.turn(-1, up);
    }
    if (right) {
      engine.turn(1, up);
    } 

    // Accelerating
    if (up) {
      last.add(cos(dir)*-engine.speed, sin(dir)*-engine.speed, 0);
      world.effects.add(new Smoke(last.x, last.y, random(4, 8), color(random(192, 256)), random(4, 8))); // Contrails
    }

    gun.shoot(fire);
  }
}

/* Particle effects */

/*
  Effects:
 Spark
 Smoke
 Eclipse
 Explosion (compound effect)
 */

// Determines how long the shaking lasts for
final float shakeReduction = -0.95f;

abstract class Particle {
  float size;
  float lifetime; // Initial life time in frames
  float remaining; // Remaining life time
  float xpos, ypos;
  int col; // Color

  Particle() {
  }

  public void render() {
    if (xpos > world.screenPos.x-size && xpos < world.screenPos.x+size+width &&
      ypos > world.screenPos.y-size && ypos < world.screenPos.y+size+height)
      show();

    remaining--;
  }

  public void show() {
  }
}

class Spark extends Particle { // Sparks are circles that fly some distance then fade
  float ang;

  Spark(float tx, float ty, float ts, int tcol, float tl, float ta) {
    xpos = tx;
    ypos = ty;
    size = ts; // Not physical size, but distance spark flies

      col = tcol;

    ang = ta;

    lifetime = tl;
    remaining = lifetime;
  }



  public void show() {
    float temp = remaining/lifetime; // Slightly reduce computatuions
    stroke(col, 255*temp);
    strokeWeight(1.5f);
    pushMatrix();
    translate(xpos, ypos);
    rotate(ang);
    translate(size*(1-temp), 0);
    noFill();
    ellipse(0, 0, 3, 3);
    popMatrix();
  }
}

class Smoke extends Particle { // Smoke is a circle that fades

  Smoke(float tx, float ty, float ts, int tcol, float tl) {
    xpos = tx;
    ypos = ty;
    size = ts;

    col = tcol;

    lifetime = tl;
    remaining = lifetime;
  }

  public void show() {
    noStroke();
    fill(col, 255*remaining/lifetime);
    pushMatrix();
    translate(xpos, ypos);
    ellipse(0, 0, size, size);
    popMatrix();
  }
}

class Eclipse extends Particle { // Eclipse is a circle that dissolves into a crescent
  float ang;


  Eclipse(float tx, float ty, float ts, int tcol, float tl) {
    xpos = tx;
    ypos = ty;
    size = ts;

    ang = random(0, 2*PI);

    col = tcol;

    lifetime = tl;
    remaining = lifetime;
  }

  public void show() {
    float temp = remaining/lifetime;
    noStroke();
    fill(col, 255*temp);
    pushMatrix();
    translate(xpos, ypos);
    rotate(ang);
    beginShape();
    bezierCircle(0, 0, size); 
    bezierCircleInv(0, size*temp, size*(1-temp)); // That's no moon
    endShape();
    popMatrix();
  }
}

class Explosion extends Particle { // Explosions are complex particles IE they solely consist of primitive particles
  ArrayList<Particle> parts;

  Explosion (float tx, float ty, float ts) {
    xpos = tx;
    ypos = ty;
    size = ts;

    parts = new ArrayList();

    for (int i = 0; i < size/8; i++)
      parts.add(new Smoke(xpos+random(-size, size), ypos+random(-size, size), random(size/4, size/2), color(0, 0, PApplet.parseInt(random(0, 255))), PApplet.parseInt(random(40, 60))));
    for (int i = 0; i < size/12; i++)
      parts.add(new Eclipse(xpos+random(-size/2, size/2), ypos+random(-size/2, size/2), random(size/4, size/2), color(PApplet.parseInt(random(0, 256)), 255, 255), PApplet.parseInt(random(30, 45))));
    for (int i = 0; i < size/6; i++)
      parts.add(new Spark(xpos+random(-size/2, size/2), ypos+random(-size/2, size/2), random(size, 2*size), color(PApplet.parseInt(random(0, 255)), 255, 255), PApplet.parseInt(random(30, 45)), random(0, 2*PI)));
    remaining = parts.size(); // Lifetime is number of particles remaining in the explosion
  }

  public void render() { // Essentially same as renderEffects();
    for (Particle p : parts)
      p.render(); // Boom (Add "Sound effects" to ToDo list

    for (int i = parts.size ()-1; i >= 0; i--)
      if (parts.get(i).remaining == 0)
        parts.remove(i);

    remaining = parts.size();
  }
}

final float c = 4*(sqrt(2)-1)/3; // Constant to make circles with bezier curves

public void bezierCircle(float x, float y, float r) {
  vertex(x, y+r);
  bezierVertex(x+c*r, y+r, x+r, y+c*r, x+r, y); // Go to Processing documentation or Wikipedia to learn how bezier curves work
  bezierVertex(x+r, y-c*r, x+c*r, y-r, x, y-r);
  bezierVertex(x-c*r, y-r, x-r, y-c*r, x-r, y);
  bezierVertex(x-r, y+c*r, x-c*r, y+r, x, y+r);
}

public void bezierCircleInv(float x, float y, float r) {
  vertex(x, y+r);
  bezierVertex(x-c*r, y+r, x-r, y+c*r, x-r, y);
  bezierVertex(x-r, y-c*r, x-c*r, y-r, x, y-r);
  bezierVertex(x+c*r, y-r, x+r, y-c*r, x+r, y);
  bezierVertex(x+r, y+c*r, x+c*r, y+r, x, y+r);
}

// Stored values of whether or not keys are held down
boolean upkey = false;
boolean dnkey = false;
boolean lfkey = false;
boolean rtkey = false;
boolean fkey = false;

public void keyPressed() {
  if (key == CODED) // Arrow keys are referred to by a keyCode enum
    switch(keyCode) {
    case UP:
      upkey = true;
      break;
    case DOWN:
      dnkey = true;
      break;
    case LEFT: // To prevent sticky movement, left and write override eachother
      lfkey = true;
      rtkey = false;
      break;
    case RIGHT: 
      rtkey = true;
      lfkey = false;
      break;
    } else if (key == 'z' || key == 'Z') {
    fkey = true;
  } else if (key == 'o' || key == 'O') {
    screenShot();
  } else if (key == 'r' || key == 'R') {
    world = new World();
  }
}

public void keyReleased() {
  if (key == CODED)
    switch(keyCode) {
    case UP:
      upkey = false;
      break;
    case DOWN:
      dnkey = false;
      break;
    case LEFT:
      lfkey = false;
      break;
    case RIGHT:
      rtkey = false;
      break;
    } else if (key == 'z' || key == 'Z') {
    fkey = false;
  }
}

// Saves precious memories
public void screenShot() {
  save("screenshots/screenshot-"+day()+month()+year()+"-"+hour()+minute()+second()+".png");
  println("Screenshot saved: "+"screenshots/screenshot-"+day()+month()+year()+"-"+hour()+minute()+second()+".png");
}

public int signum(float n){
  return (n < 0) ? -1 : 1;
}

// dimensions 26.5, 7
public void redWing(float x, float y, float h) {
  float u = h/7;
  pushMatrix();
  translate(x, y);
  // R  
  beginShape();
  vertex(0, 0);
  vertex(.5f*u, u);
  vertex(1.5f*u, u);
  bezierVertex(u*(1.5f+c), u, 2.5f*u, u*(2-c), 2.5f*u, 2*u);
  bezierVertex(2.5f*u, u*(2+c), u*(1.5f+c), 3*u, 1.5f*u, 3*u);
  vertex(1*u, 3*u);
  vertex(1.5f*u, 4*u);
  bezierVertex(u*(1.5f+c*2), 4*u, 3.5f*u, u*(2+c*2), 3.5f*u, 2*u);
  bezierVertex(3.5f*u, u*(2-c*2), u*(1.5f+c*2), 0, 1.5f*u, 0);
  endShape();

  beginShape();
  vertex(1*u, 1.5f*u);
  vertex(1*u, 6.5f*u);
  vertex(0*u, 7*u);
  vertex(0*u, 1*u);
  endShape();
  
  beginShape();
  vertex(1*u, 3*u);
  vertex(1.5f*u, 3*u);
  bezierVertex(u*(1.5f+c*2), 3*u, 3.5f*u, u*(5-c*2), 3.5f*u, 5*u);
  vertex(3.5f*u, 6.5f*u);
  vertex(2.5f*u, 7*u);
  vertex(2.5f*u, 5*u);
  bezierVertex(2.5f*u, u*(5-c), u*(1.5f+c), 4*u, 1.5f*u, 4*u);
  endShape();
    
  translate(.5f*u, 0);
  // E
  beginShape();
  vertex(3.5f*u, 5*u);
  bezierVertex(u*(3.5f), u*(5-2*c), u*(5.5f-2*c), u*(3), 5.5f*u, 3*u);
  bezierVertex(u*(5.5f+2*c), u*(3), u*(7.5f), u*(5-c*2), 7.5f*u, 5*u);
  vertex(6.5f*u, 5.5f*u);
  vertex(5.5f*u, 5.5f*u);
  vertex(4.5f*u, 5*u);
  vertex(6.5f*u, 5*u);
  bezierVertex(u*(6.5f), u*(5-c), u*(5.5f+c), u*(4), 5.5f*u, 4*u);
  bezierVertex(u*(5.5f-c), u*(4), u*(4.5f), u*(5-c), 4.5f*u, 5*u);
  bezierVertex(u*(4.5f), u*(5+c), u*(5.5f-c), u*(6), 5.5f*u, 6*u);
  vertex(7.5f*u, 6*u);
  vertex(7*u, 7*u);
  vertex(5.5f*u, 7*u);
  bezierVertex(u*(5.5f-c*2), u*(7), u*3.5f, u*(5+c*2), 3.5f*u, 5*u);  
  endShape();
  
  translate(8*u, 0);
  // D
  beginShape();
  vertex(3*u, 2*u);
  vertex(4*u, 1.5f*u);
  vertex(4*u, 7*u);
  vertex(3*u, 6.5f*u);
  endShape();

  beginShape();
  vertex(2*u, 3*u);
  vertex(3*u, 3*u);
  vertex(2.5f*u, 4*u);
  vertex(2*u, 4*u);
  bezierVertex(u*(2-c), 4*u, u, u*(5-c), u, u*5);
  bezierVertex(u, u*(5+c), u*(2-c), u*(6), u*2, u*6);
  bezierVertex(u*(2+c), u*6, u*3, u*(5+c), u*3, u*5);
  vertex(u*4, u*5);
  bezierVertex(u*4, u*(5+2*c), u*(2+2*c), u*7, u*2, u*7);
  bezierVertex(u*(2-2*c), u*7, 0, u*(5+2*c), 0, u*5);
  bezierVertex(0, u*(5-2*c), u*(2-2*c), u*3, u*2, u*3);
  endShape();
  
  translate(-4*u, 0);
  // W
  beginShape();
  vertex(-1.5f*u, 0);
  vertex(9*u, 0);
  vertex(10*u, 6*u);
  vertex(9*u, 6*u);
  vertex(u*(8+1.0f/6), u);
  vertex(-1*u, u);
  endShape();
  
  translate(8*u, 0);
  
  beginShape();
  vertex(2*u, 3*u);
  vertex(2.5f*u, 6*u);
  vertex(3.5f*u, 6*u);
  vertex(3*u, 3*u);
  endShape();
  
  beginShape();
  vertex(u*(3.375f), 2.25f*u);
  vertex(u*(3.875f), u*(5.25f));
  vertex(u*(4.75f-1.0f/6), u);
  vertex(u*14, u);
  vertex(u*14.5f, 0);
  vertex(u*3.75f, 0);
  endShape();
  
  translate(4*u, 0);
  // I
  beginShape();
  vertex(u*.5f, u*2.5f);
  vertex(u*.5f, u*7);
  vertex(u*1.5f, u*6.5f);
  vertex(u*1.5f, u*3);
  endShape();
  
  beginShape();
  vertex(u*.5f, u*2);
  bezierVertex(u*.5f, u*(2+c/2), u*(1-c/2), u*2.5f, u*1, u*2.5f);
  bezierVertex(u*(1+c/2), u*2.5f, u*1.5f, u*(2+c/2), u*1.5f, u*2);
  bezierVertex(u*1.5f, u*(2-c/2), u*(1+c/2), u*1.5f, u*1, u*1.5f);
  bezierVertex(u*(1-c/2), u*1.5f, u*.5f, u*(2-c/2), u*.5f, u*2);
  endShape();
  // N
  beginShape();
  vertex(2*u, 2.5f*u);
  vertex(2*u, 7*u);
  vertex(3*u, 6.5f*u);
  vertex(3*u, 3*u);
  endShape();
  
  beginShape();
  vertex(3.5f*u, 3*u);
  vertex(4*u, 3*u);
  bezierVertex(u*(4+c*2), u*3, u*6, u*(5-c*2), u*6, u*5);
  vertex(u*6, u*6.5f);
  vertex(u*5, u*7);
  vertex(u*5, u*5);
  bezierVertex(u*5, u*(5-c), u*(4+c), u*4, u*4, u*4);
  vertex(u*3, u*4);
  endShape();
  
  translate(6*u, 0);
  // G
  beginShape();
  vertex(2.5f*u, 1.5f*u);
  vertex(3.5f*u, 1.5f*u);
  vertex(3*u, 2.5f*u);
  vertex(2.5f*u, 2.5f*u);
  bezierVertex(u*(2.5f-c), 2.5f*u, u*1.5f, u*(3.5f-c), u*1.5f, u*3.5f);
  bezierVertex(u*1.5f, u*(3.5f+c), u*(2.5f-c), u*(4.5f), u*2.5f, u*4.5f);
  bezierVertex(u*(2.5f+c), u*4.5f, u*3.5f, u*(3.5f+c), u*3.5f, u*3.5f);
  vertex(u*3.5f, u*1.5f);
  vertex(u*4.5f, u*1);
  vertex(u*4.5f, u*3.5f);
  bezierVertex(u*4.5f, u*(3.5f+2*c), u*(2.5f+2*c), u*5.5f, u*2.5f, u*5.5f);
  bezierVertex(u*(2.5f-2*c), u*5.5f, u*.5f, u*(3.5f+2*c), u*.5f, u*3.5f);
  bezierVertex(u*.5f, u*(3.5f-2*c), u*(2.5f-2*c), u*1.5f, u*2.5f, u*1.5f);
  endShape();
  
  beginShape();
  vertex(u*.5f, u*5.5f);
  vertex(u*.5f, u*6);
  bezierVertex(u*.5f, u*(6+c), u*(1.5f-c), u*7, u*1.5f, u*7);
  vertex(u*2.5f, u*7);
  bezierVertex(u*(2.5f+2*c), u*7, u*4.5f, u*(5+c*2), u*4.5f, u*5);
  vertex(u*4.5f, u*4);
  bezierVertex(u*4.5f, u*(4+c*2), u*(2.5f+c*2), u*6, u*2.5f, u*6);
  vertex(u*1.5f, u*6);
  endShape();

  popMatrix();
}

// Currently implements a cell based hitscan system; however, it isn't used because there aren't any other objects to collide with.

final int FIELDX = 768; // Number of cells in the x and y directions of the field
final int FIELDY = 256;
final int CELLSIZE = 16; // Pixel size of each cell

final int SCREENFOLLOW = 8; // Amount to shift the screen by to follow RedWing

class World {
  Cell[][] cells;
  PVector screenPos; // Location of the screen
  Object redWing; // The star of the show
  ArrayList<Controller> actors; // List of redWing. Literally contains nothing except redWing for now
  ArrayList<Controller> addition; // list of objects to be added in the next frame
  ArrayList<Controller> removal; // List of objects to be removed from actors this tick

  int enemies;
  int difficulty;


  ArrayList<Particle> effects;
  PVector shake;

  int bleed;

  boolean showHitboxes;

  World() {
    cells = new Cell[FIELDX][FIELDY]; // Initiliazes cells
    for (int i = 0; i < FIELDX; i++)
      for (int j = 0; j < FIELDY; j++)
        cells[i][j] = new Cell(i, j);

    screenPos = new PVector(0, 0);
    redWing = new Plane(0, 0, floor(random(1, 3)), floor(random(1, 4)), floor(random(1, 3)));
    actors = new ArrayList();
    addition = new ArrayList();
    removal = new ArrayList();

    actors.add(new Player(redWing));

    enemies = 0;
    difficulty = 2;
    actors.add(new Computer(new Plane(random(FIELDX*CELLSIZE), random(FIELDY*CELLSIZE), floor(random(1, 3)), floor(random(1, 4)), floor(random(1, 3)))));
    enemies++;

    effects = new ArrayList();
    shake = new PVector(0, 0);

    bleed = color(160, 255, 255, 0);

    showHitboxes = false;
  }

  public void render() {
    background(0);
    for (Controller c : removal) {
      actors.remove(c);
      for (Cell l : c.location) {
        l.occupants.remove(c);
      }
    }
    removal.clear();

    for (Controller c : addition)
      actors.add(0, c);

    addition.clear();

    for (Controller c : actors)
      c.tick(); // Magic happens

    PVector target = new PVector(); // Offset vector based off of redWing's position and velocity for the screen position
    target.set((SCREENFOLLOW+1)*redWing.pos.x - width/2 - SCREENFOLLOW*redWing.last.x, (SCREENFOLLOW+1)*redWing.pos.y - height/2 - SCREENFOLLOW*redWing.last.y);

    screenPos.x = target.x+shake.x;
    screenPos.y = target.y+shake.y;

    pushMatrix();
    translate(-screenPos.x, -screenPos.y);
    shake.mult(shakeReduction);

    // i and j are set to only retrieve relevant cells
    for (int i = floor (screenPos.x/CELLSIZE); i <= ceil((screenPos.x+width)/CELLSIZE); i++) {
      pushMatrix();
      translate(i*CELLSIZE, 0);
      for (int j = floor (screenPos.y/CELLSIZE); j <= ceil((screenPos.y+height)/CELLSIZE); j++) {
        pushMatrix();
        translate(0, j*CELLSIZE);
        getCell(i, j).render();
        popMatrix();
      }
      popMatrix();
    }
    noStroke();
    if (screenPos.x > 0 && screenPos.x < 27*400.0f/7+width && screenPos.y > 0 && screenPos.y < 400+height) {
      fill(0, 255, 255);
      redWing(width, height, 400);
    }
    if (screenPos.x > FIELDX*CELLSIZE/2 && screenPos.x < 27*400.0f/7+width+FIELDX*CELLSIZE/2 && screenPos.y > 0 && screenPos.y < 400+height) {
      fill(128, 255, 255);
      redWing(width+FIELDX*CELLSIZE/2, height, 400);
    }
    // Renders all of the special effects
    for (Particle p : effects)
      p.render();

    for (int i = effects.size ()-1; i >= 0; i--) { // When effects time out, they are removed
      if (effects.get(i).remaining < 0) {
        Cell e = getCell(floor(effects.get(i).xpos/CELLSIZE), floor(effects.get(i).ypos/CELLSIZE));
        println(floor(effects.get(i).xpos/CELLSIZE));
        float magnitude = 32;
        if (effects.get(i) instanceof Smoke) {
          magnitude = 4;
        } else if (effects.get(i) instanceof Spark) {
          magnitude = 4;
        } else if (effects.get(i) instanceof Eclipse) {
          magnitude = 16;
        } else if (effects.get(i) instanceof Explosion) {
          magnitude = 32;
        }
        e.col = color(hue(e.col), saturation(e.col) + min(255-saturation(e.col), PApplet.parseInt(random(magnitude, magnitude*1.5f))), brightness(e.col));
        effects.remove(i);
      }
    }

    for (Controller c : actors)
      c.render(); // renders redWing

    popMatrix();

    noStroke();
    fill(bleed);
    rect(0, 0, width, height);

    fps();
  }

  // Gets a cell with a specific index
  // Also checks boundaries
  public Cell getCell(int x, int y) {
    x %= FIELDX;
    y %= FIELDY;
    if (x < 0)
      x += FIELDX;
    if (y < 0)
      y += FIELDY;
    return cells[x][y];
  }

  // Drawrs a minimap in the bottom left corner
  public void minimap() {
    noFill();
    strokeWeight(2);
    pushMatrix();
    translate(64, height-64-FIELDY);

    stroke(160, 255, 255);
    // This math was annoying.
    // I don't feel like explaining it right now.
    // If you really care, post something on the repo
    float tempx1 = width/CELLSIZE;
    float tempy1 = height/CELLSIZE;
    float tempx2 = screenPos.x/CELLSIZE;
    float tempy2 = screenPos.y/CELLSIZE;
    rect(max(0, tempx2), max(tempy2, 0), min(min(tempx1, tempx1+tempx2), FIELDX-tempx2), min(tempy1, FIELDY-tempy2));
    if (tempx2 < 0)
      rect(tempx2+FIELDX, max(tempy2, 0), -tempx2, min(tempy1, FIELDY-tempy2));
    if (tempx2 > FIELDX-tempx1)
      rect(0, max(tempy2, 0), tempx1+tempx2-FIELDX, min(tempy1, FIELDY-tempy2));

    stroke(0);
    rect(0, 0, FIELDX, FIELDY);
    popMatrix();
  }

  // Displays the active framerate
  public void fps() {
    fill(75, 255, 64);
    pushMatrix();
    translate(width-128, height-16);
    textSize(12);
    text("FPS: "+PApplet.parseInt(frameRate*100)/100.0f, 0, 0);

    translate(-80, -128);
    textSize(18);
    text("Instructions:", 0, 0);
    text("'Z' : Fire", 0, 24);
    text("Up : Accelerate", 0, 48);
    text("Left/Right : Turn", 0, 72);
    text("'R' : Restart", 0, 96);
    popMatrix();
  }

  public ArrayList<Controller> collide(Controller obj) {
    ArrayList<Controller> ret = new ArrayList();
    for (Cell c : obj.location) {
      for (Controller n : c.occupants) {
        if (!ret.contains(n)) {
          ret.add(n);
        }
      }
    }
    ret.remove(obj);
    return ret;
  }
}

class Cell {
  int xi, yi; // Index of Cell in the World.cells array
  int col;
  ArrayList<Controller> occupants;

  Cell(int x, int y) {
    xi = x;
    yi = y;
    col = color(random(1*y, 16+1*y)%255, 160+96*sin(2*PI*x/FIELDX), random(208, 224));
    occupants = new ArrayList();
  }

  public void render() {
    noStroke();
    if (world.showHitboxes)
      if (occupants.size() != 0) {
        strokeWeight(2);
        stroke(75, 255, 255);
      }
    fill(col);
    rect(0, 0, CELLSIZE+1, CELLSIZE+1);
  }
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--stop-color=#cccccc", "RedWing_Freeflight" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
