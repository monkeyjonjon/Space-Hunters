class Player {
  int kills = 0;
  float pCD = 500;
  float lastFireTime = - pCD;
  int maxAmmo = 6, ammo;
  boolean isMoving = false;
  boolean keyReleased = false;
  float playerX = 20, playerY;
  int playerHP = 5, earthHP = 8;
  int maxStamina = 250;
  int stamina = maxStamina;
  float playerSpeed = 20;
  int eEffectFrameDuration = 150;
  int eIdleEffectFrameDuration = 200;
  int eEffectLastFrameTime = 0;
  int eEffectCurrentFrame = 0;
  int eIdleEffectCurrentFrame = 0;
  int keyLastReleased = 0;
  int idleTime = 2300;
  PImage playerSprite, weaponSprite, engineSprite;
  PImage engineEffect1, engineEffect2, engineEffect3, engineEffect4;
  PImage engineEffectIdle1, engineEffectIdle2, engineEffectIdle3;
  PImage effectToShow;
  PImage[] engineEffects = new PImage[4];
  PImage[] engineEffectsIdle = new PImage[3];
  PApplet parent;
  Player () {
    ammo = maxAmmo;
    playerY = height/2;
    playerSprite = loadImage("player_full.png");
    engineSprite = loadImage("player_engine.png");
    weaponSprite = loadImage("player_weapon.png");
    engineSprite = loadImage("player_engine.png");
    engineEffect1 = loadImage("engineEffects1.png");
    engineEffect2 = loadImage("engineEffects2.png");
    engineEffect3 = loadImage("engineEffects3.png");
    engineEffect4 = loadImage("engineEffects4.png");
    engineEffectIdle1 = loadImage("engineEffectsIdle1.png");
    engineEffectIdle2 = loadImage("engineEffectsIdle2.png");
    engineEffectIdle3 = loadImage("engineEffectsIdle3.png");
    effectToShow = engineEffectIdle1;
    engineEffects[0] = engineEffect1;
    engineEffects[1] = engineEffect2;
    engineEffects[2] = engineEffect3;
    engineEffects[3] = engineEffect4;
    engineEffectsIdle[0] = engineEffectIdle1;
    engineEffectsIdle[1] = engineEffectIdle2;
    engineEffectsIdle[2] = engineEffectIdle3;
  }
  void display (PApplet parent) {

    if (isMoving) {
      if (parent.millis() - eEffectLastFrameTime >= eEffectFrameDuration) {
        eEffectLastFrameTime = parent.millis();
        eEffectCurrentFrame += 1;
        if (eEffectCurrentFrame > 3) {
          eEffectCurrentFrame = 0;
        }
        effectToShow = engineEffects[eEffectCurrentFrame];
      }
    } else {
      if (parent.millis() - eEffectLastFrameTime >= eIdleEffectFrameDuration) {
        eEffectLastFrameTime = parent.millis();
        eIdleEffectCurrentFrame += 1;
        if (eIdleEffectCurrentFrame > 2) {
          eIdleEffectCurrentFrame = 0;
        }
        if (eIdleEffectCurrentFrame != 3) {
          effectToShow = engineEffectsIdle[eIdleEffectCurrentFrame];
        }
      }
    }
    parent.image(engineSprite, playerX - 20, playerY -5, 160, 160);
    parent.image(weaponSprite, playerX, playerY, 150, 150);
    parent.image(playerSprite, playerX, playerY, 150, 150);
    parent.image(effectToShow, playerX - 25, playerY + 15, 150, 120);
  }
  public void displayAmmo(PApplet parent) {
    parent.fill(255, 0, 0);
    parent.textSize(100);
    parent.text(ammo + "/" + maxAmmo, 180, 80);
  }
  public void displayStamina(PApplet parent) {
    parent.fill(255, 0, 0);
    parent.textSize(100);
    parent.text(stamina, 180, 80);
  }
  public void displayHP (PApplet parent) {
    parent.fill(0, 255, 255);
    parent.textSize(100);
    parent.text(playerHP, 50, 80);
    parent.text(earthHP, parent.width - 110, 80);
  }
  public void move (float multiplier) {
    if (playerY >= height - 60) {
      playerY = -139;
    }
    if (playerY <= - 140) {
      playerY = height - 60;
    }
    if (arduino_values[1] < 0 && stamina > 0 && arduino_values[3] == 0) {
      if (keyReleased == false) {
        keyLastReleased = millis();
        keyReleased = true;
      }
      playerY += multiplier * playerSpeed * speedBonus;
      stamina -= 0.05 * speedBonus;
      isMoving = true;
      keyReleased = false;
    }
    if (arduino_values[1] > 0 && stamina > 0 && arduino_values[3] == 0) {
      if (keyReleased == false) {
        keyLastReleased = millis();
        keyReleased = true;
      }
      playerY -= multiplier * playerSpeed * speedBonus;
      stamina -= 0.05 * speedBonus;
      isMoving = true;
      keyReleased = false;
    }
    if (arduino_values[1] != 0 && stamina == 0 || arduino_values[1] != 0 && arduino_values[3] != 0) {
      errorSound.play();
    }
    if (keyPressed) {
      if (key == 'w' && stamina > 0) {
        playerY -= playerSpeed;
        isMoving = true;
        keyReleased = false;
      }
      if (key == 's' && stamina > 0) {
        playerY += playerSpeed;
        isMoving = true;
        keyReleased = false;
      }
      if (key == 'w' || key == 's') {
        if (keyReleased == false) {
          keyLastReleased = millis();
          keyReleased = true;
        }
      }
    }
    if (millis() - keyLastReleased >= idleTime) {
      isMoving = false;
    }
  }
  public void shoot() {
    if (keyPressed) {
      if (key == ' ' && ammo > 0 && (millis() - lastFireTime >= pCD)) {
        lastFireTime = millis();
        projectiles.add(new Projectile(playerX + 100, playerY + 50, 6));
        shootSound.play();
        ammo--;
      }
      if (key == ' ' && ammo == 0) {
        errorSound.play();
      }
    }
    if (arduino_values[0] == 1 && ammo > 0 && (millis() - lastFireTime >= pCD)) {
      lastFireTime = millis();
      projectiles.add(new Projectile(playerX + 100, playerY + 50, 6));
      shootSound.play();
      ammo--;
    }
  }
  public void reload() {
    if (keyPressed) {
      if (key == 'r' && ammo < maxAmmo) {
        ammo += 1;
        if (ammo > maxAmmo) {
          ammo = maxAmmo;
        }
      }
    }
    if (arduino_values[2] != 0 && ammo < maxAmmo) {
      ammo += 1;
      if (ammo > maxAmmo) {
        ammo = maxAmmo;
      }
    }
    if (arduino_values[3] == 1 && stamina < maxStamina) {
      stamina += 100;
      if (stamina > maxStamina) {
        stamina = maxStamina;
      }
    }
  }
  void reset() {
    ammo = maxAmmo;
    stamina = maxStamina;
  }
}
