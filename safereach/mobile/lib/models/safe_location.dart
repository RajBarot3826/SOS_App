/// Safe Location Model
library;

class SafeLocation {
  final String id;
  final String name;
  final String type; // home, college, hostel, classroom, custom
  final double latitude;
  final double longitude;
  final String? address;
  final String? building;
  final String? floor;
  final String? room;
  final String? qrCode;

  const SafeLocation({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.address,
    this.building,
    this.floor,
    this.room,
    this.qrCode,
  });

  String get displayName {
    final parts = <String>[name];
    if (building != null) parts.add(building!);
    if (floor != null) parts.add('Floor $floor');
    if (room != null) parts.add('Room $room');
    return parts.join(', ');
  }

  String get googleMapsUrl =>
      'https://maps.google.com/?q=$latitude,$longitude';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'building': building,
        'floor': floor,
        'room': room,
        'qrCode': qrCode,
      };

  factory SafeLocation.fromJson(Map<String, dynamic> json) {
    return SafeLocation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'custom',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['address'],
      building: json['building'],
      floor: json['floor'],
      room: json['room'],
      qrCode: json['qrCode'],
    );
  }

  SafeLocation copyWith({
    String? id,
    String? name,
    String? type,
    double? latitude,
    double? longitude,
    String? address,
    String? building,
    String? floor,
    String? room,
    String? qrCode,
  }) {
    return SafeLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      room: room ?? this.room,
      qrCode: qrCode ?? this.qrCode,
    );
  }
}
