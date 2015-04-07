final int FIELDX = 768; // Number of cells in the x and y directions of the field
final int FIELDY = 256;
final int CELLSIZE = 16; // Pixel size of each cell

final int SCREENFOLLOW = 8; // Amount to shift the screen by to follow RedWing
final int MAXEFFECTSIZE = 192;

class World extends HasButtons{
  Cell[][] cells;
  PVector screenPos; // Location of the screen
  Object redWing; // The star of the show
  ArrayList<Controller> actors; // List of redWing. Literally contains nothing except redWing for now
  ArrayList<Controller> addition; // list of objects to be added in the next frame
  ArrayList<Controller> removal; // List of objects to be removed from actors this tick

  int enemies;
  int difficulty;

  int x = FIELDX*CELLSIZE;
  int y = FIELDY*CELLSIZE;
  int hx = x/2;
  int hy =  y/2;

  ArrayList<Particle> effects;
  PVector shake;
  boolean xsplit, ysplit;

  color bleed;

  boolean showHitboxes;


  World() {
    resetWorld();
    showHitboxes = false;
  }

  void resetWorld(){
    cells = new Cell[FIELDX][FIELDY]; // Initiliazes cells
    for (int i = 0; i < FIELDX; i++)
      for (int j = 0; j < FIELDY; j++)
        cells[i][j] = new Cell(i, j);

    screenPos = new PVector(0, 0);
    actors = new ArrayList();
    addition = new ArrayList();
    removal = new ArrayList();

    effects = new ArrayList();
    for(int i = 0; i < 64; i++)
      effects.add(new Cloud(random(x), random(y), random(4, 10), random(120, 180)));

    shake = new PVector(0, 0);

    bleed = color(160, 255, 255, 0);

  }

  ArrayList<Button> buttons;
  SideBar sidebar;

  void menuMain() {
    actors = new ArrayList();
    addition = new ArrayList();
    removal = new ArrayList();

    sidebar = new SideBar(320, 32, 0);

    buttons = new ArrayList(); // Adding buttons
    buttons.add(new Button(-320, 0, 256, color(0, 192, 255), "Play!", 0));
    buttons.add(new Button(-320, 96, 256, color(0, 192, 255), "Stats", 11));
    buttons.add(new Button(64, 0, 256, color(0, 192, 255), "Settings", 2));
    buttons.add(new Button(64, 96, 256, color(0, 192, 255), "Quit", 3));
    target = null;
  }

  void beginGame(int tdiff){
    buttons = new ArrayList();
    sidebar = null;

    actors = new ArrayList();
    addition = new ArrayList();
    removal = new ArrayList();

    redWing = new Plane(0, 0, floor(random(1, NUMGUN+1)), floor(random(1, NUMBODY+1)), floor(random(1, NUMENG+1)));
    
    actors.add(new Player(redWing));

    enemies = 0;
    difficulty = tdiff;
    actors.add(new Computer(new Plane(random(x), random(y), floor(random(1, NUMGUN+1)), floor(random(1, NUMBODY+1)), floor(random(1, NUMENG+1)))));
    enemies++;

    shake = new PVector(0, 0);

    bleed = color(160, 255, 255, 0);

  }

  void menuMainRender() {
    background(0);
    screenPos.x -= 4;
    screenPos.y -= 3;


    pushMatrix();
    translate(-screenPos.x, -screenPos.y);
    shake.mult(shakeReduction);

    // i and j are set to only retrieve relevant cells
    for (int i = floor (screenPos.x/CELLSIZE)-1; i <= ceil((screenPos.x+width)/CELLSIZE); i++) {
      pushMatrix();
      translate((i)*CELLSIZE, 0);
      for (int j = floor (screenPos.y/CELLSIZE)-1; j <= ceil((screenPos.y+height)/CELLSIZE); j++) {
        pushMatrix();
        translate(0, (j)*CELLSIZE);
        getCell(i, j).render();
        popMatrix();
      }
      popMatrix();
    }

    translate(screenPos.x, screenPos.y);
    
    // Renders the logo
    noStroke();
    fill(0, 255, 255);
    redWing(width/4, height/8, min(width*7/(2*26.5), height/4+32));
    textFont(f24);
    text(VERSION, width/4, height/8+32+min(width*7/(2*26.5), height/4+32));
    
    translate(-screenPos.x, -screenPos.y);
    
    xsplit = false;
    ysplit = false;
    if (world.screenPos.x < MAXEFFECTSIZE || world.screenPos.x+width > x)
      xsplit = true;
    if(world.screenPos.y < MAXEFFECTSIZE || world.screenPos.y+height > y)
      ysplit = true;

    // Renders all of the special effects
    for (Particle p : effects)
      p.render(xsplit, ysplit);

    for (int i = effects.size ()-1; i >= 0; i--) { // When effects time out, they are removed
      if (effects.get(i).remaining < 0) {
        Cell e = getCell(floor(effects.get(i).xpos/CELLSIZE), floor(effects.get(i).ypos/CELLSIZE));
        float magnitude = 32;
        if (effects.get(i) instanceof Smoke) {
          magnitude = 4;
        } else if (effects.get(i) instanceof Spark) {
          magnitude = 4;
        } else if (effects.get(i) instanceof Eclipse) {
          magnitude = 32;
        }
        e.col = color(hue(e.col), saturation(e.col) + min(255-saturation(e.col), int(random(magnitude, magnitude*1.2))), brightness(e.col));
        effects.remove(i);
      }
    }

    popMatrix();

    sidebar.render();

    for (Button b : buttons)
      b.render(this);

    fps();
  }

