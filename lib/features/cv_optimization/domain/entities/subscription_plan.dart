import 'package:equatable/equatable.dart';

class SubscriptionPlan extends Equatable {
  final int id;
  final String name;
  final int level;
  final double price;
  final double? yearlyPrice;
  final double? offerPrice;
  final String? offerName;
  final String? userType;
  final List<String> features;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.level,
    required this.price,
    this.yearlyPrice,
    this.offerPrice,
    this.offerName,
    this.userType,
    required this.features,
  });

  double get effectivePrice => offerPrice ?? price;

  @override
  List<Object?> get props => [id, name, level, price];
}
