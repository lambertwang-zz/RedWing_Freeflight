// Stored values of whether or not keys are held down
boolean upkey = false;
boolean dnkey = false;
boolean lfkey = false;
boolean rtkey = false;
boolean fkey = false;

void keyPressed() {
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
      rtKey = false;
      break;
    case RIGHT: 
      rtkey = true;
      lfKey = false;
      break;
    } else if (key == '1') { // When 1 is pressed, changes redWing to a regular plane
    Vehicle tempv = new Plane(world.redWing.pos.x, world.redWing.pos.y);
    tempv.last = world.redWing.last; // I should really be using a copyFrom method here
    tempv.dir = world.redWing.dir;
    tempv.roll = world.redWing.roll;
    world.redWing = tempv;
    world.actors = new ArrayList();
    world.actors.add(new Player(world.redWing));
  } else if (key == '2') { // Changes redWing to a jet
    Vehicle tempv = new Jet(world.redWing.pos.x, world.redWing.pos.y);
    tempv.last = world.redWing.last;
    tempv.dir = world.redWing.dir;
    tempv.roll = world.redWing.roll;
    world.redWing = tempv;
    world.actors = new ArrayList();
    world.actors.add(new Player(world.redWing));
  } else if (key == 'o' || key == 'O') {
    screenShot();
  }
}

void keyReleased() {
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
    }
}

