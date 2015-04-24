// Contoller superclass refers to input method for manipulating the movement of vehicles
abstract class Controller {
  Object vehicle;
  ArrayList<Cell> location; // List of cells occupied by the vehicle
  int checkx, checky; // Number of cells to check in each direction for collision

  float life; // Life or hitpoints remaining of the object
  float maxLife;

  Controller origin; // The controller that spawned this controller (Not always required)


  // Constructor
  Controller() {
  }

  // Updates the cell occupants and the plane location
  void update() {
    // Removes contoller from previously occupied cells
    for (Cell c : location)
      c.occupants.remove(this);
    // Clears occupied cells
    location.clear();
    // Adds cells in the x and y direction from the vehicle position to its array of occupied cells
    // Also adds this controller to the list of occupants for each cell
    for (int i = floor (vehicle.pos.x/CELLSIZE)-checkx; i <= floor(vehicle.pos.x/CELLSIZE)+checkx; i++)
      for (int j = floor (vehicle.pos.y/CELLSIZE)-checky; j <= floor(vehicle.pos.y/CELLSIZE)+checky; j++) {
        Cell tempc = world.getCell(i, j);
        location.add(tempc);
        tempc.occupants.add(this);
      }
  }

  void tick() {
  }

  // Draws the object
  void render() {
  }

  // Resets the hitbox
  void recheck() {
  }

  void collide(Controller c) {
  }
}

