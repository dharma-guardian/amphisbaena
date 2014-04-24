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
boolean bloop = false;
int servosAttached = 8;

int servoAngle[16] = 
                      {20, 60, 120, 160, 
                      35, 60, 120, 145, 
                      20, 60, 120, 160, 
                      20, 60, 120, 160};
int servoActiveDist[16] = 
                      {
                       0,0,0,0,
                       90,90,90,90,
                       180,180,180,180,
                       270,270,270,270
                      }
                       
int servoDeltaI[16] = {0, 0, 0, 0, 
                       0, 0, 0, 0, 
                       0, 0, 0, 0, 
                       0, 0, 0, 0};
int servoDeltaO[16] = {30, 60, 60, 30, 
                       30, 60, 60, 30, 
                       30, 60, 60, 30, 
                       30, 60, 60, 30};
int servoMin[16] = {540, 510, 170, 150, 
                    150, 150, 670, 670};
int servoAttack[16] = {350, 415, 250, 290, 
                       240, 240, 600, 600};
int servoMax[16] = {220, 335, 360, 450, 
                    450, 450, 340, 340};

void setup() {
  Serial.begin(9600);
  Serial.println("8 servos in a row intensity from angle");

  pwm.begin();
  
  pwm.setPWMFreq(60);  // Analog servos run at ~60 Hz updates
  resetServos();  
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
      intensity = map(deviation, servoDeltaO[servonum], servoDeltaI[servonum], servoAttack[servonum], servoMax[servonum]);
    }
  }
  return intensity;
  
}

void loop() {
  int tangle = angle;
  //receive angle per serial
  if (Serial.available() > 0) {
        bloop = false;
    // read the incoming int:
    tangle = Serial.parseInt();
    if (tangle > 180 || tangle < 0) {
      if (tangle == 666) {            // SPECIAL COMMAND GOING NUTS
        bloop = true;
      }else if (tangle == 999){      // SPECIAL COMMAND RESET
        resetServos();
      }
      else {
        tangle = angle;
      }
    }
  }
  
  // Loop Tester  
  if (bloop) {
    tangle -= 3;
    if(tangle < 0) {
      tangle = 180;
      angle = 180;
    }
  }
  
  int deviation = angle-tangle;
  if (abs(deviation) > input_tolerance) {
    Serial.println("Change");
    angle = tangle;
    // our servo # counter
    for (int servonum = 0; servonum < servosAttached; servonum++) {
      // Drive each servo one at a time
      pwm.setPWM(servonum, 0, getIntensity(servonum, angle)); 
    }
  }
  
  //safety delay
  delay(50);
}
// Drive Servos to idle position
void resetServos()
{
  for (int servonum = 0; servonum < servosAttached; servonum++) {
    // Drive each servo one at a time
    pwm.setPWM(servonum, 0, servoMin[servonum]); 
  }
}
