class ShipmentModel {
  const ShipmentModel({
    required this.id,
    required this.trackingNumber,
    required this.sender,
    required this.receiver,
    required this.destination,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String trackingNumber;
  final String sender;
  final String receiver;
  final String destination;
  final String status;
  final String createdAt;
  final String updatedAt;

  factory ShipmentModel.fromJson(Map<String, dynamic> json) {
    return ShipmentModel(
      id: json['id'] as String,
      trackingNumber: json['trackingNumber'] as String,
      sender: json['sender'] as String,
      receiver: json['receiver'] as String,
      destination: json['destination'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trackingNumber': trackingNumber,
      'sender': sender,
      'receiver': receiver,
      'destination': destination,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'trackingNumber': trackingNumber,
      'sender': sender,
      'receiver': receiver,
      'destination': destination,
      'status': status,
    };
  }

  factory ShipmentModel.forCreate({
    required String trackingNumber,
    required String sender,
    required String receiver,
    required String destination,
    String status = 'pending',
  }) {
    return ShipmentModel(
      id: '',
      trackingNumber: trackingNumber,
      sender: sender,
      receiver: receiver,
      destination: destination,
      status: status,
      createdAt: '',
      updatedAt: '',
    );
  }

  ShipmentModel copyWith({
    String? id,
    String? trackingNumber,
    String? sender,
    String? receiver,
    String? destination,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return ShipmentModel(
      id: id ?? this.id,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      destination: destination ?? this.destination,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
