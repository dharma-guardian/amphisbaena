/*
Serial Read Two Byte Values

 */

byte inByte;         // incoming serial byte
int ledPin = 13;
int serialInArray[2];
int serialCount, distance, angle;

void setup()
{
  // start serial port at 9600 bps:
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }

  pinMode(ledPin, OUTPUT);   // digital sensor is on digital pin 2
}

void loop()
{
  // if we get a valid byte, read analog ins:
  if (Serial.available()) {
    // get incoming byte:
    inByte = Serial.read();

    // Add the latest byte from the serial port to array:
    serialInArray[serialCount] = inByte;
    serialCount++;

    // If we have 3 bytes:
    if (serialCount > 1 ) {
      distance = serialInArray[0];
      angle = serialInArray[1];

      //do something with the values
      if (distance < 50) {
        digitalWrite(ledPin, HIGH);
      }
      else {
        digitalWrite(ledPin, LOW);
      }
      
      // Reset serialCount:
      serialCount = 0;
    }    
  }
}
