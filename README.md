# amphisbaena

[![Join the chat at https://gitter.im/dharma-guardian/amphisbaena](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/dharma-guardian/amphisbaena?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Is a hardware low-fidelity prototype to control 16 servo motors embedded in a car seat. We use Arduino with the [16 Channel PWN Servo Driver](https://learn.adafruit.com/16-channel-pwm-servo-driver/overview) to address the servo motors and Processing via serial communication for calibration and control.

## Installation
### Install Arduino Libraries:
* Adafruit PWM Servo Driver from https://github.com/adafruit/Adafruit-PWM-Servo-Driver-Library.

### Install Processing Library
Open the Processing IDE and select from the menu `Sketch > Import Library... > Add Library...`
* UI library `ControlP5` OR download it from http://www.sojamo.de/libraries/controlP5/
* Client spacebrew library `SpacebrewP5` OR download it from https://github.com/Spacebrew/spacebrewP5
