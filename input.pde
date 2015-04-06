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
    world = new World();
  }
}


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

void mouseReleased(){
  if(screen == 1)
    if(menu.target != null)
      menu.target.click();
}