public class ServoMotor {
  protected int id; //the pin of the motor
  protected int neutralIntensity;
  protected int attackIntensity;
  protected int maxIntensity;

  protected int servoPulse;
  protected Seat theSeat;

  // Constructor
  public ServoMotor(int tmpid, int tmpneutralIntensity, int tmpattackIntensity, int tmpmaxIntensity) {
    id = tmpid;
    neutralIntensity = tmpneutralIntensity;
    attackIntensity = tmpattackIntensity;
    maxIntensity = tmpmaxIntensity;
    theSeat = Seat.getInstance();
    setServoPulse(neutralIntensity);
  }

  // Constructor
  public ServoMotor(int tmpid) {
    this(tmpid, 410, 410, 410);
  }

  public void setServoPulse(int value) {
    servoPulse = value;
    if(theSeat.isConnected()) {
      theSeat.changeMotor(id, servoPulse);
    }
  }

  public int getServoPulse() {
    return servoPulse;
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