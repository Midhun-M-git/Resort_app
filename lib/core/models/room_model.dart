class RoomModel {
  final String id;
  final String roomNumber;
  final String roomType;
  final int floor;
  final double pricePerNight;
  final int maxAdults;
  final int maxChildren;
  final List<String> amenities;
  final String description;
  final List<String> imageUrls;
  final bool isAvailable;
  final DateTime createdAt;

  RoomModel({
    required this.id,
    required this.roomNumber,
    required this.roomType,
    required this.floor,
    required this.pricePerNight,
    required this.maxAdults,
    required this.maxChildren,
    required this.amenities,
    required this.description,
    required this.imageUrls,
    required this.isAvailable,
    required this.createdAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) => RoomModel(
        id: json['id'],
        roomNumber: json['room_number'],
        roomType: json['room_type'],
        floor: json['floor'],
        pricePerNight: (json['price_per_night'] as num).toDouble(),
        maxAdults: json['max_adults'],
        maxChildren: json['max_children'],
        amenities: List<String>.from(json['amenities'] ?? []),
        description: json['description'] ?? '',
        imageUrls: List<String>.from(json['image_urls'] ?? []),
        isAvailable: json['is_available'] ?? true,
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'room_number': roomNumber,
        'room_type': roomType,
        'floor': floor,
        'price_per_night': pricePerNight,
        'max_adults': maxAdults,
        'max_children': maxChildren,
        'amenities': amenities,
        'description': description,
        'image_urls': imageUrls,
        'is_available': isAvailable,
      };
}