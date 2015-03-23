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

  // Constructor
  public ServoMotor(int tmpid, int tmpneutralIntensity) {
    this(tmpid, tmpneutralIntensity, 410, 410);
  }

  public void setServoPulse(int value) {
    if (servoPulse != value) {
      servoPulse = value;
      theSeat.registerChange();
    }
  }

  public int getServoPulse() {
    return servoPulse;
  }

  public void setIntensity(float intensity) {
    int tmpservoPulse;
    if (intensity == 0) {
      tmpservoPulse = neutralIntensity;
    }
    else {
      tmpservoPulse = int(map(intensity, 0, 1, attackIntensity, maxIntensity));
    }
    setServoPulse(tmpservoPulse);
  }

  public int getNeutralIntensity() {
    return neutralIntensity;
  }

  public void setNeutralIntensity(int value) {
    neutralIntensity = value;
  }

  public void setAttackIntensity(int value) {
    attackIntensity = value;
  }

  public int getAttackIntensity() {
    return attackIntensity;
  }

  public void setMaxIntensity(int value) {
    maxIntensity = value;
  }

  public int getMaxIntensity() {
    return maxIntensity;
  }
}