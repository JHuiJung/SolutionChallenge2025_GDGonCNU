import 'spot_detail_model.dart';

// lib/models/tourist_spot_model.dart
class TouristSpotModel {
  final String id;
  final String name;
  final String location; // e.g. "Seoul, Korea"
  final String imageUrl;
  final String photographerName;
  // final LatLng coordinates;

  TouristSpotModel({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.photographerName,
    // required this.coordinates,
  });
}

// --- Temporary Dummy Data Creation Function ---
List<TouristSpotModel> getDummyTouristSpots() {
  return List.generate(5, (index) => TouristSpotModel(
    id: 'spot_$index',
    name: ['Sensoji Temple', 'Gyeongbok Palace', 'N Seoul Tower', 'Bukchon Hanok Village', 'Myeongdong Street'][index % 5],
    location: 'Seoul, Korea', // Actually different locations
    // Using random Seoul-related images from Unsplash
    imageUrl: 'https://source.unsplash.com/random/600x800/?seoul,temple,palace,landmark&sig=$index',
    photographerName: ['bruno', 'brian', 'amy', 'charlie', 'david'][index % 5],
    // coordinates: LatLng(37.5665 + (index * 0.01), 126.9780 + (index * 0.01)), // Example Lat/Lng
  ));
}

List<TouristSpotModel> getTouristSpotsBySpotPostInfo(List<SpotDetailModel> spotDetailModel) {

  List<TouristSpotModel> result = [];

  for(int i = 0 ; i < spotDetailModel.length; ++i)
  {
    TouristSpotModel newModel = TouristSpotModel(
      id: spotDetailModel[i].id,
      name: spotDetailModel[i].name,
      location: spotDetailModel[i].location, // Actually different locations
      // Using random Seoul-related images from Unsplash
      imageUrl: spotDetailModel[i].imageUrl,
      photographerName: spotDetailModel[i].authorName,
    );

    result.add(newModel);
  }
  /*
  return List.generate(5, (index) => TouristSpotModel(
    id: 'spot_$index',
    name: ['Sensoji Temple', 'Gyeongbok Palace', 'N Seoul Tower', 'Bukchon Hanok Village', 'Myeongdong Street'][index % 5],
    location: 'Seoul, Korea', // Actually different locations
    // Using random Seoul-related images from Unsplash
    imageUrl: 'https://source.unsplash.com/random/600x800/?seoul,temple,palace,landmark&sig=$index',
    photographerName: ['bruno', 'brian', 'amy', 'charlie', 'david'][index % 5],
    // coordinates: LatLng(37.5665 + (index * 0.01), 126.9780 + (index * 0.01)), // Example Lat/Lng
  ));*/

  return result;
}