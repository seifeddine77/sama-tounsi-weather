/// Modèle pour les données de localisation
class LocationData {
  final double latitude;
  final double longitude;
  final String cityName;
  final String country;
  final String? state;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.country,
    this.state,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    print('LocationData.fromJson: Données reçues - $json');
    final cityName = json['name']?.toString() ?? json['cityName']?.toString() ?? '';
    final country = json['country']?.toString() ?? '';
    print('LocationData.fromJson: Ville=$cityName, Pays=$country');
    
    return LocationData(
      latitude: (json['lat'] as num?)?.toDouble() ?? (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['lon'] as num?)?.toDouble() ?? (json['longitude'] as num?)?.toDouble() ?? 0.0,
      cityName: cityName,
      country: country,
      state: json['state']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'cityName': cityName,
      'country': country,
      'state': state,
    };
  }

  @override
  String toString() {
    return state != null ? '$cityName, $state, $country' : '$cityName, $country';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationData &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.cityName == cityName &&
        other.country == country;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^
        longitude.hashCode ^
        cityName.hashCode ^
        country.hashCode;
  }
}
