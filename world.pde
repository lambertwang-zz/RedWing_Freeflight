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
  int score;
  int hiscore = 0;

  int x = FIELDX*CELLSIZE;
  int y = FIELDY*CELLSIZE;
  int hx = x/2;
  int hy =  y/2;

  ArrayList<Particle> effects;
  PVector shake;
  boolean xsplit, ysplit;

  color bleed;

  boolean showHitboxes;
  boolean showFps = false;

  float mx, my;
  ICanClick toClick = null;

  String overlayText = null;

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
    for(int i = 0; i < 20*effectsDensity; i++)
      effects.add(new Cloud(random(x), random(y), random(4, 10), random(120, 180)));

    shake = new PVector(0, 0);

    bleed = color(160, 255, 255, 0);

    buttons = new ArrayList();
    target = null;
    overlayText = null;
  }

  ArrayList<ICanClick> buttons;
  SideBar sidebar = new SideBar(320, 32, 0);
  PVector menuScroll;

  void menuMain() {
    actors = new ArrayList();
    addition = new ArrayList();
    removal = new ArrayList();


    buttons.clear(); // Adding buttons
    buttons.add(new Button(-320, 0, 256, color(12, 192, 255), "Play!", 0));
    //buttons.add(new Button(-320, 96, 256, color(0, 192, 255), "Stats", 1));
    buttons.add(new Button(64, 0, 256, color(12, 192, 255), "Settings", 2));
    //buttons.add(new Button(64, 96, 256, color(12, 192, 255), "Quit", 3));
    
    screenPos.set(0, 0);
    menuScroll = new PVector(-3, -4);

    overlayText = null;
  }

  void menuSettings() {
    actors = new ArrayList();
    addition = new ArrayList();
    removal = new ArrayList();

    buttons.clear(); // Adding buttons
    buttons.add(new Button(-320, 0, 256, color(32, 192, 255), "Mouse", 5));
    buttons.add(new Button(-320, 96, 256, color(32, 192, 255), "Keyboard", 6));
    buttons.add(new Button(-320, 192, 256, color(32, 192, 255), "Gamepad", 7));
    //buttons.add(new Slider(64, 0, 256, color(32, 192, 255), "Effects", 0));
    buttons.add(new Button(64, 96, 256, color(32, 192, 255), "Main Menu", 4));
    //buttons.add(new Button(64, 192, 256, color(32, 192, 255), "Show FPS", 8));
    
    screenPos.set(x/2, y/2);
    menuScroll = new PVector(4, -3);
    
    overlayText = null;
  }


  void beginGame(int tdiff){
    buttons.clear();

    actors.clear();
    addition.clear();
    removal.clear();

    for (int i = 0; i < FIELDX; i++)
      for (int j = 0; j < FIELDY; j++)
        cells[i][j].occupants.clear();

    redWing = new Plane(random(x), random(y), floor(random(1, NUMGUN+1)), floor(random(1, NUMBODY+1)), floor(random(1, NUMENG+1)));
    
    actors.add(new Player(redWing));

    enemies = 0;
    difficulty = tdiff;
    actors.add(new Computer(new Plane(random(x), random(y), floor(random(1, NUMGUN+1)), floor(random(1, NUMBODY+1)), floor(random(1, NUMENG+1)))));
    //actors.add(new GunshipComp(new Gunship(random(x), random(y), floor(random(1, NUMGUN+1)), floor(random(1, GSNUMBODY+1)), floor(random(1, GSNUMENG+1)))));
    enemies++;
    score = 0;

    shake = new PVector(0, 0);

    bleed = color(160, 255, 255, 0);

    overlayText = null;
  }

  void menuMainRender() {
    background(0);
    screenPos.add(menuScroll);


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
    fill(0, 192+32*sin((frameCount/60.0)%(2*PI)), 255);
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
      p.render(xsplit, ysplit, true);
    
    for (int i = effects.size ()-1; i >= 0; i--) { // When effects time out, they are removed
      if (effects.get(i).remaining < 0) {
        Cell e = getCell(floor(effects.get(i).xpos/CELLSIZE), floor(effects.get(i).ypos/CELLSIZE));
        float magnitude = 32;
        if (effects.get(i) instanceof Smoke) {
          magnitude = 4;
        } else if (effects.get(i) instanceof Spark) {
          magnitude = 4;
        } else if (effects.get(i) instanceof Eclipse) {
          magnitude = 24;
        }
        e.col = color(hue(e.col), saturation(e.col) + min(255-saturation(e.col), int(random(magnitude, magnitude*1.2))), brightness(e.col));
        effects.remove(i);
      }
    }

    popMatrix();

    for (ICanClick b : buttons)
      b.render(this);
    if(sidebar != null)
      sidebar.render();

    if(player == gamepad && gpad != null){
      mx += gpad.getSlider("XPOS").getValue()*12;
      my += gpad.getSlider("YPOS").getValue()*12;
      if (toClick != null){
        toClick.click();
        toClick = null;
      }
    } else {
      if(gpad == null && player == gamepad){
        player = mouse;
        gamepad = null;
      }
      mx = mouseX;
      my = mouseY;
    }
    fill(0, 192, 255);
    stroke(0, 192, 255);
    strokeWeight(3);
    ellipse(mx, my, 4, 4);
    noFill();
    ellipse(mx, my, 24, 24);
    fill(0, 255, 255);
    stroke(0, 255, 255);
    strokeWeight(1);
    ellipse(mx, my, 4, 4);
    noFill();
    ellipse(mx, my, 24, 24);

    fps();
  }

  void render() {
    background(0);
    newWave();

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

    if(gpad == null && player == gamepad){
      player = mouse;
      gamepad = null;
    }
    // Calculate mouse controls
    if(player == mouse){
      my = mouseY+screenPos.y;
      mx = mouseX+screenPos.x;
      float mouseAngle = atan2(my-redWing.pos.y, mx-redWing.pos.x)-redWing.dir;
      if(mouseAngle < -PI)
        mouseAngle += 2*PI;
      mouse.dirkey = max(min(1, mouseAngle), -1);
      float mouseup = dist(mx, my, redWing.pos.x, redWing.pos.y)/(min(height, width)/5);
      mouse.upkey = mouseup > 0.5 ? min(1, mouseup) : 0;
    } if (player == gamepad){
      float gx = gpad.getSlider("XPOS").getValue(), gy = gpad.getSlider("YPOS").getValue();
      float mouseAngle = atan2(gy, gx)-redWing.dir;
      if(mouseAngle < -PI)
        mouseAngle += 2*PI;
      gamepad.upkey = dist(0, 0, gx, gy);
      if(gx != 0 || gy != 0)
        gamepad.dirkey = max(min(1, mouseAngle), -1);
      else
        gamepad.dirkey = 0;
      //gamepad.zkey = gpad.getButton("ABTN").pressed();
      //gamepad.xkey = gpad.getButton("BBTN").pressed();
      gamepad.zkey = gpad.getButton("RTRIG").pressed();
      gamepad.xkey = gpad.getButton("LTRIG").pressed();

      if (gpad.getButton("YBTN").pressed() && gpylast == false){
        pause();
      }
      gpylast = gpad.getButton("YBTN").pressed();
      if (gpad.getButton("XBTN").pressed() && gpxlast == false){
        world.beginGame(2);
        if(paused) {
          pause();
        }
      }
      gpxlast = gpad.getButton("XBTN").pressed();
    }


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


    for (Controller c : actors)
      c.render(); // renders redWing

    // Renders all of the special effects
    for (Particle p : effects)
      p.render(xsplit, ysplit, true);

    for (int i = effects.size ()-1; i >= 0; i--) { // When effects time out, they are removed
      if (effects.get(i).remaining < 0) {
        Cell e = getCell(floor(effects.get(i).xpos/CELLSIZE), floor(effects.get(i).ypos/CELLSIZE));
        if(actors.contains(redWing)){
          float magnitude = 32;
          if (effects.get(i) instanceof Smoke) {
            magnitude = 4;
          } else if (effects.get(i) instanceof Spark) {
            magnitude = 4;
          } else if (effects.get(i) instanceof Eclipse) {
            magnitude = 32;
          }
          e.col = color(hue(e.col), saturation(e.col) + min(255-saturation(e.col), int(random(magnitude, magnitude*1.2))), brightness(e.col));
        }
        effects.remove(i);
      }
    }

    if(player == mouse){
      fill(0, 192, 255);
      stroke(0, 192, 255);
      strokeWeight(3);
      ellipse(mx, my, 4, 4);
      noFill();
      ellipse(mx, my, 24, 24);
      fill(0, 255, 255);
      stroke(0, 255, 255);
      strokeWeight(1);
      ellipse(mx, my, 4, 4);
      noFill();
      ellipse(mx, my, 24, 24);
    }

    popMatrix();

    pushMatrix();
    if(overlayText != null){
      textFont(f36);
      translate(width/2, height/2);
      fill(0, 255, 255);
      noStroke();
      text(overlayText, -14*overlayText.length(), 18);
    }
    popMatrix();


    noStroke();
    fill(bleed);
    rect(0, 0, width, height);

    fps();

    //minimap();
  }

  void justRender(){
    if(player == mouse){
      my = mouseY+screenPos.y;
      mx = mouseX+screenPos.x;
    } else if(player == gamepad && gpad != null){
      if (gpad.getButton("YBTN").pressed() && gpylast == false){
        pause();
      }
      gpylast = gpad.getButton("YBTN").pressed();
      if (gpad.getButton("XBTN").pressed() && gpxlast == false){
        world.beginGame(2);
        if(paused) {
          pause();
        }
      }
      gpxlast = gpad.getButton("XBTN").pressed();
      if (gpad.getButton("BBTN").pressed()){
        if(paused) {
          world.menuMain();
          screen = 1;
          pause();
        }
      }
      gpblast = gpad.getButton("BBTN").pressed();
    }
    
    pushMatrix();
    translate(-screenPos.x, -screenPos.y);
    translate(shake.x, shake.y);

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


    for (Controller c : actors)
      c.render(); // renders redWing

    // Renders all of the special effects
    for (Particle p : effects)
      p.render(xsplit, ysplit, false);

    if(player == mouse){
      fill(0, 192, 255);
      stroke(0, 192, 255);
      strokeWeight(3);
      ellipse(mx, my, 4, 4);
      noFill();
      ellipse(mx, my, 24, 24);
      fill(0, 255, 255);
      stroke(0, 255, 255);
      strokeWeight(1);
      ellipse(mx, my, 4, 4);
      noFill();
      ellipse(mx, my, 24, 24);
    }

    popMatrix();

    pushMatrix();
    if(overlayText != null){
      textFont(f36);
      translate(width/2, height/2);
      fill(0, 255, 255);
      noStroke();
      text(overlayText, -14*overlayText.length(), 18);
    }
    popMatrix();


    noStroke();
    fill(bleed);
    rect(0, 0, width, height);

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

  // Draws a minimap in the bottom left corner
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

    if (tempy2 < 0)
      rect(max(tempx2, 0), tempy2+FIELDY, min(tempx1, FIELDX-tempx2), -tempy2);
    if (tempy2 > FIELDY-tempy1)
      rect(max(tempx2, 0), 0, min(tempx1, FIELDX-tempx2), tempy1+tempy2-FIELDY);


    stroke(0);
    rect(0, 0, FIELDX, FIELDY);
    popMatrix();
  }

  void newWave(){
     if (world.enemies == 0) {
      world.difficulty++;
      for (int i = 0; i < world.difficulty; i++) {
        Object p;
        p = new Plane(random(world.redWing.pos.x+width/2, world.redWing.pos.x-width/2+FIELDX*CELLSIZE), 
        random(world.redWing.pos.y+height/2, world.redWing.pos.y-height/2+FIELDY*CELLSIZE), floor(random(1, NUMGUN+1)), floor(random(1, NUMBODY+1)), floor(random(1, NUMENG+1)));
        world.addition.add(new Computer(p));
        world.enemies++;
      }
    }
  }

  // Displays the active framerate
  void fps() {
    noSmooth();
    fill(75, 255, 64);
    pushMatrix();
    translate(width-160, height-16);
    textFont(f12);
    if(showFps)
      text("FPS: "+int(frameRate*100)/100.0, 0, 0);
    text("SCORE:    "+score, 0, -48);
    text("HI-SCORE: "+hiscore, 0, -24);
    /*if(redWing != null){
      text("redwing.dir: "+redWing.dir, -128, -72);
      text("redwing spd: "+abs(dist(redWing.pos.x, redWing.pos.y, redWing.last.x, redWing.last.y)), -128, -96);
    }*/
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
    col = color(random(1*y, 16+1*y)%255, 96+48*sin(2*PI*x/FIELDX), random(208, 224));
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

