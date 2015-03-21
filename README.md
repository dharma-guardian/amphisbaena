# amphisbaena

Is a hardware low-fidelity prototype to control 16 servo motors embodied in a car seat. We use Arduino with the [16 Channel PWN Servo Driver](https://learn.adafruit.com/16-channel-pwm-servo-driver/overview) to address the servo-motors and Processing to control the the motors via serial communication.

## Installation
### Install Arduino Libraries:
* Adafruit PWM Servo Driver from https://github.com/adafruit/Adafruit-PWM-Servo-Driver-Library.
* Command Messenger https://github.com/thijse/Arduino-Libraries/tree/master/CmdMessenger from http://thijs.elenbaas.net/downloads/?did=9
* StandardCplusplus from https://github.com/maniacbug/StandardCplusplus

### Install Processing Library
* ControlP5: Open the Processing IDE and select from the menu `Sketch > Import Library... > Add Library...` OR download it from http://www.sojamo.de/libraries/controlP5/