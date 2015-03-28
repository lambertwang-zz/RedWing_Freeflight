
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
Input keyboard;

void setup() {
  // Drawing parameters
  colorMode(HSB);
  smooth();
  // Optimized for 60 fps
  frameRate(60);


  textFont(loadFont("Fixed_12.vlw"));

  // 4:3
  //size(800, 600);
  //size(1024, 768);
  //size(1280, 960);

  // 16:9
  //size(800, 450);
  //size(1280, 720);
  //size(1266, 768);
  size(1440, 810);
  if (frame != null) {
    frame.setResizable(true);
  }

  keyboard = new Input();
  world = new World();
}

void draw() {
  world.render();
}

