class Review {
  final String orderId;
  final String reviewerName;
  final String targetName;
  final String targetRole; // 'seller' или 'courier'
  final int rating;
  final String comment;

  Review({
    required this.orderId,
    required this.reviewerName,
    required this.targetName,
    required this.targetRole,
    required this.rating,
    this.comment = '',
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'reviewerName': reviewerName,
        'targetName': targetName,
        'targetRole': targetRole,
        'rating': rating,
        'comment': comment,
      };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        orderId: json['orderId'],
        reviewerName: json['reviewerName'],
        targetName: json['targetName'],
        targetRole: json['targetRole'],
        rating: json['rating'],
        comment: json['comment'] ?? '',
      );
}