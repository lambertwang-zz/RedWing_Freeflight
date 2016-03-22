
/* RedWing */
/**
 * Coded by Lambert Wang
 * github.com/magellantoo
 */


/**
 * RedWing is a colorful 2d side-scrolling flying adventure.
 *
 * Heavily inspired by the game Luftrausers.
 */

final String VERSION = "POWER PANEL";

// Game uses 'screens' to change between states
int screen;
World world;  
// 0 = playing the game
// 1 = main menu

boolean paused = false;

// Input method for players to control the game
Input keyboard;
Input player;

void setup() {
  // Drawing parameters
  colorMode(HSB);
  // smooth();
  
  // Optimized for 60 fps
  frameRate(60);

  // Fixedsys in sizes 12, 24, 36, and 48
  setupFont();

  noCursor();

  // Resolution of the mqp display
  size(384, 192);
  // Initialize game
  keyboard = new Input();
  player = keyboard;
  world = new World();

  // Default screen is menu
  world.menuMain();
  screen = 1;
}

void draw() {
  // Determines which screen to show
  switch(screen){
    case 0: 
      if(paused) {
        world.justRender();
        pauseText();
      } else {
        world.render();

      }
      break;
    case 1:
      world.menuMainRender();
      break;
  }
}

public void pause() { // Toggles paused and unpaused states
  if (paused) {
    paused = false;
  } else {
    paused = true;
    pauseText();
  }
}

public void pauseText() {
    noStroke();
    fill(128, 255, 255);
    redWing(width/4, height/8, min(width*7/(2*26.5), height/4+32));
    
    textFont(f24);
    fill(0);
    if(player == keyboard) {
      text("Menu unpause", width/2-108, height/2+32);
      text("Back to quit", width/2-108, height/2+64);
    }
}

