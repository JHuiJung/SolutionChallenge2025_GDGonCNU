import 'spot_detail_model.dart';

// lib/models/tourist_spot_model.dart
class TouristSpotModel {
  final String id;
  final String name;
  final String location; // 예: "Seoul, Korea"
  final String imageUrl;
  final String photographerName; // 예: "seulgi" (태그용)
  // final LatLng coordinates; // 실제 지도 연동 시 위경도 필요

  TouristSpotModel({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.photographerName,
    // required this.coordinates,
  });
}

// --- 임시 더미 데이터 생성 함수 ---
List<TouristSpotModel> getDummyTouristSpots() {
  return List.generate(5, (index) => TouristSpotModel(
    id: 'spot_$index',
    name: ['Sensoji Temple', 'Gyeongbok Palace', 'N Seoul Tower', 'Bukchon Hanok Village', 'Myeongdong Street'][index % 5],
    location: 'Seoul, Korea', // 실제로는 각기 다른 위치
    // Unsplash의 서울 관련 랜덤 이미지 사용
    imageUrl: 'https://source.unsplash.com/random/600x800/?seoul,temple,palace,landmark&sig=$index',
    photographerName: ['bruno', 'brian', 'amy', 'charlie', 'david'][index % 5],
    // coordinates: LatLng(37.5665 + (index * 0.01), 126.9780 + (index * 0.01)), // 예시 위경도
  ));
}

List<TouristSpotModel> getTouristSpotsBySpotPostInfo(List<SpotDetailModel> spotDetailModel) {

  List<TouristSpotModel> result = [];

  for(int i = 0 ; i < spotDetailModel.length; ++i)
    {
      TouristSpotModel newModel = TouristSpotModel(
        id: spotDetailModel[i].id,
        name: spotDetailModel[i].name,
        location: spotDetailModel[i].location, // 실제로는 각기 다른 위치
        // Unsplash의 서울 관련 랜덤 이미지 사용
        imageUrl: spotDetailModel[i].imageUrl,
        photographerName: spotDetailModel[i].authorName,
      );

      result.add(newModel);
    }
  /*
  return List.generate(5, (index) => TouristSpotModel(
    id: 'spot_$index',
    name: ['Sensoji Temple', 'Gyeongbok Palace', 'N Seoul Tower', 'Bukchon Hanok Village', 'Myeongdong Street'][index % 5],
    location: 'Seoul, Korea', // 실제로는 각기 다른 위치
    // Unsplash의 서울 관련 랜덤 이미지 사용
    imageUrl: 'https://source.unsplash.com/random/600x800/?seoul,temple,palace,landmark&sig=$index',
    photographerName: ['bruno', 'brian', 'amy', 'charlie', 'david'][index % 5],
    // coordinates: LatLng(37.5665 + (index * 0.01), 126.9780 + (index * 0.01)), // 예시 위경도
  ));*/

  return result;
}