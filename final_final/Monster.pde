public class Monster {
  float x, y;
  float speed = 1.5;
  int lastMoveTime = 0;
  int diceRoll, diceRoll2;
  public Monster(float startX, float startY) {
    x = startX;
    y = startY;
  }
  public void display(PApplet parent) {
    parent.image(monsterGif, x, y, 150, 150);
    x -= speed * speedBonus;
  }
  void move() {
    if (millis() - lastMoveTime >= 3500) {
      diceRoll = int(random(1, 2055));
      if (diceRoll <= 1) {
        diceRoll = 0;
        lastMoveTime = millis();
        if (y + 100 >= height) {
          float destination = y;
          destination -= 180;
          while (y > destination) {
            y -= 0.05;
          }
        } else if (y - 100 <= 0) {
          float destination = y;
          destination += 180;
          while (y < destination) {
            y += 0.05;
          }
        } else {
          diceRoll2 = int(random(1, 3));
          if (diceRoll2 == 1) {
            float destination = y;
            destination += 180;
            while (y < destination) {
              y += 0.05;
            }
            diceRoll2 = 0;
          } else {
            float destination =y;
            destination -= 180;
            while (y > destination) {
              y -= 0.05;
            }
          }
        }
      }
    }
  }
  public void reset() {
    x = width + random(100, 700);
    y = random(100, height - 100);
    speed = random(1.5, 2.2);
  }
}
