
//joystick inputs and initialization
#define joystickYPin A0  // Arduino pin connected to VRY pin
#define UP_THRESHOLD 800
#define DOWN_THRESHOLD 800
#define COMMAND_NO 0x00
#define COMMAND_UP 0x04
#define COMMAND_DOWN 0x08

// Neopixel
#include <FastLED.h>
#define NUM_LEDS 60  // How many LEDs in your strip?
#define DATA_PIN 9   // Which pin is connected to the strip's DIN?
CRGB leds[NUM_LEDS];

void setColor(CRGB color) {
  for (int i = 0; i < NUM_LEDS; i++) {
    leds[i] = color;  // Set each LED in the array to the specified color
  }
  FastLED.show();  // Update the LED strip to apply the color
}


//stamina inputs and initialization 
const int tiltSensorPin = 8; // Digital pin 2
int stamina_refill;
// joystick inputs and initialization
int yValue = 0;  // To store value of the Y axis
int command = COMMAND_NO;
int speed_y_from_joystick = 20;
int ySent;

// Rotary Encoder Inputs and initialization
const int clkPin = 2;  // CLK to D2
const int dtPin = 4;   // DT to D3


int counter = 0;      // count rotary encoder
int lastClkState;     // 上一次读取的 CLK 状态
int currentClkState;  // 当前 CLK 状态
int prev_counter = 0;
int reload;  //0=no reload; 1= reload

// switch input and initialization
const int switchPin = 7;  // 开关连接到 D2 引脚
int shoot = 0;            // 定义 shoot 变量，默认值为 0
int prevSwitchState = HIGH; // Track the previous state of the switch
int currentSwitchState;     // Track the current state of the switch



void setup() {
  pinMode(clkPin, INPUT);
  pinMode(dtPin, INPUT);
  pinMode(switchPin, INPUT_PULLUP);  // 设置 switchPin 为输入，并启用内部上拉电阻
  pinMode(tiltSensorPin, INPUT_PULLUP);
  lastClkState = digitalRead(clkPin);  // 初始化 CLK 状态
  Serial.begin(9600);

  //Neopixel

  // FastLED.addLeds<NEOPIXEL, DATA_PIN>(leds, NUM_LEDS);
  // FastLED.setBrightness(100);  // external 5V needed for full brightness

  // setColor(CRGB::Green); // Neopixel green in the beginning
  // FastLED.show();
  // delay(5000);
  // setColor(CRGB::Red); // Turn to red after 5 seconds
  // FastLED.show();

}

void loop() {
  unsigned long currentMillis = millis();

      //tilt sensor 
    int tiltState = digitalRead(tiltSensorPin);
    if (tiltState == HIGH) {
      stamina_refill =1;

      // //neopixel controlled by tilt sensor
      // setColor(CRGB::Green);
      // FastLED.show();
      // delay(5000);
      // // After 5 seconds, turn red
      // setColor(CRGB::Red);
      // FastLED.show();
      
    } else {
      stamina_refill = 0;
    }

  // 读取 Joystick Y 轴的模拟值（范围为 0 - 1023）
  int yPosition = analogRead(joystickYPin);

  // Add a dead zone around the center
  if (yPosition > 478 && yPosition < 512) {
    yPosition = 512;  // Set to center value
  }

  // 将 0-1023 映射到 0-800
  int mappedY_Velocity = map(yPosition, 0, 1023, speed_y_from_joystick * (-1), speed_y_from_joystick);
  if (mappedY_Velocity >= 18) {
    ySent = 1;
  } else if (mappedY_Velocity <= -18) {
    ySent = -1;
  } else {
    ySent = 0;
  }


  //rotary encoder
  // 读取当前 CLK 状态
  currentClkState = digitalRead(clkPin);
  reload = 0;
  // 如果检测到 CLK 状态发生变化，说明旋转了
  if (currentClkState != lastClkState) {
    // 读取 DT 状态来判断方向
    if (digitalRead(dtPin) != currentClkState) {
      prev_counter = counter;
      counter++;  // 顺时针旋转

      if (counter - prev_counter > 0) {
        reload = 1;
      }
    }
  }

  // 更新上一次的 CLK 状态
  lastClkState = currentClkState;

  delay(10);  // 稍微延时以避免过多刷新

  // code for switch

  int currentSwitchState = digitalRead(switchPin);

  // 如果开关接通（LOW 表示接通），设置 shoot 为 1
  if (prevSwitchState == HIGH & currentSwitchState == LOW) {
    shoot = 1;
  } else {
    shoot = 0;
  }
  prevSwitchState = currentSwitchState;

  Serial.print(shoot);
  Serial.print(",");
  Serial.print(ySent);
  Serial.print(",");
  Serial.print(reload);
  Serial.print(",");
  Serial.println(stamina_refill);

  delay(10);
}

