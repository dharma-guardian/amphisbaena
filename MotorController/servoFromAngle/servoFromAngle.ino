/*************************************************** 
  This is an example for our Adafruit 16-channel PWM & Servo driver
  Servo test - this will drive 16 servos, one after the other

  Pick one up today in the adafruit shop!
  ------> http://www.adafruit.com/products/815

  These displays use I2C to communicate, 2 pins are required to  
  interface. For Arduino UNOs, thats SCL -> Analog 5, SDA -> Analog 4

  Adafruit invests time and resources providing this open source code, 
  please support Adafruit and open-source hardware by purchasing 
  products from Adafruit!

  Written by Limor Fried/Ladyada for Adafruit Industries.  
  BSD license, all text above must be included in any redistribution
 ****************************************************/

#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>

// called this way, it uses the default address 0x40
Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();
// you can also call it with a different address you want
//Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver(0x41);

// Depending on your servo make, the pulse width min and max may vary, you 
// want these to be as small/large as possible without hitting the hard stop
// for max range. You'll have to tweak them as necessary to match the servos you
// have!
#define SERVOMIN  150 // this is the 'minimum' pulse length count (out of 4096)
#define SERVOMAX  670 // this is the 'maximum' pulse length count (out of 4096)

int angle = 0;
double input_tolerance = 2;

int servoAngle[4] = {30, 60, 120, 150};
int servoDeltaI[4] = {15, 15, 15, 15};
int servoDeltaO[4] = {30, 30, 30, 30};
int servoMin[4] = {150, 150, 150, 150};
int servoMax[4] = {600, 400, 400, 600};

void setup() {
  Serial.begin(9600);
  Serial.println("4 servos in a row intensity from angle");

  pwm.begin();
  
  pwm.setPWMFreq(60);  // Analog servos run at ~60 Hz updates
}

double getIntensity(uint8_t servonum, int angle) {
  double intensity = servoMin[servonum];
  double deviation = abs(servoAngle[servonum]-angle);
  //is angle inside the range of the servo?
  if (deviation < servoDeltaO[servonum]) {
    //is the angle in the direct hit area of the servo
    if (deviation < servoDeltaI[servonum]) {
      intensity = servoMax[servonum];
    }
    else {
      intensity = map(deviation, servoDeltaO[servonum], servoDeltaI[servonum], servoMin[servonum], servoMax[servonum]);
    }
  }
  return intensity;
  
}

void loop() {
  int tangle = angle;
  if (Serial.available() > 0) {
    // read the incoming int:
    tangle = Serial.parseInt();
  }
  
// Loop Tester  
//  tangle += 3;
//  if(tangle > 180) {
//    tangle = 0;
//    angle = 0;
//  }
  
  int deviation = angle-tangle;
  if (abs(deviation) > input_tolerance) {
    Serial.println("Change");
    angle = tangle;
    // our servo # counter
    for (int servonum = 0; servonum < 4; servonum++) {
      // Drive each servo one at a time
      Serial.println(servonum);
      pwm.setPWM(servonum, 0, getIntensity(servonum, angle)); 
    }
  }
  
  //safety delay
  delay(5);
}
