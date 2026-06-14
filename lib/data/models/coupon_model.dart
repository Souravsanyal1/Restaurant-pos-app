class CouponModel {
  final String code;
  final bool isPercentage;
  final double value;
  final double minOrderAmount;
  bool isActive;

  CouponModel({
    required this.code,
    required this.isPercentage,
    required this.value,
    required this.minOrderAmount,
    this.isActive = true,
  });

  double calculateDiscount(double subtotal) {
    if (subtotal < minOrderAmount) return 0.0;
    if (isPercentage) {
      return subtotal * (value / 100.0);
    } else {
      return value;
    }
  }

  CouponModel copyWith({
    String? code,
    bool? isPercentage,
    double? value,
    double? minOrderAmount,
    bool? isActive,
  }) {
    return CouponModel(
      code: code ?? this.code,
      isPercentage: isPercentage ?? this.isPercentage,
      value: value ?? this.value,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'isPercentage': isPercentage,
      'value': value,
      'minOrderAmount': minOrderAmount,
      'isActive': isActive,
    };
  }

  factory CouponModel.fromMap(Map<String, dynamic> map) {
    return CouponModel(
      code: map['code'] ?? '',
      isPercentage: map['isPercentage'] ?? true,
      value: (map['value'] ?? 0).toDouble(),
      minOrderAmount: (map['minOrderAmount'] ?? 0).toDouble(),
      isActive: map['isActive'] ?? true,
    );
  }
}
