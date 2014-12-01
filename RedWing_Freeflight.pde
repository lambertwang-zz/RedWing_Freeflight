
/* RedWing */
// A 2d side-scrolling flying adventure
// Coded by Lambert Wang
// Controls: Arrow Keys

World world;

void setup() {
  colorMode(HSB);
  smooth();
  frameRate(60);
  //size(640, 360);
  //size(1280, 720);
  size(1440, 800);
  world = new World();
}

void draw() {
  world.render();
}

