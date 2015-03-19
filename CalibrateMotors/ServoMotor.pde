class ServoMotor {
  int id; //the pin of the motor
  int neutralIntensity;
  int attackIntensity;
  int maxIntensity;

  int servoPulse;
  Seat theSeat;

  // Constructor
  ServoMotor(int tmpid, int tmpneutralIntensity, int tmpattackIntensity, int tmpmaxIntensity) {
    id = tmpid;
    neutralIntensity = tmpneutralIntensity;
    attackIntensity = tmpattackIntensity;
    maxIntensity = tmpmaxIntensity;
    theSeat = Seat.getInstance();
  }

  public void setServoPulse(int value) {
    servoPulse = value;
    theSeat.changeMotor(id, servoPulse);
  }

  public void setIntensity(float intensity) {
    if (intensity == 0) {
      servoPulse = neutralIntensity;
    }
    else {
      servoPulse = int(map(intensity, 0, 1, attackIntensity, maxIntensity));
    }
    setServoPulse(servoPulse);
  }

  public void setNeutralIntensity(int value) {
    neutralIntensity = value;
  }

  public void setAttackIntensity(int value) {
    attackIntensity = value;
  }

  public void setMaxIntensity(int value) {
    maxIntensity = value;
  }
}