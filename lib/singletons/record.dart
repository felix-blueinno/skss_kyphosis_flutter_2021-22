class Record {
  Record._privateConstructor();
  static final Record _instance = Record._privateConstructor();

  bool _postureCorrect = false;
  String _earShoulderAngle = 'none';
  String _shoulderHipAngle = 'none';
  String _hipAnkleAngle = 'none';
  int _exercise1Rounds = 0;
  int _exercise2Rounds = 0;

  static Record get instance => _instance;

  void reset() {
    _postureCorrect = false;
    _earShoulderAngle = '無';
    _shoulderHipAngle = '無';
    _hipAnkleAngle = '無';
    _exercise1Rounds = 0;
    _exercise2Rounds = 0;
  }

  get postureCorrect => _postureCorrect;
  set postureCorrect(correct) => _postureCorrect = correct;

  get earShoulder => _earShoulderAngle;
  set earShoulder(angle) => _earShoulderAngle = angle + '°';

  get shoulderHip => _shoulderHipAngle;
  set shoulderHip(angle) => _shoulderHipAngle = angle + '°';

  get hipAnkle => _hipAnkleAngle;
  set hipAnkle(angle) => _hipAnkleAngle = angle + '°';

  get exercise1Rounds => _exercise1Rounds;
  set exercise1Rounds(rounds) => _exercise1Rounds = rounds;

  get exercise2Count => _exercise2Rounds;
  set exercise2Count(rounds) => _exercise2Rounds = rounds;
}
