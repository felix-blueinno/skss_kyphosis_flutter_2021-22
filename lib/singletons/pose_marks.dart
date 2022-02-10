class PoseMarks {
  PoseMarks._privateConstructor();
  static final PoseMarks _instance = PoseMarks._privateConstructor();

  double _leftEarShoulderAngle = 360;
  double _leftShoulderHipAngle = 360;
  double _leftHipAnkleAngle = 360;

  static PoseMarks get instance => _instance;

  get earShoulderAngle => _leftEarShoulderAngle;
  set earShoulderAngle(angle) => _leftEarShoulderAngle = angle;

  get shoulderHipAngle => _leftShoulderHipAngle;
  set shoulderHipAngle(angle) => _leftShoulderHipAngle = angle;

  get hipAnkleAngle => _leftHipAnkleAngle;
  set hipAnkleAngle(angle) => _leftHipAnkleAngle = angle;

  setAngles(earShoulder, shoulderHip, hipAnkle) {
    _leftEarShoulderAngle = earShoulder;
    _leftShoulderHipAngle = shoulderHip;
    _leftHipAnkleAngle = hipAnkle;
  }
}
