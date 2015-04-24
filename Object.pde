// Superclass Object is a body which exist in the world. 
// They must exist with a controller
abstract class Object {

  PVector pos; // Current position and previous frame position
  PVector last; // Last is used for verlet integration. See wikipedia for more information
  // Terminal velocities in the x direction based off of speed and in the y direction based off of gravity
  PVector terminal = new PVector(100, 100);
  float gravity = GRAVITY;

  // Radii
  float sizex; // Tail to nose /2
  float sizey; // Wingspan /2
  float sizez; // Bottom to top
  float dir; // Direction plane is facing in radians
  float roll; // The roll of the plane in radians (aka rotation about the local x axis)

  Controller controller; // Controller related to the object

  color col; // Color of the object

  // Constructor
  Object() {
  }

  void tick() {
    // Ensures dir is always between 0 and 2*PI
    if (dir < 0) 
      dir += 2*PI; 
    dir %= 2*PI;
    // Same for roll
    if (roll < 0) 
      roll += 2*PI; 
    roll %= 2*PI;

    // Makes the roll level out
    if (dir < PI/2 || dir > 3*PI/2) { // Checks if vehicle is facing right
      if (roll < PI) // If nose is pitched up, roll will be between 0 and PI
          roll *= 0.98; // In this case, roll approaches 0
      else // If nose is pitched down, roll will be between PI and 2*PI
      roll = (roll - 2*PI)*.98; // Otherwise, roll approaches 2*PI
    } else { // If plane is facing left
      roll = PI + (roll - PI)*.98; // Roll will approach PI
    }

    if (pos.y < 0) { // Allows infinite translation from ceiling to floor and side to side
      pos.y += FIELDY*CELLSIZE; // IE you can fly off one side of the screen and re-appear on the other
      last.y += FIELDY*CELLSIZE; // There is no visual feedback when this happens due to the screen scrolling and rendering with the plane
    }
    if (pos.y >= FIELDY*CELLSIZE) {
      pos.y -= FIELDY*CELLSIZE;
      last.y -= FIELDY*CELLSIZE;
    }
    if (pos.x < 0) {
      pos.x += FIELDX*CELLSIZE;
      last.x += FIELDX*CELLSIZE;
    }
    if (pos.x > FIELDX*CELLSIZE) {
      pos.x -= FIELDX*CELLSIZE;
      last.x -= FIELDX*CELLSIZE;
    }

    // Gravity
    last.add(0, -gravity*(1-abs(pos.x - last.x)/terminal.x), 0); // As the x velocity increases, the plane generates lift, and gravity has less of an effect

    // Simple verlet integration for movement
    // Velocity is calculated from the delta of the last position and current position. 
    PVector temp = new PVector(pos.x, pos.y);
    pos.add(FRICTION*(pos.x - last.x), FRICTION*(pos.y - last.y), 0);
    last.set(temp.x, temp.y);
  }

  void render() {
  }
}

