class ExerciseSupervisor {
  ExerciseSupervisor._privateConstructor();

  static final ExerciseSupervisor _instance =
      ExerciseSupervisor._privateConstructor();

  final Stopwatch _stopwatch = Stopwatch();

  int exercise1Round = 0; // Current round
  final int exercise1MaxRounds = 1; // Maximum number of round
  final int _exercise1MaxTime = 2; // Time for each round

  int exercise2Count = 0;
  final int _exercise2MaxCount = 10;
  bool counted = false;

  static ExerciseSupervisor get instance => _instance;

  pauseStopwatch() => _stopwatch.stop();
  startStopwatch() => _stopwatch.start();
  reset() => _stopwatch.reset();

  int get stopwatchElapsedSeconds => _stopwatch.elapsed.inSeconds;
  bool get stopwatchIsRunning => _stopwatch.isRunning;

  int get exercise1MaxTime => _exercise1MaxTime;
  int get exercise2MaxCount => _exercise2MaxCount;
}
