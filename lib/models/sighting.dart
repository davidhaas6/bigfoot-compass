
class Sighting {
  final String creature;
  final num lat; // flatitude
  final num lon; // longitude
  final bool
      estimatedLocation; // whether the lat/lon was provided or imputed (estimated)
  final num id;

  final String? locationDetails;
  final String? reportTitle;
  final String? description;
  final String? classification;
  final String? date;
  final String? season;
  final String? state;
  final String? county;
  final num? moonPhase;
  final num? humidity;

  Sighting(
    this.creature,
    this.lat,
    this.lon,
    this.id,
    this.estimatedLocation, {
    this.locationDetails,
    this.reportTitle,
    this.description,
    this.classification,
    this.date,
    this.season,
    this.state,
    this.county,
    this.moonPhase,
    this.humidity,
  });

  Sighting.fromMap(Map<String, dynamic> sightingMap)
      : this.creature = sightingMap['creature'],
        this.lat = sightingMap['latitude'],
        this.lon = sightingMap['longitude'],
        this.id = sightingMap['number'],
        this.estimatedLocation = sightingMap['loc_estimated'] == 1,
        this.locationDetails = sightingMap['location_details'],
        this.reportTitle = sightingMap['title'],
        this.description = sightingMap['observed'],
        this.classification = sightingMap['classification'],
        this.date = sightingMap['date'],
        this.season = sightingMap['season'],
        this.state = sightingMap['state'],
        this.county = sightingMap['county'],
        this.moonPhase = sightingMap['moon_phase'],
        this.humidity = sightingMap['humidity'];

  Map<String, dynamic> toMap() {
    return {
      'creature': creature,
      'latitude': lat,
      'longitude': lon,
      'number': id,
      'loc_estimated': estimatedLocation,
      'location_details': locationDetails,
      'title': reportTitle,
      'observed': description,
      'classification': classification,
      'date': date,
      'season': season,
      'state': state,
      'county': county,
      'moon_phase': moonPhase,
      'humidity': humidity,
    };
  }

  @override
  String toString() {
    return 'Sighting{creature: $creature, lat: $lat, lon: $lon}';
  }
}
