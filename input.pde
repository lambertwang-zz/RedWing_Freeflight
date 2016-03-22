// Stored values of whether or not keys are held down
class Input {
  float upkey = 0;
  float dnkey = 0;
  float dirkey = 0;
  boolean zkey = false;
  boolean xkey = false;

  Input() {
  }

  void reset() {
    upkey = 0;
    dnkey = 0;
    dirkey = 0;
    zkey = false;
    xkey = false;
  }
};

void keyPressed() {
  if(screen == 0){
    if (key == CODED) {// Arrow keys are referred to by a keyCode enum
      switch(keyCode) {
      case UP:
        keyboard.upkey = 1;
        break;
      case DOWN:
        keyboard.dnkey = 1;
        break;
      case LEFT: // To prevent sticky movement, left and write override eachother
        keyboard.dirkey = -1;
        break;
      case RIGHT: 
        keyboard.dirkey = 1;
        break;
      } 
    } else if (key == 't' || key == 'T') {
      keyboard.upkey = 1;
    } else if (key == 'f' || key == 'F') {
      keyboard.dirkey = -1;
    } else if (key == 'h' || key == 'H') {
      keyboard.dirkey = 1;
    } else if (key == 'b' || key == 'B') {
      keyboard.dnkey = 1;
    } else if (key == 'c' || key == 'C') {
      keyboard.zkey = true;
    } else if (key == 'z' || key == 'Z') {
      keyboard.xkey = true;
    } else if (key == 'o' || key == 'O') {
      screenShot();
    } else if (key == 'q' || key == 'Q') {
      world.beginGame(2);
      if(paused) {
        world.menuMain();
        screen = 1;
        pause();
      }
    } else if (key == 'e' || key == 'E') {
      pause();
    }
  } else { // Not in game (menu screen)
    if (key == 'o' || key == 'O') {
      screenShot();
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    switch(keyCode) {
    case UP:
      keyboard.upkey = 0;
      break;
    case DOWN:
      keyboard.dnkey = 0;
      break;
    case LEFT:
      if (keyboard.dirkey == -1)
        keyboard.dirkey = 0;
      break;
    case RIGHT:
      if (keyboard.dirkey == 1)
        keyboard.dirkey = 0;
      break;
    } 
  } else if (key == 't' || key == 'T') {
    keyboard.upkey = 0;
  } else if (key == 'f' || key == 'F') {
    keyboard.dirkey = 0;
  } else if (key == 'h' || key == 'H') {
    keyboard.dirkey = 0;
  } else if (key == 'b' || key == 'B') {
    keyboard.dnkey = 0;
  } else if (key == 'c' || key == 'C') {
        keyboard.zkey = false;
  } else if (key == 'z' || key == 'Z') {
      keyboard.xkey = false;
  }
  if (screen != 0) {
    if (key == 'z' || key == 'Z') {
      world.beginGame(2);
      screen = 0;
    } else if (key == 'c' || key == 'C') {
      exit();
    }
  }
}

