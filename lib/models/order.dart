class Order {
  final String id;
  final String buyerName;
  final String buyerPhone;
  final String address;
  final List<String> itemNames;
  final double totalAmount;
  String status; // 'new', 'accepted', 'ready_for_courier', 'delivering', 'completed', 'cancelled'
  String? courierName;

  Order({
    required this.id,
    required this.buyerName,
    required this.buyerPhone,
    required this.address,
    required this.itemNames,
    required this.totalAmount,
    this.status = 'new',
    this.courierName,
  });
}