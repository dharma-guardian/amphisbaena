/***************************************************
  Advanced Seat 
****************************************************/
#include <StandardCplusplus.h>
#include <vector>
using namespace std;
#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>
#include <Motor.h>
//#include <CmdMessenger.h>  // CmdMessenger

// MotorVariables
uint8_t selectedMotor     = 0;   // Current state of Led

// Attach a new CmdMessenger object to the default Serial port
//CmdMessenger cmdMessenger = CmdMessenger(Serial);

// called this way, it uses the default address 0x40
Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();
// you can also call it with a different address you want
//Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver(0x41);

// Depending on your servo make, the pulse width min and max may vary, you
// want these to be as small/large as possible without hitting the hard stop
// for max range. You'll have to tweak them as necessary to match the servos you
// have!
#define MOTORCOUNT 16
#define SERVOMIN  150 // this is the 'minimum' pulse length count (out of 4096)
#define SERVOMAX  670 // this is the 'maximum' pulse length count (out of 4096)

#define HEADER 'M'
#define MESSAGE_BYTES 32

uint16_t motorsMin[]{160,165,635,555,165,165,580,620,170,159,550,550,165,161,550,550};
uint16_t motorsMax[]{466,435,339,276,445,477,309,305,445,452,260,267,435,488,247,232};
vector<Motor> motors;
bool calibration;





void setup() {
  //DEBUG: always start in Calibration mode
  bool calibration = true;
  // Listen on serial connection for messages from the PC
  // 115200 is the max speed on Arduino Uno, Mega, with AT8u2 USB
  // Use 57600 for the Arduino Duemilanove and others with FTDI Serial
  Serial.begin(57600);


  // Create #MOTORCOUNT Motor objects and push them to vector motors
  for (int i=0; i <= MOTORCOUNT; i++)
  {
    motors.push_back(Motor(i, SERVOMIN, SERVOMAX));
  }

  pwm.begin();
  pwm.setPWMFreq(60);  // Analog servos run at ~60 Hz updates
  resetMotors();
  for(int i=0; i<MOTORCOUNT;i++)
  {
    //Serial.println("Motor ");
    //Serial.println(motors[i].getId());
  }
}

/**
* Main Loop
**/
void loop() {
  // Process incoming serial data, and perform callbacks
  if ( Serial.available() >= MESSAGE_BYTES)
  {
    if( Serial.read() == HEADER)
    {
      
        for(int i=0; i<MOTORCOUNT; i++){
            //Serial.readBytes(inputbuffer, 2);
            //motors[i] = word(inputbuffer);
            uint16_t val = Serial.read()*256;
            val = val + Serial.read();
            fireMotor(i, val);
            Serial.print('Motor: ');
            Serial.print(i);
            Serial.print(', Val: ');
            Serial.println(val);
        }
      }
  }

  
}


uint16_t readSerialValues()
{
  
}

void fireMotor(uint8_t motorID, uint16_t motorIntensity)
{
  if((motorsMin[motorID]<motorsMax[motorID] && motorIntensity>=motorsMin[motorID] && motorIntensity<=motorsMax[motorID])||(motorsMin[motorID]>motorsMax[motorID] && motorIntensity<=motorsMin[motorID] && motorIntensity>=motorsMax[motorID]))
  {
    pwm.setPWM(motorID, 0, motorIntensity);
    delay(20);
  }else{
    String msg = String(motorID)+" out of bounds. Min: ";
    msg = msg+String(motorsMin[motorID])+", Val: ";
    msg = msg+String(motorIntensity)+", Max: ";
    msg = msg+String(motorsMax[motorID]);
    Serial.println(msg);
  }
}


// Drive Servos to idle position
void resetMotors()
{
  for(uint8_t i=0; i<MOTORCOUNT; i++){
      fireMotor(i, motorsMin[i]);
      delay(100);
  }
}