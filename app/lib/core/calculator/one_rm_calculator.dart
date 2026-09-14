class OneRmCalculator {
  /// Epley formula: 1RM = weight * (1 + reps / 30)
  static double epley({required double weight, required int reps}) {
    if (reps <= 1) return weight;
    return weight * (1.0 + (reps / 30.0));
  }

  /// Brzycki formula: 1RM = weight * (36 / (37 - reps))
  static double brzycki({required double weight, required int reps}) {
    if (reps <= 1) return weight;
    if (reps >= 37) return epley(weight: weight, reps: reps);
    return weight * (36.0 / (37.0 - reps));
  }

  /// Average 1RM for balanced estimate
  static double estimate({required double weight, required int reps}) {
    if (reps <= 1) return weight;
    final e = epley(weight: weight, reps: reps);
    final b = brzycki(weight: weight, reps: reps);
    return (e + b) / 2.0;
  }
}
