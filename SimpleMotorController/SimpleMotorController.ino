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
#include <StandardCplusplus.h>
#include <vector>
using namespace std;
#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>
#include <Motor.h>
#include <CmdMessenger.h>  // CmdMessenger

// MotorVariables 
uint8_t selectedMotor     = 0;   // Current state of Led
//uint16_t motorIntensity   = 

// Attach a new CmdMessenger object to the default Serial port
CmdMessenger cmdMessenger = CmdMessenger(Serial);

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

vector<Motor> motors;
bool calibration; 

// Commands
enum
{
  kSetMotorIntensity,
  kResponse
  //kSelectMotor, // Command to request led to be set in specific state
  //kSetIntensity
};

// Callbacks define on which received commands we take action 
void attachCommandCallbacks()
{
  cmdMessenger.attach(kSetMotorIntensity, OnSetMotorIntensity);
  //cmdMessenger.attach(kSelectMotor, OnSelectMotor);
  //cmdMessenger.attach(kSetIntensity, OnSetIntensity);
}

void OnSetMotorIntensity()
{
  uint8_t motorID = cmdMessenger.readInt16Arg();
  uint16_t motorIntensity = cmdMessenger.readInt16Arg();
  cmdMessenger.sendCmd(kResponse,"MotorID: ");
  cmdMessenger.sendCmd(kResponse,motorID);
  cmdMessenger.sendCmd(kResponse,"MotorIntensity: ");
  cmdMessenger.sendCmd(kResponse,motorIntensity);
  fireMotor(motorID, motorIntensity);
}


void setup() {
  //DEBUG: always start in Calibration mode
  bool calibration = true;
  // Listen on serial connection for messages from the PC
  // 115200 is the max speed on Arduino Uno, Mega, with AT8u2 USB
  // Use 57600 for the Arduino Duemilanove and others with FTDI Serial
  Serial.begin(57600); 

  // Adds newline to every command
  cmdMessenger.printLfCr();   

  // Attach my application's user-defined callback methods
  attachCommandCallbacks();

  // Create #MOTORCOUNT Motor objects and push them to vector motors
  for (int i=0; i <= MOTORCOUNT; i++)
  {
    motors.push_back(Motor(i, SERVOMIN, SERVOMAX));
  }

  pwm.begin();
  pwm.setPWMFreq(60);  // Analog servos run at ~60 Hz updates
  //resetServos();
  for(int i=0; i<MOTORCOUNT;i++)
  {
    cmdMessenger.sendCmd(kResponse,"Motor ");
    cmdMessenger.sendCmd(kResponse,motors[i].getId());
  }
}

/**
* Main Loop
**/
void loop() {
  // Process incoming serial data, and perform callbacks
  cmdMessenger.feedinSerialData();
}

void fireMotor(uint8_t motorID, uint16_t motorIntensity)
{
  pwm.setPWM(motorID, 0, motorIntensity);
}


// Drive Servos to idle position
void resetServos()
{
  
}