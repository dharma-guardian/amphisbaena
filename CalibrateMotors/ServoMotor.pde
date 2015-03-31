public class ServoMotor {
  static final float MAXINTENSITY = 0.8;
  protected int id; //the pin of the motor
  protected int neutralIntensity;
  protected int attackIntensity;
  protected int maxIntensity;

  protected int horizontalAngle;
  protected int fov;
  protected float activeDistance = 1;

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
    switch (floor(tmpid / 4)) {
      case 0 :
        activeDistance = 0.66;
      break;
      case 1 :
        activeDistance = 1;
      break;
      case 2 :
        activeDistance = 0.85;
      break;
      case 3 :
        activeDistance = 0.5;
      break;
    }
    theSeat = Seat.getInstance();
    setServoPulse(neutralIntensity);
  }

  // Constructor
  public ServoMotor(int tmpid, int tmpneutralIntensity, int tmpattackIntensity, int tmpmaxIntensity) {
    this(tmpid, tmpneutralIntensity, tmpattackIntensity, tmpmaxIntensity, 0, 0);
    switch (tmpid % 4) {
      case 0 :
        horizontalAngle = 120;
        fov = 90;
      break;
      case 1 :
        horizontalAngle = 160;
        fov = 90;
      break;
      case 2 :
        horizontalAngle = 200;
        fov = 90;
      break;
      case 3 :
        horizontalAngle = 240;
        fov = 90;
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
    tmpservoPulse = int(map(intensity, 0, 1, attackIntensity, maxIntensity));
    setServoPulse(tmpservoPulse);
  }

  public void setIntensityFromAngle(float angle) {
    float deviation = abs(horizontalAngle - angle);
    //is angle inside the range of the servo?
    if (deviation <= fov) {
      float intensity = map(deviation, 0, fov, MAXINTENSITY, 0); // set max intensity to 0.8
      setIntensity(intensity);
    }
    else {
      setIntensity(0);
    }
  }

  public void setIntensityFromAngleAndDistance(float angle, float distance) {
    float deviation = abs(horizontalAngle - angle);
    //is angle inside the range of the servo?
    if (deviation <= fov) {
      float intensity = map(deviation, 0, fov, MAXINTENSITY, 0); // set max intensity to 0.8
      intensity = intensity * map(distance, 0, activeDistance, 1, 0);
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