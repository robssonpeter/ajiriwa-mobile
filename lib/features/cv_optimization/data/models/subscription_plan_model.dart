import '../../domain/entities/subscription_plan.dart';

class SubscriptionPlanModel extends SubscriptionPlan {
  const SubscriptionPlanModel({
    required super.id,
    required super.name,
    required super.level,
    required super.price,
    super.yearlyPrice,
    super.offerPrice,
    super.offerName,
    super.userType,
    required super.features,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    final contents = json['contents'] as List<dynamic>? ?? [];
    final features = contents
        .where((c) => c['value'] == true || c['value'] == 1 || c['value'] == '1')
        .map<String>((c) => c['label'] as String? ?? c['feature_key'] as String? ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    return SubscriptionPlanModel(
      id: json['id'] as int,
      name: json['name'] as String,
      level: json['level'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      yearlyPrice: (json['yearly_price'] as num?)?.toDouble(),
      offerPrice: (json['offer_price'] as num?)?.toDouble(),
      offerName: json['offer_name'] as String?,
      userType: json['user_type'] as String?,
      features: features,
    );
  }
}
