class Store {
  final String id;
  final String name;
  final bool isCurbside;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final String storeHours;

  Store({
    required this.id,
    required this.name,
    required this.isCurbside,
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    required this.storeHours,
  });

  String get friendlyAddress => '$name\n$address\n$city, $state ${postalCode.substring(0, 5)}';

  factory Store.fromJson(Map<String, dynamic> json, {String? id}) {
    return Store(
      id: id ?? json['id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      storeHours: json['storeHours'],
      city: json['city'],
      postalCode: json['postalCode'],
      phoneNumber: json['phoneNumber'],
      state: json['state'],
      isCurbside: json['isCurbside'],
      address: json['address1'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isCurbside': isCurbside,
    'address1': address,
    'city': city,
    'state': state,
    'postalCode': postalCode,
    'latitude': latitude,
    'longitude': longitude,
    'phoneNumber': phoneNumber,
    'storeHours': storeHours,
  };

  static List<Store> parseStores(Map<String, dynamic> jsonObjects) {
    return jsonObjects.keys
        .map((key) => Store(
              id: key,
              // \u2011 is a non breaking hyphen character which keeps 'H-E-B' as one word when wrapping text on word boundaries.
              name: (jsonObjects[key]['name'] as String)
                  .replaceAll('-', '\u2011'),
              isCurbside: jsonObjects[key]['isCurbside'],
              address: jsonObjects[key]['address1'],
              city: jsonObjects[key]['city'],
              state: jsonObjects[key]['state'],
              postalCode: jsonObjects[key]['postalCode'],
              latitude: jsonObjects[key]['latitude'],
              longitude: jsonObjects[key]['longitude'],
              phoneNumber: jsonObjects[key]['phoneNumber'],
              storeHours: jsonObjects[key]['storeHours'],
            ))
        .toList();
  }
}
