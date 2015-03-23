public class ServoMotor {
  protected int id; //the pin of the motor
  protected int neutralIntensity;
  protected int attackIntensity;
  protected int maxIntensity;

  protected int horizontalAngle;
  protected int fov;

  protected int servoPulse;
  protected Seat theSeat;

  // Constructor
  public ServoMotor(int tmpid, int tmpneutralIntensity, int tmpattackIntensity, int tmpmaxIntensity, int tmpangle, int tmpfov) {
    id = tmpid;
    neutralIntensity = tmpneutralIntensity;
    attackIntensity = tmpattackIntensity;
    maxIntensity = tmpmaxIntensity;
    horizontalAngle = tmpangle;
    fov = tmpfov;
    theSeat = Seat.getInstance();
    setServoPulse(neutralIntensity);
  }

  // Constructor
  public ServoMotor(int tmpid, int tmpneutralIntensity, int tmpattackIntensity, int tmpmaxIntensity) {
    this(tmpid, tmpneutralIntensity, tmpattackIntensity, tmpmaxIntensity, 0, 0);
    switch (tmpid % 4) {
      case 0 :
        horizontalAngle = 20;
        fov = 30;
      break;
      case 1 :
        horizontalAngle = 60;
        fov = 60;
      break;
      case 2 :
        horizontalAngle = 120;
        fov = 60;
      break;
      case 3 :
        horizontalAngle = 160;
        fov = 30;
      break;
    }
  }

  // Constructor
  public ServoMotor(int tmpid, int tmpneutralIntensity) {
    this(tmpid, tmpneutralIntensity, 410, 410);
  }
  // Constructor
  public ServoMotor(int tmpid) {
    this(tmpid, 410);
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

  public void setIntensityFromAngle(float angle) {
    float deviation = abs(horizontalAngle - angle);
    //is angle inside the range of the servo?
    if (deviation <= fov) {
      float intensity = map(deviation, 0, fov, 0.8, 0); // set max intensity to 0.8
      setIntensity(intensity);
    }
    else {
      setIntensity(0);
    }
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