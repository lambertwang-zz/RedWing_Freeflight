// Currently implements a cell based hitscan system; however, it isn't used because there aren't any other objects to collide with.

final int FIELDX = 768; // Number of cells in the x and y directions of the field
final int FIELDY = 256;
final int CELLSIZE = 16; // Pixel size of each cell
final int SCREENFOLLOW = 8; // Amount to shift the screen by to follow RedWing

class World {
  Cell[][] cells;
  PVector screenPos; // Location of the screen
  Vehicle redWing; // The star of the show
  ArrayList<Controller> actors; // List of redWing. Literally contains nothing except redWing for now

  World() {
    cells = new Cell[FIELDX][FIELDY]; // Initiliazes cells
    for (int i = 0; i < FIELDX; i++)
      for (int j = 0; j < FIELDY; j++)
        cells[i][j] = new Cell(i, j);

    screenPos = new PVector(0, 0);
    redWing = new Plane(0, 0);
    actors = new ArrayList();
    actors.add(new Player(redWing));
  }

  void render() {
    background(0);
    for (Controller c : actors)
      c.tick(); // Magic happens

    PVector target = new PVector(); // Offset vector based off of redWing's position and velocity for the screen position
    target.set((SCREENFOLLOW+1)*redWing.pos.x - width/2 - SCREENFOLLOW*redWing.last.x, (SCREENFOLLOW+1)*redWing.pos.y - height/2 - SCREENFOLLOW*redWing.last.y);
    
    screenPos.x = target.x;
    screenPos.y = target.y;

    pushMatrix();
    translate(-screenPos.x, -screenPos.y);
    
    // i and j are set to only retrieve relevant cells
    for (int i = floor (screenPos.x/CELLSIZE); i <= ceil((screenPos.x+width)/CELLSIZE); i++) {
      pushMatrix();
      translate(i*CELLSIZE, 0);
      for (int j = floor (screenPos.y/CELLSIZE); j <= ceil((screenPos.y+height)/CELLSIZE); j++) {
        pushMatrix();
        translate(0, j*CELLSIZE);
        getCell(i, j).render();
        popMatrix();
      }
      popMatrix();
    }

    for (Controller c : actors)
      c.render(); // renders redWing

    popMatrix();

    //minimap();
    //fps();
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
  void fps(){
    fill(75, 255, 64);
    pushMatrix();
    translate(width-128, height-16);
    text("FPS: "+int(frameRate*100)/100.0, 0, 0);
    popMatrix();
  }
}

class Cell {
  int xi, yi; // Index of Cell in the World.cells array
  color col;
  ArrayList<Controller> occupants;

  Cell(int x, int y) {
    xi = x;
    yi = y;
    col = color(random(1*y, 16+1*y)%255, 176+80*sin(2*PI*x/FIELDX), random(240, 256)%256);
    occupants = new ArrayList();
  }

  void render() {
    noStroke();
    /*if (occupants.size() != 0) {
      strokeWeight(2);
      stroke(75, 255, 255);
    }*/
    fill(col);
    rect(0, 0, CELLSIZE+1, CELLSIZE+1);
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
}

