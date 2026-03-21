class BookingModel {
  final String id;
  final String userId;
  final String roomId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int adults;
  final int children;
  final double totalPrice;
  final String status;
  final String? specialRequests;
  final String guestName;
  final String guestEmail;
  final String? guestPhone;
  final DateTime createdAt;
  final Map<String, dynamic>? room;

  BookingModel({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.checkIn,
    required this.checkOut,
    required this.adults,
    required this.children,
    required this.totalPrice,
    required this.status,
    this.specialRequests,
    required this.guestName,
    required this.guestEmail,
    this.guestPhone,
    required this.createdAt,
    this.room,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        id: json['id'],
        userId: json['user_id'],
        roomId: json['room_id'],
        checkIn: DateTime.parse(json['check_in']),
        checkOut: DateTime.parse(json['check_out']),
        adults: json['adults'],
        children: json['children'],
        totalPrice: (json['total_price'] as num).toDouble(),
        status: json['status'],
        specialRequests: json['special_requests'],
        guestName: json['guest_name'],
        guestEmail: json['guest_email'],
        guestPhone: json['guest_phone'],
        createdAt: DateTime.parse(json['created_at']),
        room: json['rooms'],
      );

  int get nights => checkOut.difference(checkIn).inDays;
}