import processing.serial.*;
import processing.sound.*;
import processing.video.*;
import gifAnimation.*;

int NUM_OF_VALUES_FROM_ARDUINO = 4;  /* CHANGE THIS ACCORDING TO YOUR PROJECT */
Serial serialPort;
int arduino_values[] = new int[NUM_OF_VALUES_FROM_ARDUINO];

int NUM_LEDS = 60;
color[] leds = new color[NUM_LEDS];

PApplet windowA, windowB;

Player player;
Monster tutorialMonster;
Obstacle tutorialObstacle;
ArrayList<Projectile> projectiles = new ArrayList<Projectile>();
ArrayList<Monster> monsters = new ArrayList<Monster>();
ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();
Movie tutorialA, tutorialB, tutorialC;

boolean valuesToBeReset = true;
boolean tutorial1 = false;
boolean tutorial2 = false;
boolean tutorial3 = false;
boolean tutorial4 = false;
int gameState = 1;
boolean visionOff = false;

float speedBonus = 1.3;

Gif monsterGif;
Gif victory;

PImage bg;
float bg_x = 0;
float bg_speed = 1;
float bg_len = 10492;

SoundFile shootSound;
SoundFile errorSound;
SoundFile monsterSound;
SoundFile earthSound;
SoundFile playerSound;
SoundFile bgm;

boolean timeRecorded = false;
int gameStartTime = 0;
//Serial myPort;
boolean tutorialAPlay = true;
boolean tutorialBPlay = true;
boolean tutorialCPlay = false;
boolean tutorialDPlay = false;
boolean APlaying = false;
boolean CPlaying = false;
boolean C2Playing = false;
boolean DPlaying = false;

void initialize() {
APlaying = false;
CPlaying = false;
C2Playing = false;
DPlaying = false;
tutorialAPlay = true;
tutorialBPlay = false;
tutorialCPlay = true;
tutorialDPlay = false;
tutorialA = new Movie(this, "1.264");
//tutorialA.loop();
tutorialA.pause();
tutorialB = new Movie(this, "2.264");
//tutorialB.loop();
tutorialB.pause();
tutorialC = new Movie(this, "common.264");
//tutorialC.loop();
tutorialC.pause();
  bg_x = 0;
  bg = loadImage("bg.jpg");
  bgm = new SoundFile(this, "bgm.wav");
  // Clear or reset monsters
  monsters.clear();
  // Clear or reset obstacles
  obstacles.clear();
  // Clear or reset projectiles
  projectiles.clear();
  // Reset player stats
  shootSound = new SoundFile(this, "laser.ogg");
  errorSound = new SoundFile(this, "error.wav");
  monsterSound = new SoundFile(this, "alienDeath.wav");
  earthSound = new SoundFile(this, "villager.wav");
  playerSound = new SoundFile(this, "hurt.wav");
  monsterGif = new Gif(this, "monster.gif");
  monsterGif.loop();
  victory = new Gif(this, "victory.gif");
  victory.loop();
  gameStartTime = 0;
  player = new Player();
  player.reset();
  monsters.add(new Monster(800, 300));
  monsters.add(new Monster(600, 100));
  monsters.add(new Monster(750, 400));
  monsters.add(new Monster(1200, 200));
  obstacles.add(new Obstacle(1000, 200, 70, 500));
  obstacles.add(new Obstacle(1400, 400, 600, 90));
  obstacles.add(new Obstacle(2000, 100, 40, 550));
  obstacles.add(new Obstacle(1250, 500, 90, 400));
  tutorialMonster = new Monster(1000, 500);
  tutorialObstacle = new Obstacle(400, 400, 200, 200);

  timeRecorded = false;
  gameState = 0;
}

