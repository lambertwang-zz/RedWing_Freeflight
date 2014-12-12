// Stored values of whether or not keys are held down
class Input {
  boolean upkey = false;
  boolean dnkey = false;
  boolean lfkey = false;
  boolean rtkey = false;
  boolean zkey = false;
  boolean xkey = false;

  Input() {
  }

  void reset() {
    upkey = false;
    dnkey = false;
    lfkey = false;
    rtkey = false;
    zkey = false;
    xkey = false;
  }
}


void keyPressed() {
  if (key == CODED) // Arrow keys are referred to by a keyCode enum
    switch(keyCode) {
    case UP:
      keyboard.upkey = true;
      break;
    case DOWN:
      keyboard.dnkey = true;
      break;
    case LEFT: // To prevent sticky movement, left and write override eachother
      keyboard.lfkey = true;
      keyboard.rtkey = false;
      break;
    case RIGHT: 
      keyboard.rtkey = true;
      keyboard.lfkey = false;
      break;
    } else if (key == 'z' || key == 'Z') {
    keyboard.zkey = true;
  } else if (key == 'x' || key == 'X') {
    keyboard.xkey = true;
  } else if (key == 'o' || key == 'O') {
    screenShot();
  } else if (key == 'r' || key == 'R') {
    world = new World();
  }
}


void keyReleased() {
  if (key == CODED)
    switch(keyCode) {
    case UP:
      keyboard.upkey = false;
      break;
    case DOWN:
      keyboard.dnkey = false;
      break;
    case LEFT:
      keyboard.lfkey = false;
      break;
    case RIGHT:
      keyboard.rtkey = false;
      break;
    } else if (key == 'z' || key == 'Z') {
    keyboard.zkey = false;
  } else if (key == 'x' || key == 'X') {
    keyboard.xkey = false;
  }
}

