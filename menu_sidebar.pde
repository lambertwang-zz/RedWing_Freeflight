class SideBar {
  SideBar() {
  }

  void render() {
    instructions();
  }
};

void instructions() {
  noStroke();
  fill(255, 64);
  rect(0, 0, 84, height);
  rect(width-84, 0, width, height);

  fill(137, 255, 27);

  pushMatrix();
  translate(0, 8);
  textFont(f6);
  text("Up:",6, 6);
  text("Accel", 12, 18);
  text("Left/Right:", 6, 30);
  text("Turn", 12, 42);
  text("Square:", 6, 54);
  text("Shoot", 12, 66);
  text("Triangle:", 6, 78);
  text("Special", 12, 90);
  text("Menu:", 6, 102);
  text("Pause",   12, 114);
  text("Back:", 6, 126);
  text("Restart",   12, 138);
  popMatrix();
  text("Triangle to start Square to quit", 80, 186);
  pushMatrix();
  translate(width-84, 8);
  text("Paint the", 6, 6);
  text("world!", 12, 18);
  text("Thanks for", 6, 36); 
  text("playing!", 12, 48);
  text("Made by: ", 6, 66);
  text("Lambert", 12, 78);
  text("Wang", 12, 90);
  popMatrix();
}

