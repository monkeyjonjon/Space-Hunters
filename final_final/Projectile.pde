class Projectile {
  PImage projectile1, projectile2, projectile3, projectile4;
  PImage pEffectToShow;
  PImage[] projectileEffects = new PImage[4];
  int pEffectFrameDuration = 150;
  int pEffectLastFrameTime = 0;
  int pEffectCurrentFrame = 0;
  float pSpeed = 6, currentSpeed;
  int state = 0;
  float x, y;
  PApplet parent;
  public Projectile(float startX, float startY, int speed) {
    x = startX;
    y = startY;
    currentSpeed = speed * speedBonus;
    projectile1 = loadImage("projectile1.png");
    projectile2 = loadImage("projectile2.png");
    projectile3 = loadImage("projectile3.png");
    projectile4 = loadImage("projectile4.png");
    pEffectToShow = projectile1;
    projectileEffects[0] = projectile1;
    projectileEffects[1] = projectile2;
    projectileEffects[2] = projectile3;
    projectileEffects[3] = projectile4;
  }
  public void display(PApplet parent) {
    if (parent.millis() - pEffectLastFrameTime >= pEffectFrameDuration) {
      pEffectLastFrameTime = parent.millis();
      pEffectCurrentFrame += 1;
      if (pEffectCurrentFrame > 3) {
        pEffectCurrentFrame = 0;
      }
      if (pEffectCurrentFrame != 4) {
        pEffectToShow = projectileEffects[pEffectCurrentFrame];
      }
    }
    parent.image(pEffectToShow, x - 20, y - 25, 100, 100);
    x += currentSpeed;
  }
}
