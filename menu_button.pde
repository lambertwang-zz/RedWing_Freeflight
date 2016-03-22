// Square buttons for the menu
class Button implements ICanClick{
  float posx, posy, size; // Size is width
  color col; // Color
  String text;
  int button; // The index for what to do when the button is clicked
  boolean hover; // Whether or not the button is hovered over

    Button(float tx, float ty, float ts, color tcol, String tt, int tb) { // Large constructor caller because why not
    posx = tx; 
    posy = ty; 
    size = ts; 
    col = tcol;
    text = tt;
    button = tb;
    hover = false;
  }

  void render(HasButtons screen) {
    pushMatrix();
    translate(width/2+posx, height/2+posy);
    if (world.mx > width/2+posx && world.mx < width/2+posx+size && world.my > height/2+posy && world.my < height/2+posy+64) // Check hover
      hover = true;
    else {
      hover = false;
      if (screen.target == this)
        screen.target = null;
    }

    if (hover){
      screen.target = this;
      if (mousePressed) { 
        fill(255);
      } else {
        fill(255, 128);
      }
    }
    else if(button == 6 && player == keyboard)
      fill(255, 192);
    else if(button == 8 && world.showFps == true)
      fill(255, 192);
    else 
      fill(255, 64); // Transparent

    strokeWeight(3.5);
    stroke(col);
    rect(0, 0, size, 44);

    fill(col);
    textFont(f24);
    text(text, size/2 - text.length()*8.9, 32);

    popMatrix();
  }

  void click() {
    switch(button) {
    case 0: // Begin game
      world.beginGame(2);
      screen = 0;
      break;
    case 3: // exit game
      exit();
      break;
    }
  }
};

abstract class HasButtons{
  ICanClick target;
}

interface ICanClick{
  void click();
  void render(HasButtons screen);
}

