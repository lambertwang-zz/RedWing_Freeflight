
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

final String VERSION = "Beta 0.2";

// Game uses 'screens' to change between states
int screen;
World world;  // 0 = playing the game
Menu menu;    // 1 = main menu

// Input method for players to control the game
Input keyboard;

void setup() {
  // Drawing parameters
  colorMode(HSB);
  smooth();
  // Optimized for 60 fps
  frameRate(60);

  // Fixedsys in sizes 12, 24, 36, and 48
  setupFont();

  // 4:3
  //size(800, 600);
  //size(1024, 768);
  //size(1280, 960);

  // 16:9
  //size(800, 450);
  //size(1280, 720);
  size(1366, 768);
  //size(1440, 810);

  // Active resizing works fine during gameplay
  // Need to re-initialize menus when screen is resized on a menu screen
  if (frame != null) {
    frame.setResizable(true);
  }

  // Initialize game
  keyboard = new Input();
  menu = new Menu();
  world = new World();

  // Default screen is menu
  screen = 1;
}

void draw() {
  // Determines which screen to show
  switch(screen){
    case 0: 
      world.render();
      break;
    case 1:
      menu.render();
      break;
  }
}