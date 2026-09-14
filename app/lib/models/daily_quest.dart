class DailyQuest {
  final String id;
  final String name;
  final double target;
  double current;
  final String unit;
  bool isCompleted;
  bool isSelected;
  final String date;

  DailyQuest({
    required this.id,
    required this.name,
    required this.target,
    this.current = 0.0,
    required this.unit,
    this.isCompleted = false,
    this.isSelected = false,
    required this.date,
  });

  double get progress => (current / target).clamp(0.0, 1.0);

  void addProgress(double value) {
    current += value;
    if (current >= target) {
      current = target;
      isCompleted = true;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target': target,
      'current': current,
      'unit': unit,
      'is_completed': isCompleted ? 1 : 0,
      'is_selected': isSelected ? 1 : 0,
      'date': date,
    };
  }

  factory DailyQuest.fromMap(Map<String, dynamic> map) {
    return DailyQuest(
      id: map['id'],
      name: map['name'],
      target: (map['target'] as num).toDouble(),
      current: (map['current'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'],
      isCompleted: (map['is_completed'] == 1 || map['is_completed'] == true),
      isSelected: (map['is_selected'] == 1 || map['is_selected'] == true),
      date: map['date'],
    );
  }
}
