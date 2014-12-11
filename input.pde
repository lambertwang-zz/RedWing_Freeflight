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
    } else if (key == 'f' || key == 'F') {
    fkey = false;
  }
}

