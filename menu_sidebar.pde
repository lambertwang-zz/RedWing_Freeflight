class SideBar {
  float pos;
  float target;
  float neutral; // Position when not being hovered
  int side;
  // -1 = left
  // 1 = right
  int type;
  float speed;

  boolean opened;

  SideBar(float ttar, float tn, int tt) {
    pos = tn;
    target = ttar;
    neutral = tn;
    side = int(signum(target-neutral));
    type = tt;
    speed = (target-neutral)/20;

    opened = false;
  }

  void render() {
    if (world.mx*side > (width-pos)*side && (width-pos)*side > (width-target)*side){
      pos += speed;
      opened = true;
    }
    else if ((width-pos)*side < (width-neutral)*side && world.mx*side < (width-pos)*side){
      pos -= speed;
    }

    switch(type) {
    case 0:
      instructions(width-pos, opened);
      break;
    }
  }
};

void instructions(float x, boolean opened) {
  fill(255, opened ? 64 : (frameCount%60 > 30 ? 64 : 192));
  strokeWeight(3);
  stroke(0, 255, 192);
  rect(x, -5, width+5, height+10);
  
  pushMatrix();
  translate(x+28, 500);
  rotate(-PI/2);
  textFont(f24);
  fill(0);
  text("HOVER HERE FOR INSTRUCTIONS", 0, 0);
  popMatrix();

  pushMatrix();
  translate(x+36, 0);

  if(player == keyboard){
    text("Up Arrow:",12, 28);
    text("Accelerate", 24, 56);
    text("Left/Right:", 12, 92);
    text("Turn Plane", 24, 120);
    text("Z Key:", 12, 156);
    text("Shoot Weapon", 24, 184);
    text("X Key:", 12, 220);
    text("Special Move", 24, 248);
    text("P Key:", 12, 284);
    text("Pause",   24, 312);
    text("R Key:", 12, 348);
    text("Restart",   24, 376);
  } 

  translate(0, 24);
  textFont(f12);
  text("Paint the world!", 12, 398);
  text("Thanks for playing!", 12, 412);
  text("Made by: ", 12, 426);
  text("Lambert Wang", 24, 440);
  text("github.com/magellantoo", 24, 454);
  popMatrix();
}

