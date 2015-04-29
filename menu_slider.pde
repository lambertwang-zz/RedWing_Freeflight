// Square buttons for the menu
class Slider implements ICanClick{
  float posx, posy, size; // Size is width
  color col; // Color
  String text;
  int slider; // The index for what to do when the button is clicked
  boolean hover; // Whether or not the button is hovered over

  float posm;

  Slider(float tx, float ty, float ts, color tcol, String tt, int tb) { // Large constructor caller because why not
    posx = tx; 
    posy = ty; 
    size = ts; 
    col = tcol;
    text = tt;
    slider = tb;
    hover = false;

    posm = 0;
  }

  void render(HasButtons screen) {
    pushMatrix();
    translate(width/2+posx, height/2+posy);
    if (world.mx > width/2+posx && world.mx < width/2+posx+size && world.my > height/2+posy && world.my < height/2+posy+64) {// Check hover
      hover = true;
      posm = (world.mx-(width/2+posx))/size;
    } else {
      hover = false;
      posm = 0;
      if (screen.target == this)
        screen.target = null;
    }

    if (hover){
      screen.target = this;if (player != gamepad) {
        if (mousePressed) { 
          fill(255);
        } else {
          fill(255, 192);
        }
      } else if(player == gamepad){
        if (gpad.getButton("ABTN").pressed() && gpalast == false) {
          world.toClick = this;
          fill(255);
        } else {
          fill(255, 192);
        }
        gpalast = gpad.getButton("ABTN").pressed();
      } else {
        fill(255, 192);
      }
    } else 
      fill(255, 128); // Transparent

    noStroke();
    switch(slider) {
    case 0: // Begin game
      rect(0, 0, size*((effectsDensity-1)/5), 56);
      break;
    }
    
    noFill();
    strokeWeight(3.5);
    stroke(col);
    rect(0, 0, size, 56);

    fill(col);
    textFont(f36);
    text(text, size/2 - text.length()*13.3, 44);

    popMatrix();
  }

  void click() {
    switch(slider) {
    case 0: // Begin game
      effectsDensity = 1 + 5*posm;
      world.effects = new ArrayList();
      for(int i = 0; i < 20*effectsDensity; i++)
        world.effects.add(new Cloud(random(world.x), random(world.y), random(4, 10), random(120, 180)));
      break;
    }
  }
};