  void render() {
    background(0);
    for (Controller c : removal) {
      actors.remove(c);
      for (Cell l : c.location) {
        l.occupants.remove(c);
      }
    }
    removal.clear();

    for (Controller c : addition)
      actors.add(0, c);

    addition.clear();

    for (Controller c : actors)
      c.tick(); // Magic happens

    PVector target = new PVector(); // Offset vector based off of redWing's position and velocity for the screen position
    target.set((SCREENFOLLOW+1)*redWing.pos.x - width/2 - SCREENFOLLOW*redWing.last.x, (SCREENFOLLOW+1)*redWing.pos.y - height/2 - SCREENFOLLOW*redWing.last.y);

    if (screenPos.x - redWing.pos.x > hx) {
      screenPos.x -= x;
    } else if (screenPos.x - redWing.pos.x < -hx) {
      screenPos.x += x;
    }

    if (screenPos.y - redWing.pos.y > hy) {
      screenPos.y -= y;
    } else if (screenPos.y - redWing.pos.y < -hy) {
      screenPos.y += y;
    }

    screenPos.x -= (screenPos.x-target.x)/16;
    screenPos.y -= (screenPos.y-target.y)/16;


    pushMatrix();
    translate(-screenPos.x, -screenPos.y);
    translate(shake.x, shake.y);
    shake.mult(shakeReduction);

    // i and j are set to only retrieve relevant cells
    for (int i = floor (screenPos.x/CELLSIZE)-1; i <= ceil((screenPos.x+width)/CELLSIZE); i++) {
      pushMatrix();
      translate((i)*CELLSIZE, 0);
      for (int j = floor (screenPos.y/CELLSIZE)-1; j <= ceil((screenPos.y+height)/CELLSIZE); j++) {
        pushMatrix();
        translate(0, (j)*CELLSIZE);
        getCell(i, j).render();
        popMatrix();
      }
      popMatrix();
    }
    
    xsplit = false;
    ysplit = false;
    if (world.screenPos.x < MAXEFFECTSIZE || world.screenPos.x+width > x)
      xsplit = true;
    if(world.screenPos.y < MAXEFFECTSIZE || world.screenPos.y+height > y)
      ysplit = true;

    // Renders all of the special effects
    for (Particle p : effects)
      p.render(xsplit, ysplit);

    for (int i = effects.size ()-1; i >= 0; i--) { // When effects time out, they are removed
      if (effects.get(i).remaining < 0) {
        Cell e = getCell(floor(effects.get(i).xpos/CELLSIZE), floor(effects.get(i).ypos/CELLSIZE));
        float magnitude = 32;
        if (effects.get(i) instanceof Smoke) {
          magnitude = 4;
        } else if (effects.get(i) instanceof Spark) {
          magnitude = 4;
        } else if (effects.get(i) instanceof Eclipse) {
          magnitude = 32;
        }
        e.col = color(hue(e.col), saturation(e.col) + min(255-saturation(e.col), int(random(magnitude, magnitude*1.2))), brightness(e.col));
        effects.remove(i);
      }
    }

    for (Controller c : actors)
      c.render(); // renders redWing

    popMatrix();

    noStroke();
    fill(bleed);
    rect(0, 0, width, height);

    fps();

    //minimap();
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

  // Drawrs a minimap in the bottom left corner
  void minimap() {
    noFill();
    strokeWeight(2);
    pushMatrix();
    translate(64, height-64-FIELDY);

    stroke(160, 255, 255);
    // This math was annoying.
    // I don't feel like explaining it right now.
    // If you really care, post something on the repo
    float tempx1 = width/CELLSIZE;
    float tempy1 = height/CELLSIZE;
    float tempx2 = screenPos.x/CELLSIZE;
    float tempy2 = screenPos.y/CELLSIZE;
    rect(max(0, tempx2), max(tempy2, 0), min(min(tempx1, tempx1+tempx2), FIELDX-tempx2), min(tempy1, FIELDY-tempy2));
    if (tempx2 < 0)
      rect(tempx2+FIELDX, max(tempy2, 0), -tempx2, min(tempy1, FIELDY-tempy2));
    if (tempx2 > FIELDX-tempx1)
      rect(0, max(tempy2, 0), tempx1+tempx2-FIELDX, min(tempy1, FIELDY-tempy2));

    stroke(0);
    rect(0, 0, FIELDX, FIELDY);
    popMatrix();
  }

  // Displays the active framerate
  void fps() {
    noSmooth();
    fill(75, 255, 64);
    pushMatrix();
    translate(width-160, height-16);
    textFont(f12);
    text("FPS: "+int(frameRate*100)/100.0, 0, 0);
    //text("redwing.dir: "+redWing.dir, -128, -12);
    //text("Screenpos X: "+(int)screenPos.x + ", Y: " +(int)screenPos.y, -128, -12);
    //text("Screen Edge X: "+xsplit + ", Y: " +ysplit, -128, -24);
    
    popMatrix();
    smooth();
  }

  ArrayList<Controller> collide(Controller obj) {
    ArrayList<Controller> ret = new ArrayList();
    for (Cell c : obj.location) {
      for (Controller n : c.occupants) {
        if (!ret.contains(n)) {
          ret.add(n);
        }
      }
    }
    ret.remove(obj);
    return ret;
  }
};

class Cell {
  int xi, yi; // Index of Cell in the World.cells array
  color col;
  ArrayList<Controller> occupants;

  Cell(int x, int y) {
    xi = x;
    yi = y;
    col = color(random(1*y, 16+1*y)%255, 64+64*sin(2*PI*x/FIELDX), random(208, 224));
    occupants = new ArrayList();
  }

  void render() {
    noStroke();
    if (world.showHitboxes)
      if (occupants.size() != 0) {
        strokeWeight(2);
        stroke(75, 255, 255);
      }
    fill(col);
    rect(0, 0, CELLSIZE+1, CELLSIZE+1);
  }
};

