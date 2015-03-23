/***************************************************
  Advanced Seat
****************************************************/
#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>

Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();

#define MOTORCOUNT 16
#define SERVOMIN  150 // this is the 'minimum' pulse length count (out of 4096)
#define SERVOMAX  670 // this is the 'maximum' pulse length count (out of 4096)

#define HEADER 'M'
#define MESSAGE_BYTES 33

uint16_t motorsMin[] = {160,165,635,555,165,165,580,620,170,159,550,550,165,161,550,550};
uint16_t motorsMax[] = {466,435,339,276,445,477,309,305,445,452,260,267,435,488,247,232};

void setup() {
  // Listen on serial connection for messages from the PC
  // 115200 is the max speed on Arduino Uno, Mega, with AT8u2 USB
  // Use 57600 for the Arduino Duemilanove and others with FTDI Serial
  Serial.begin(57600);

  pwm.begin();
  pwm.setPWMFreq(60);  // Analog servos run at ~60 Hz updates
  resetMotors();
}

/**
* Main Loop
**/
void loop() {
  // Process incoming serial data
  if (Serial.available() >= MESSAGE_BYTES)
  {
    if (Serial.read() == HEADER)
    {
      for(int i = 0; i < MOTORCOUNT; i++){
          uint16_t val = Serial.read() * 256;
          val = val + Serial.read();

          fireMotor(i, val);
      }
    }
  }
}

void fireMotor(uint8_t motorID, uint16_t motorIntensity)
{
  String msg;
  if(  (motorsMin[motorID] < motorsMax[motorID] && motorIntensity >= motorsMin[motorID] && motorIntensity <= motorsMax[motorID])
    || (motorsMin[motorID] > motorsMax[motorID] && motorIntensity <= motorsMin[motorID] && motorIntensity >= motorsMax[motorID]))
  {
    pwm.setPWM(motorID, 0, motorIntensity);

    msg = String(motorID) + " Motor set to ";
    msg = msg + String(motorIntensity);
    Serial.println(msg);

    delay(1);
  } else {
    msg = String(motorID) + " out of bounds. Min: ";
    msg = msg + String(motorsMin[motorID]) + ", Val: ";
    msg = msg + String(motorIntensity) + ", Max: ";
    msg = msg + String(motorsMax[motorID]);
    Serial.println(msg);
  }
}

// Drive Servos to idle position
void resetMotors()
{
  for(uint8_t i = 0; i < MOTORCOUNT; i++){
      fireMotor(i, motorsMin[i]);
  }
}