void setup() {
  printArray(Serial.list());
  serialPort = new Serial(this, "/dev/cu.usbmodem101", 9600);
  //myPort = new Serial(this, "/dev/cu.usbmodem101", 9600);
  size(1250, 800);
  frameRate(50);
  initialize();
    bgm.play();
    bgm.loop();
  windowB = new PlayerBWindow();
  projectiles.add(new Projectile(- 1000, 0, 0));
  windowTitle("Player A");
  //PApplet.runSketch(new String[] {"Player A"}, windowA);
  //windowB = new PlayerBWindow();
  //PApplet.runSketch(new String[] {"Player B"}, windowB);
}
void draw() {
  //println(frameRate);
if (tutorialA.available()) {
tutorialA.read();
}
if (tutorialB.available()) {
tutorialB.read();
}
if (tutorialC.available()) {
tutorialC.read();
}
  getSerialData();
  //if (player.stamina >= 180) {
  //for (int i = 0; i < NUM_LEDS; i++) {
  //  myPort.write(0 + '\n');
  //}
  //}
  //else if (player.stamina < 180 && player.stamina >= 80) {
  //  myPort.write(1 + '\n');
  //} 
  //else if (player.stamina < 80 && player.stamina > 0) {
  //  myPort.write(2 + '\n');
  //}
  //else if (player.stamina == 0) {
  //  myPort.write(3 + '\n');
  //}
  if (player.playerHP < 1 || player.earthHP < 1) {
    timeRecorded = false;
    gameState = 0;
    initialize();
  }
  if (gameState == 0) {
    if (tutorialAPlay && arduino_values[3] == 1) {
      tutorialAPlay = false;
      tutorialBPlay = true;
    }
    if (tutorialCPlay && arduino_values[2] != 0) {
      tutorialCPlay = false;
      tutorialDPlay = true;
    }
    else if (tutorialBPlay && tutorialDPlay && arduino_values[0] == 1) {
      gameState = 1;
    }
  }
  if (tutorialAPlay) {
    //print("JIBA");
  //tutorialA.read();
  image(tutorialA, 0, 0, width, height);
  if (!APlaying) {
  tutorialA.play();
  APlaying = true;
  }
  }
  if (tutorialBPlay) {
  //tutorialC.read();
  image(tutorialC, 0, 0, width, height);
  if (!CPlaying) {
  tutorialC.play();
  CPlaying = true;
  }
  }
  if (gameState == 1 && !timeRecorded) {
    tutorialA.pause();
    tutorialC.pause();
    gameStartTime = millis();
    timeRecorded = true;
  } else if (gameState ==1 && (13000 < (millis() - gameStartTime) && (millis() - gameStartTime < 180000))) {
    gameState = 2;
  }
  //} else if (gameState == 2 && (millis() - gameStartTime > 28000)) {
  //  visionOff = true;
  //} 
  else if (gameState == 2 && (millis() - gameStartTime > 180000)) {
    gameState = 3;
  } 
  if (gameState == 3 && (millis() - gameStartTime == 200000)) {
    timeRecorded = false;
    gameState = 0;
    initialize();  
}
  if (gameState == 1) {
    //print("STATE1");
    player.reset();
    background(0);
    tutorialMonster.display(this);
    tutorialObstacle.display(this);
    //image(victory, width/2, height/2);
    player.shoot();
    player.reload();
    player.display(this);
    player.move(0.45);
    for (int i = projectiles.size() - 1; i >= 0; i--) {
      Projectile p = projectiles.get(i);
      p.display(this);
      if (p.x > width) {
        projectiles.remove(i);
      }
      if (dist(p.x, p.y - 25, tutorialMonster.x, tutorialMonster.y) < 115) {
        tutorialMonster.reset();
        monsterSound.play();
        projectiles.remove(i);
      }
      if (player.playerX < tutorialObstacle.x + tutorialObstacle.oWidth &&
        player.playerX + 50 > tutorialObstacle.x &&
        player.playerY < tutorialObstacle.y + tutorialObstacle.oHeight &&
        player.playerY + 55 > tutorialObstacle.y) {
        tutorialObstacle.reset();
        playerSound.play();
      }
    }
  } else if (gameState == 2) {
    background(0);
    image(bg, bg_x, 0);
    bg_x -= bg_speed * speedBonus;
    player.displayHP(this);
    player.displayStamina(this);
    player.move(1);
    player.shoot();
    player.reload();
    player.display(this);
    if (player.kills >= 3) {
      player.playerHP += 1;
      player.kills = 0;
      errorSound.play();
    }
    // Handle projectiles
    for (int i = projectiles.size() - 1; i >= 0; i--) {
      Projectile p = projectiles.get(i);
      p.display(this);
      if (p.x > width) {
        projectiles.remove(i);
        continue;
      }

      // Collision detection with monsters
      for (int j = monsters.size() - 1; j >= 0; j--) {
        Monster m = monsters.get(j);
        if (dist(p.x, p.y - 25, m.x, m.y) < 115) {
          m.reset();
          monsterSound.play();
          projectiles.remove(i);
          player.kills += 1;
          break;
        }
      }
    }
    // Handle monsters
    for (int i = monsters.size() - 1; i >= 0; i--) {
      Monster m = monsters.get(i);
      m.move();
      m.display(this);
      if (m.x < -100) {
        m.reset();
        player.earthHP -= 1;
        earthSound.play();
      }
      if (dist(player.playerX, player.playerY, m.x, m.y -30) < 100) {
        m.reset();
        player.playerHP -= 1;
        playerSound.play();
      }
    }
    for (int i = obstacles.size() - 1; i >= 0; i--) {
      Obstacle o = obstacles.get(i);
      //if (!visionOff) {
      //  o.display(this);
      //}
      //o.display(this);
      if (o.x < 0.8*width) {
        o.move();
      }
      if (o.x < -100) {
        o.reset();
      }
      if (player.playerX < o.x + o.oWidth &&
        player.playerX + 50 > o.x &&
        player.playerY < o.y + o.oHeight &&
        player.playerY + 55 > o.y) {
        o.reset();
        player.playerHP -= 1;
        playerSound.play();
      }
    }
  }
  if (gameState == 3) {
    image(victory, 0, 0, width + 50, height + 50);
  }
  //sendColors();
}

