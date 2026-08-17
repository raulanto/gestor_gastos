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
    Icons.account_balance_wallet_outlined.codePoint: Icons.account_balance_wallet_outlined,
    Icons.school.codePoint: Icons.school,
    Icons.restaurant.codePoint: Icons.restaurant,
    Icons.local_cafe.codePoint: Icons.local_cafe,
    Icons.train.codePoint: Icons.train,
    Icons.fitness_center.codePoint: Icons.fitness_center,
    Icons.sports_esports.codePoint: Icons.sports_esports,
    Icons.checkroom.codePoint: Icons.checkroom,
    Icons.local_grocery_store.codePoint: Icons.local_grocery_store,
    Icons.medical_services.codePoint: Icons.medical_services,
    Icons.subscriptions.codePoint: Icons.subscriptions,
    Icons.wifi.codePoint: Icons.wifi,
    Icons.water_drop.codePoint: Icons.water_drop,
    Icons.bolt.codePoint: Icons.bolt,
    Icons.local_gas_station.codePoint: Icons.local_gas_station,
    Icons.phone_iphone.codePoint: Icons.phone_iphone,
    Icons.child_care.codePoint: Icons.child_care,
    Icons.card_giftcard.codePoint: Icons.card_giftcard,
  };

  static List<IconData> get allIcons => _iconMap.values.toList();

  static IconData getIcon(int codePoint) {
    return _iconMap[codePoint] ?? Icons.help_outline;
  }
}
