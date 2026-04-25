class PredefinedReasonData {
  final String id;
  final String returnReason;
  final String message;
  final String image;

  PredefinedReasonData({
    required this.id,
    required this.returnReason,
    required this.message,
    required this.image,
  });

  factory PredefinedReasonData.fromJson(Map<String, dynamic> json) {
    return PredefinedReasonData(
      id: json['id'].toString(),
      returnReason: json['return_reason'].toString(),
      message: json['message'].toString(),
      image: json['image'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'return_reason': returnReason,
      'message': message,
      'image': image,
    };
  }

  @override
  String toString() {
    return 'TestData(id: $id, return_reason: $returnReason,message: $message, image: $image )';
  }
}
