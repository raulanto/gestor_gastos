class Account {
  final int id;
  final String name;
  final double balance;
  final int iconCode;
  final int colorCode;

  const Account({
    required this.id,
    required this.name,
    this.balance = 0.0,
    required this.iconCode,
    required this.colorCode,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int,
      name: map['name'] as String,
      balance: map['balance'] as double,
      iconCode: map['icon_code'] as int,
      colorCode: map['color_code'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'icon_code': iconCode,
      'color_code': colorCode,
    };
  }

  Account copyWith({
    int? id,
    String? name,
    double? balance,
    int? iconCode,
    int? colorCode,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      iconCode: iconCode ?? this.iconCode,
      colorCode: colorCode ?? this.colorCode,
    );
  }
}
