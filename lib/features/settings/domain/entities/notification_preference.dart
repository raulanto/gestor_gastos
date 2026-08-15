class NotificationPreference {
  final int? id;
  final String type;
  final bool isEnabled;
  final String? timeOfDay;

  NotificationPreference({
    this.id,
    required this.type,
    required this.isEnabled,
    this.timeOfDay,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'is_enabled': isEnabled ? 1 : 0,
      'time_of_day': timeOfDay,
    };
  }

  factory NotificationPreference.fromMap(Map<String, dynamic> map) {
    return NotificationPreference(
      id: map['id'],
      type: map['type'],
      isEnabled: map['is_enabled'] == 1,
      timeOfDay: map['time_of_day'],
    );
  }

  NotificationPreference copyWith({
    int? id,
    String? type,
    bool? isEnabled,
    String? timeOfDay,
  }) {
    return NotificationPreference(
      id: id ?? this.id,
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
      timeOfDay: timeOfDay ?? this.timeOfDay,
    );
  }
}
