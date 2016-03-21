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
    if (key == CODED) // Arrow keys are referred to by a keyCode enum
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
      } else if (key == 'z' || key == 'Z') {
      keyboard.zkey = true;
    } else if (key == 'x' || key == 'X') {
      keyboard.xkey = true;
    } else if (key == 'o' || key == 'O') {
      screenShot();
    } else if (key == 'r' || key == 'R') {
      world.beginGame(2);
      if(paused) {
        pause();
      }
    } else if (key == 'p' || key == 'P') {
      pause();
    } else if (key == 'm' || key == 'M') {
      if(paused){
        world.menuMain();
        screen = 1;
        pause();
      }
    }
  } else {
    if (key == 'o' || key == 'O') {
      screenShot();
    } 
  }
}

/**
 * Bug with Linux, holding down a key will cause multiple calls of keyReleased and keyPressed.
 * On windows, keyReleased will only call once, but keyPressed will call multiple times.
 */
/*
long upTimer = 0;
long downTimer = 0;
long leftTimer = 0;
long rightTimer = 0;
long zTimer = 0;
long xTimer = 0;
long repeatThreshold = 80;

void keyReleased() {
  if (key == CODED)
    switch(keyCode) {
    case UP:
      if(System.currentTimeMillis() - upTimer > repeatThreshold){
        keyboard.upkey = 0;
      }
      upTimer = System.currentTimeMillis();
      break;
    case DOWN:
      if(System.currentTimeMillis() - downTimer > repeatThreshold){
        keyboard.dnkey = 0;
      }
      downTimer = System.currentTimeMillis();
      break;
    case LEFT:
      if(System.currentTimeMillis() - leftTimer > repeatThreshold){
        if (keyboard.dirkey == -1)
          keyboard.dirkey = 0;
      }
      leftTimer = System.currentTimeMillis();
      
      break;
    case RIGHT:
      if(System.currentTimeMillis() - rightTimer > repeatThreshold){
        if (keyboard.dirkey == 1)
          keyboard.dirkey = 0;
      }
      rightTimer = System.currentTimeMillis();
      break;
    } else if (key == 'z' || key == 'Z') {
      if(System.currentTimeMillis() - zTimer > repeatThreshold){
        keyboard.zkey = false;
      }
      zTimer = System.currentTimeMillis();    
  } else if (key == 'x' || key == 'X') {
    if(System.currentTimeMillis() - xTimer > repeatThreshold){
      keyboard.xkey = false;
    }
    xTimer = System.currentTimeMillis();
  }
}
*/

void keyReleased() {
  if (key == CODED)
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
    } else if (key == 'z' || key == 'Z') {
        keyboard.zkey = false;
  } else if (key == 'x' || key == 'X') {
      keyboard.xkey = false;
  }
}

