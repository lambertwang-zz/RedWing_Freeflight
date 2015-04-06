class Menu extends HasButtons{
  Cell[][] cells;

  int x = width;
  int y = height;
  int hx = x/2;
  int hy =  y/2;

  ArrayList<Particle> effects;
  boolean xsplit, ysplit;

  SideBar sidebar;

  ArrayList<Button> buttons;
  Button target;

  Menu() {
    cells = new Cell[1+x/CELLSIZE][1+y/CELLSIZE]; // Initiliazes cells
    for (int i = 0; i < 1+x/CELLSIZE; i++)
      for (int j = 0; j < 1+y/CELLSIZE; j++)
        cells[i][j] = new Cell(FIELDX/4, int(.5*FIELDY*(1.3-j/(1.0+y/CELLSIZE))));

    effects = new ArrayList();
    for(int i = 0; i < 8; i++)
      effects.add(new Cloud(random(x), random(y), random(4, 8), random(120, 180)));

    sidebar = new SideBar(width-320, width-32, 0);

    buttons = new ArrayList(); // Adding buttons
    buttons.add(new Button(width/2-320, height/2-32, 256, color(0, 255, 192), "Play!", 0));
    //buttons.add(new Button(width/2-288, height/2, 256, color(75, 255, 192), "Stats", 11));
    //buttons.add(new Button(width/2+32, height/2-64, 256, color(75, 255, 192), "Settings", 2));
    buttons.add(new Button(width/2+64, height/2+64, 256, color(0, 255, 192), "Quit", 3));
    target = null;
  }

  void render() {
    background(0);

    // i and j are set to only retrieve relevant cells
    for (int i = 0; i <= x/CELLSIZE; i++) {
      pushMatrix();
      translate((i)*CELLSIZE, 0);
      for (int j = 0; j <= y/CELLSIZE; j++) {
        pushMatrix();
        translate(0, (j)*CELLSIZE);
        getCell(i, j).render();
        popMatrix();
      }
      popMatrix();
    }
    
    // Renders the logo
    noStroke();
    fill(0, 255, 255);
    redWing(width/4, height/8, width*7/(2*26.5));
    textFont(f24);
    text(VERSION, width/4, height/8+32+width*7/(2*26.5));

    xsplit = false;
    ysplit = false;
    if (world.screenPos.x < MAXEFFECTSIZE || world.screenPos.x+width > x)
      xsplit = true;
    if(world.screenPos.y < MAXEFFECTSIZE || world.screenPos.y+height > y)
      ysplit = true;

    // Renders all of the special effects
    for (Particle p : effects)
      p.render(xsplit, ysplit);

    sidebar.render();

    for (Button b : buttons)
      b.render(this);

    fps();

  }

  // Gets a cell with a specific index
  // Also checks boundaries
  Cell getCell(int x, int y) {
    x %= FIELDX;
    y %= FIELDY;
    if (x < 0)
      x += FIELDX;
    if (y < 0)
      y += FIELDY;
    return cells[x][y];
  }

  // Displays the active framerate
  void fps() {
    noSmooth();
    fill(75, 255, 64);
    pushMatrix();
    translate(width-160, height-16);
    textFont(f12);
    text("FPS: "+int(frameRate*100)/100.0, 0, 0);
    popMatrix();
    smooth();
  }
};

abstract class HasButtons{
  Button target;
}