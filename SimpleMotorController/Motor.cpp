#include "Motor.h"
#include <Adafruit_PWMServoDriver.h>

Motor::Motor(uint8_t motorId, uint16_t minIntensityAbs, uint16_t maxIntensityAbs) : _motorId(motorId), _minIntensityAbs(minIntensityAbs), _maxIntensityAbs(maxIntensityAbs){}
uint8_t Motor::getId()
{
	return _motorId;
}


void Motor::setIntensity(uint16_t intensity) {
	_intensity = intensity;
	
}
uint16_t Motor::getIntensity(){
	return _intensity;
};
