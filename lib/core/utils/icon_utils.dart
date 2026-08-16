import 'package:flutter/material.dart';

class IconUtils {
  static final Map<int, IconData> _iconMap = {
    Icons.category.codePoint: Icons.category,
    Icons.shopping_cart.codePoint: Icons.shopping_cart,
    Icons.fastfood.codePoint: Icons.fastfood,
    Icons.directions_car.codePoint: Icons.directions_car,
    Icons.home.codePoint: Icons.home,
    Icons.health_and_safety.codePoint: Icons.health_and_safety,
    Icons.flight.codePoint: Icons.flight,
    Icons.computer.codePoint: Icons.computer,
    Icons.movie.codePoint: Icons.movie,
    Icons.pets.codePoint: Icons.pets,
    Icons.account_balance_wallet.codePoint: Icons.account_balance_wallet,
    Icons.account_balance.codePoint: Icons.account_balance,
    Icons.credit_card.codePoint: Icons.credit_card,
    Icons.savings.codePoint: Icons.savings,
    Icons.money.codePoint: Icons.money,
    Icons.wallet.codePoint: Icons.wallet,
    Icons.payment.codePoint: Icons.payment,
    Icons.attach_money.codePoint: Icons.attach_money,
    Icons.person.codePoint: Icons.person,
    Icons.person_outline.codePoint: Icons.person_outline,
    Icons.calendar_today.codePoint: Icons.calendar_today,
    Icons.shopping_bag_outlined.codePoint: Icons.shopping_bag_outlined,
    Icons.swap_horiz.codePoint: Icons.swap_horiz,
    Icons.account_balance_wallet_outlined.codePoint:
        Icons.account_balance_wallet_outlined,
  };

  static IconData getIcon(int codePoint) {
    return _iconMap[codePoint] ?? Icons.help_outline;
  }
}
