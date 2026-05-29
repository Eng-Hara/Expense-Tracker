import 'package:flutter/material.dart';

class IconHelper {
  static const List<String> iconOptions = [
    'fastfood',
    'shopping_cart',
    'directions_car',
    'movie',
    'receipt',
    'favorite',
    'work',
    'home',
    'school',
    'sports_esports',
    'flight',
    'health_and_safety',
    'pets',
    'shopping_bag',
    'restaurant',
    'help'
  ];

  static IconData getIconData(String iconName) {
    switch (iconName) {
      case 'fastfood':
        return Icons.fastfood;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'directions_car':
        return Icons.directions_car;
      case 'movie':
        return Icons.movie;
      case 'receipt':
        return Icons.receipt;
      case 'favorite':
        return Icons.favorite;
      case 'work':
        return Icons.work;
      case 'home':
        return Icons.home;
      case 'school':
        return Icons.school;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'flight':
        return Icons.flight;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'pets':
        return Icons.pets;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.help;
    }
  }
}
