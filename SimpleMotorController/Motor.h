#if ARDUINO >= 100
 #include "Arduino.h"
#else
 #include "WProgram.h"
#endif

class Motor {
 private:
 uint8_t _motorId;
 uint16_t _intensity;
 uint16_t _minIntensityAbs;
 uint16_t _maxIntensityAbs;
public:

Motor(uint8_t motorId, uint16_t minIntensityAbs, uint16_t maxIntensityAbs); 
void setIntensity(uint16_t intensity);
uint8_t getId();
uint16_t getIntensity();
};