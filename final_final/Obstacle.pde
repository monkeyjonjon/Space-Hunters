public class Obstacle {
  boolean diceRolled = false;
  int diceRoll;
  float moveSpeed;
  float x, y;
  float speed = 1.3;
  int oWidth, oHeight;
  public Obstacle(float startX, float startY, int Width, int Height) {
    x = startX;
    y = startY;
    oWidth = Width;
    oHeight = Height;
  }
  public void display(PApplet parent) {
    parent.fill (255, 0, 0);
    parent.rect(x, y, oWidth, oHeight);
    x -= speed * speedBonus;
  }
  public void move() {
    if (!diceRolled) {
      diceRoll = int(random(0, 2));
      moveSpeed = random(0, 1.5);
      speed += random(0, 1);
      diceRolled = true;
    }
    if (diceRoll == 0) {
      y += moveSpeed;
    } else {
      y -= moveSpeed;
    }
  }
  public void reset() {
    speed = random(1.3, 2.1);
    x = width + random(200, 1000);
    y = random(100, height - 100);
  }
}