class PlayerBWindow extends PApplet {
  //Player playerB;
  public PlayerBWindow() {
    super();
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }
  public void settings() {
    size(1250, 800);
  }
  public void setup() {
    frameRate(50);
    windowTitle("Player B");
    //playerB = new Player(this);
  }
  public void draw() {
    if (tutorialCPlay) {
    image(tutorialB, 0, 0, width, height);
    if (!C2Playing) {
    tutorialB.play();
    C2Playing = true;
    }
    }
    if (tutorialDPlay) {
    image(tutorialC, 0, 0, width, height);
    if (!DPlaying) {
    tutorialC.play();
    DPlaying = true;
    }
    }
    if (gameState == 1) {
      tutorialB.pause();
      background(0);
      //player.move(1);
      player.display(this);
      for (int i = projectiles.size() - 1; i >= 0; i--) {
        Projectile p = projectiles.get(i);
        p.display(this);
      }
      tutorialMonster.display(this);
      tutorialObstacle.display(this);
    } else if (gameState == 2) {
      background(0);
      image(bg, bg_x, 0);
      //playerB.move(1);
      //playerB.display();
      player.display(this);
      player.displayHP(this);
      player.displayAmmo(this);
      for (int i = projectiles.size() - 1; i >= 0; i--) {
        Projectile p = projectiles.get(i);
        p.display(this);
      }
      //if (!visionOff) {
      //for (int i = monsters.size() - 1; i >= 0; i--) {
      //  Monster m = monsters.get(i);
      //  //if (!visionOff) {
      //  //  m.display(this);
      //  //}
      //}
      //}
      for (int i = obstacles.size() - 1; i >= 0; i--) {
        Obstacle o = obstacles.get(i);
        o.display(this);
      }
    }
    if (gameState == 3) {
      image(victory, 0, 0, width + 50, height + 50);
      
    }
    //  if (gameRunning && !timeRecorded) {
    //    gameStartTime = millis();
    //    timeRecorded = true;
    //  }
    //  if (gameRunning && (millis() - gameStartTime < 20000)) {
    //    background(0);
    //    rect(500, 500, 500, 500);
    //    tutorialMonster.display();
    //    tutorialObstacle.display();
    //    player.shoot();
    //    player.reload();
    //    player.display();
    //    player.move(1);
    //    for (int i = projectiles.size() - 1; i >= 0; i--) {
    //      Projectile p = projectiles.get(i);
    //      p.display();
    //      if (p.x > width) {
    //        projectiles.remove(i);
    //      }
    //      if (dist(p.x, p.y - 25, tutorialMonster.x, tutorialMonster.y) < 115) {
    //        tutorialMonster.reset();
    //        monsterSound.play();
    //        projectiles.remove(i);
    //      }
    //      if (player.playerX < tutorialObstacle.x + tutorialObstacle.oWidth &&
    //        player.playerX + 50 > tutorialObstacle.x &&
    //        player.playerY < tutorialObstacle.y + tutorialObstacle.oHeight &&
    //        player.playerY + 55 > tutorialObstacle.y) {
    //        tutorialObstacle.reset();
    //        playerSound.play();
    //      }
    //    }
    //  } else if (gameRunning && (millis() - gameStartTime > 20000)) {
    //    print("HI");
    //    background(0);
    //    player.displayHP();
    //    player.displayAmmo();
    //    player.move(1);
    //    player.shoot();
    //    player.reload();
    //    player.display();
    //    if (player.kills >= 3) {
    //      player.playerHP += 1;
    //      player.kills = 0;
    //      errorSound.play();
    //    }
    //    // Handle projectiles
    //    for (int i = projectiles.size() - 1; i >= 0; i--) {
    //      Projectile p = projectiles.get(i);
    //      p.display();
    //      if (p.x > width) {
    //        projectiles.remove(i);
    //        continue;
    //      }

    //      // Collision detection with monsters
    //      for (int j = monsters.size() - 1; j >= 0; j--) {
    //        Monster m = monsters.get(j);
    //        if (dist(p.x, p.y - 25, m.x, m.y) < 115) {
    //          m.reset();
    //          monsterSound.play();
    //          projectiles.remove(i);
    //          player.kills += 1;
    //          break;
    //        }
    //      }
    //    }
    //    // Handle monsters
    //    for (int i = monsters.size() - 1; i >= 0; i--) {
    //      Monster m = monsters.get(i);
    //      m.display();
    //      if (m.x < -100) {
    //        m.reset();
    //        player.earthHP -= 1;
    //        earthSound.play();
    //      }
    //      if (dist(player.playerX, player.playerY, m.x, m.y -30) < 100) {
    //        m.reset();
    //        player.playerHP -= 1;
    //        playerSound.play();
    //      }
    //    }
    //    for (int i = obstacles.size() - 1; i >= 0; i--) {
    //      Obstacle o = obstacles.get(i);
    //      o.display();
    //      if (o.x < 0.8*width) {
    //        o.move();
    //      }
    //      if (o.x < -100) {
    //        o.reset();
    //      }
    //      if (player.playerX < o.x + o.oWidth &&
    //        player.playerX + 50 > o.x &&
    //        player.playerY < o.y + o.oHeight &&
    //        player.playerY + 55 > o.y) {
    //        o.reset();
    //        player.playerHP -= 1;
    //        playerSound.play();
    //      }
    //    }
    //  }
  }
}


