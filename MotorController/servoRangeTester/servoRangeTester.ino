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


int servoMin[16] = {540, 510, 170, 150,
                    150, 650, 150, 670};

int servonum = 6;

void setup() {
  Serial.begin(9600);
  Serial.print("Set Servo #");
  Serial.print(servonum);
  Serial.println(" by Serial Send");

  pwm.begin();

  pwm.setPWMFreq(60);  // Analog servos run at ~60 Hz updates

  resetServos();
}

void loop() {
  int tangle;
  if (Serial.available() > 0) {
    // read the incoming int:
    tangle = Serial.parseInt();
    if(tangle <= SERVOMAX && tangle >= SERVOMIN) {
      pwm.setPWM(servonum, 0, tangle);
    }
  }

  //safety delay
  delay(5);
}

// Drive Servos to idle position
void resetServos()
{
  for (int servonum = 0; servonum < 8; servonum++) {
    // Drive each servo one at a time
    pwm.setPWM(servonum, 0, servoMin[servonum]);
  }
}
