// Contoller superclass refers to input method for manipulating the movement of vehicles
// Currently, only player control is implemented.
// AI control is planned for use in RedWing, the 2d arcade style aerial combat game
abstract class Controller {

  Vehicle vehicle;
  ArrayList<Cell> location; // List of cells occupied by the vehicle
  int checkx, checky; // Number of cells to check in each direction for collision

  Controller() {
  }

  // Updates the cell occupants and the plane location
  void update() {
    // Clears occupied cells
    location.clear();
    // Removes contoller from previously occupied cells
    for (Cell c : location)
      c.occupants.remove(this);
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

  void render() {
  }

  void recheck() {
  }
}