//}
//int monsterNum = 3;
//float[] monsterPosX = {800, 600, 750};
//float[] monsterPosY = {300, 100, 300};
//float[] monsterSpeed = {1, 1, 1};
//int[] monsterCollision = {0, 0, 0};
//int[] monsterHP = {2, 2, 2};
//float[] lastMoveTime = {0, 0, 0};
//int[] diceRoll = {0, 0, 0};
//int[] diceRoll2 = {0, 0, 0};



//void initialize() {
//  // monster values
//  monsterNum = 3;
//  monsterPosX[0] = 4000;
//  monsterPosX[1] = 4000;
//  monsterPosX[2] = 4000;
//  monsterPosY[0] = 4000;
//  monsterPosY[1] = 4000;
//  monsterPosY[2] = 4000;
//  monsterSpeed[0] = 0;
//  monsterSpeed[1] = 0;
//  monsterSpeed[2] = 0;
//  monsterCollision[0] = 0;
//  monsterCollision[1] = 0;
//  monsterCollision[2] = 0;
//  lastMoveTime[0] = 0;
//  lastMoveTime[1] = 0;
//  lastMoveTime[2] = 0;
//  diceRoll[0] = 0;
//  diceRoll[1] = 0;
//  diceRoll[2] = 0;
//  diceRoll2[0] = 0;
//  diceRoll2[1] = 0;
//  diceRoll2[2] = 0;
//  // player values
//  maxStamina = 250;
//  stamina = maxStamina;
//  player_speed = 20;
//  player_hp = 6;
//  village_hp = 10;
//  player_x = 20;
//  player_y = win_height/2;
//  // projectile values
//  pSpeeds[0] = 4;
//  pSpeeds[1] = 4;
//  pSpeeds[2] = 4;
//  pSpeeds[3] = 4;
//  pSpeeds[4] = 4;
//  pSpeeds[5] = 4;
//  pSpeeds[6] = 4;
//  pSpeeds[7] = 4;
//  pReady[0] = 1;
//  pReady[1] = 1;
//  pReady[2] = 1;
//  pReady[3] = 1;
//  pReady[4] = 1;
//  pReady[5] = 0;
//  pReady[6] = 0;
//  pReady[7] = 0;
//  pFlying[0] = 0;
//  pFlying[1] = 0;
//  pFlying[2] = 0;
//  pFlying[3] = 0;
//  pFlying[4] = 0;
//  pFlying[5] = 0;
//  pFlying[6] = 0;
//  pFlying[7] = 0;
//  // obstacle values
//  obstacleNum = 3;
//  obstacleSpeed = 0;
//  obstaclePosX[0] = 0;
//  obstaclePosX[1] = 0;
//  obstaclePosX[2] = 0;
//  obstaclePosY[0] = 0;
//  obstaclePosY[1] = 0;
//  obstaclePosY[2] = 0;
//  obstacleWidth[0] = 100;
//  obstacleWidth[1] = 200;
//  obstacleWidth[2] = 60;
//  obstacleHeight[0] = 300;
//  obstacleHeight[1] = 240;
//  obstacleHeight[2] = 400;
//  obstacleCollision[0] = 1;
//  obstacleCollision[1] = 1;
//  obstacleCollision[2] = 1;
//}
void getSerialData() {
  while (serialPort.available() > 0) {
    String in = serialPort.readStringUntil( 10 );  // 10 = '\n'  Linefeed in ASCII
    if (in != null) {
      print("From Arduino: " + in);
      String[] serialInArray = split(trim(in), ",");
      if (serialInArray.length == NUM_OF_VALUES_FROM_ARDUINO) {
        for (int i=0; i<serialInArray.length; i++) {
          arduino_values[i] = int(serialInArray[i]);
        }
      }
    }
  }
}

//void sendColors() {
//  byte[] out = new byte[NUM_LEDS*3];
//  for (int i=0; i < NUM_LEDS; i++) {
//    out[i*3]   = (byte)(floor(hue(leds[i])) >> 1);
//    if (i == 0) {
//      out[0] |= 1 << 7;
//    }
//    out[i*3+1] = (byte)(floor(saturation(leds[i])) >> 1);
//    out[i*3+2] = (byte)(floor(brightness(leds[i])) >> 1);
//  }
//  serialPort.write(out);
//}
