// Saves precious memories
void screenShot() {
  save("screenshots/screenshot-"+day()+month()+year()+"-"+hour()+minute()+second()+".png");
  println("Screenshot saved: "+"screenshots/screenshot-"+day()+month()+year()+"-"+hour()+minute()+second()+".png");
}
