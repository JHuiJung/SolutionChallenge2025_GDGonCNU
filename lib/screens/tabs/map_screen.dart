// lib/screens/tabs/map_screen.dart
import 'dart:async';
import 'dart:io'; // File 사용 위해 추가
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart'; // 이미지 피커 임포트
import 'package:sliding_up_panel/sliding_up_panel.dart';
// 프로젝트 구조에 맞게 모델 및 위젯 경로 확인 필요
import '../../models/tourist_spot_model.dart';
import '../../widgets/tourist_spot_card.dart';
import '../../models/spot_detail_model.dart'; // *** SpotDetailModel 임포트 추가

// --- 이미지 검색 상태를 나타내는 enum ---
enum ImageSearchStatus { none, picking, searching, found, error }

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  GoogleMapController? _mapController;
  final PanelController _panelController = PanelController();
  final TextEditingController _searchController = TextEditingController();

  // 지도 초기 위치 (예: 서울)
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(37.5665, 126.9780),
    zoom: 13.0,
  );

  // 지도에 표시할 마커 (예시)
  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('marker_1'),
      position: LatLng(37.5700, 126.9790),
    ),
    const Marker(
      markerId: MarkerId('marker_2'),
      position: LatLng(37.5650, 126.9770),
    ),
    const Marker(
      markerId: MarkerId('marker_3'),
      position: LatLng(37.5685, 126.9760),
    ),
  };

  // 슬라이딩 패널에 표시할 관광지 데이터
  List<TouristSpotModel> _touristSpots = [];
  bool _isLoadingSpots = true;

  // 슬라이딩 패널 높이 설정
  final double _panelMinHeight = 40.0;
  final double _panelMaxHeight = 245.0;

  // 버튼의 동적 bottom offset을 위한 상태 변수
  double _buttonBottomOffset = 0;
  final double _buttonMarginAbovePanel = 16.0;

  get writeButtonColor => null;
  get writeIconColor => null; // 버튼과 패널 상단 사이의 여백


  // --- 이미지 검색 관련 상태 변수 ---
  ImageSearchStatus _imageSearchStatus = ImageSearchStatus.none;
  XFile? _pickedImageFile; // 사용자가 선택/촬영한 이미지 파일
  String? _geminiSearchResult; // Gemini 검색 결과 텍스트
  String _searchBarHintText = 'Search places or with picture...'; // 검색창 기본 힌트

  final ImagePicker _picker = ImagePicker();



  @override
  void initState() {
    super.initState();
    // 초기 버튼 위치 설정 (패널 최소 높이 기준)
    // initState에서는 MediaQuery 사용이 안전하지 않을 수 있으므로,
    // 초기값은 고정값으로 설정하고, 빌드 후 또는 onPanelSlide에서 업데이트
    _buttonBottomOffset = _panelMinHeight + _buttonMarginAbovePanel;
    _loadTouristSpots();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- 글쓰기 화면 호출 및 결과 처리 함수 수정 ---
  Future<void> _navigateToWriteSpotScreen() async { // 함수 이름 변경
    // WriteSpotScreen으로 이동하고 결과를 기다림 (결과는 SpotDetailModel 또는 null)
    final result = await Navigator.pushNamed(context, '/write_spot'); // *** 라우트 변경 ***

    // 결과가 SpotDetailModel 객체이면 목록에 추가 (임시: TouristSpotModel로 변환 필요)
    if (result != null && result is SpotDetailModel) { // *** 반환 타입 변경 ***
      final newSpotData = result;

      // TODO: SpotDetailModel을 TouristSpotModel로 변환하는 로직 필요
      // (또는 슬라이딩 패널에서 SpotDetailModel을 직접 사용하도록 수정)
      // 임시 변환 (필요한 필드만 사용)
      final newTouristSpot = TouristSpotModel(
        id: newSpotData.id,
        name: newSpotData.name,
        location: newSpotData.location,
        imageUrl: newSpotData.imageUrl,
        photographerName: newSpotData.authorName, // 임시로 authorName 사용
      );

      // 상태 업데이트하여 슬라이딩 패널 목록에 추가 (맨 앞에 추가)
      setState(() {
        _touristSpots.insert(0, newTouristSpot);
      });
      print('New spot added to list: ${newSpotData.name}');
    } else {
      print('Writing spot cancelled or failed.');
    }
  }
  // --- 함수 수정 끝 ---

  // 관광지 데이터 로드 함수 (예시)
  Future<void> _loadTouristSpots() async {
    // setState 호출 전에 위젯이 마운트되었는지 확인 (선택 사항이지만 안전함)
    if (!mounted) return;
    setState(() => _isLoadingSpots = true);
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading
    // 더미 데이터 로드
    _touristSpots = getDummyTouristSpots();
    if (!mounted) return;
    setState(() => _isLoadingSpots = false);
  }

  // 지도 이동 함수 (예시)
  Future<void> _goToLocation(LatLng position) async {
    // mapController가 초기화되었는지 확인
    if (_mapController == null) {
      final GoogleMapController controller = await _mapControllerCompleter.future;
      _mapController = controller;
    }
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 15.0),
    ));
  }

  // 현재 위치로 이동 함수 (Placeholder)
  void _goToCurrentLocation() {
    print('GPS button pressed - Go to current location (Not implemented)');
    _goToLocation(const LatLng(37.5665, 126.9780)); // 예시: 서울 시청
  }


  // 검색 처리 함수 (Placeholder)
  void _handleSearch(String query) {
    print('Search submitted: $query');
    FocusScope.of(context).unfocus();
    _goToLocation(const LatLng(37.5512, 126.9882)); // 예시: 남산타워
  }



  // --- 이미지 검색 관련 함수 ---
  Future<void> _pickImageAndSearch(ImageSource source) async {
    if (!mounted) return;
    setState(() {
      _imageSearchStatus = ImageSearchStatus.picking;
      _searchBarHintText = 'Selecting image...'; // 검색창 힌트 변경
      _geminiSearchResult = null; // 이전 결과 초기화
      _pickedImageFile = null;
    });

    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        if (!mounted) return;
        setState(() {
          _pickedImageFile = pickedFile;
          _imageSearchStatus = ImageSearchStatus.searching;
          _searchBarHintText = 'Searching image...'; // 검색창 힌트 변경
        });
        // --- Gemini API 호출 (시뮬레이션) ---
        _callGeminiApi(pickedFile);
      } else {
        if (!mounted) return;
        setState(() {
          _imageSearchStatus = ImageSearchStatus.none; // 이미지 선택 취소
          _searchBarHintText = 'Search places or with picture...';
        });
      }
    } catch (e) {
      print("Image picker error: $e");
      if (mounted) {
        setState(() {
          _imageSearchStatus = ImageSearchStatus.error;
          _searchBarHintText = 'Error picking image.';
        });
      }
    }
  }

  // Gemini API 호출 시뮬레이션 함수
  Future<void> _callGeminiApi(XFile imageFile) async {
    // TODO: 실제 Gemini API 연동 로직 구현
    // 1. imageFile을 Gemini API가 요구하는 형식으로 변환 (예: base64, bytes)
    // 2. Gemini API 호출
    // 3. 응답 파싱하여 _geminiSearchResult에 저장

    // 시뮬레이션을 위해 2초 딜레이 후 더미 결과 반환
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // 더미 결과 (실제로는 API 응답 사용)
      final dummyResult = """This is Tokyo Tower, located in Minato City, Tokyo, Japan.
Here are some popular attractions near Tokyo Tower:
* Zojoji Temple: A historic Buddhist temple right next to Tokyo Tower, known for its connection to the Tokugawa shogunate.
* Shiba Park: One of the oldest parks in Japan, offering green spaces and views of Tokyo Tower. Zojoji Temple is located within this park.
* Tokyo Tower Observation Decks: Enjoy panoramic views of Tokyo from the Main Deck (150m) and the Top Deck (250m). On a clear day, you might even see Mount Fuji.
* Foot Town: Located at the base of Tokyo Tower, this complex has various shops, restaurants, and attractions like the Tokyo Tower Aquarium.
* Hamarikyu Gardens: A traditional Japanese garden with a teahouse, ponds, and seasonal flowers, offering a peaceful escape from the city bustle. You can take a water bus from here.
* Mini Cruise in Tokyo Bay: Enjoy views of the Tokyo skyline, including Tokyo Tower and the Rainbow Bridge, from a different perspective.
* Shiodome Miyazaki's Clock: A whimsical and large clock designed by Hayao Miyazaki of Studio Ghibli fame.""";

      setState(() {
        _geminiSearchResult = dummyResult;
        _imageSearchStatus = ImageSearchStatus.found;
        _searchBarHintText = 'Gemini found it!'; // 검색창 힌트 변경
      });
    }
  }

  // 이미지 검색 UI 닫기 (결과 화면에서 뒤로가기 등)
  void _closeImageSearchUI() {
    if (!mounted) return;
    setState(() {
      _imageSearchStatus = ImageSearchStatus.none;
      _searchBarHintText = 'Search places or with picture...';
      _geminiSearchResult = null;
      _pickedImageFile = null;
    });
  }
  // --- 이미지 검색 관련 함수 끝 ---



  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map 배경 (이미지 검색 UI가 활성화되지 않았을 때만 보이도록)
          if (_imageSearchStatus == ImageSearchStatus.none)
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                if (!_mapControllerCompleter.isCompleted) {
                  _mapControllerCompleter.complete(controller);
                  _mapController = controller;
                }
              },
              markers: _markers,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              padding: EdgeInsets.only(bottom: _panelMinHeight - 30),
            ),

          // 2. 슬라이딩 패널 (이미지 검색 UI가 활성화되지 않았을 때만 보이도록)
          if (_imageSearchStatus == ImageSearchStatus.none)
            SlidingUpPanel(
              controller: _panelController,
              minHeight: _panelMinHeight,
              maxHeight: _panelMaxHeight,
              parallaxEnabled: true,
              parallaxOffset: 0.1,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
              color: colorScheme.surface,
              onPanelSlide: (double position) { if (mounted) { setState(() { _buttonBottomOffset = (_panelMinHeight + _buttonMarginAbovePanel) + (_panelMaxHeight - _panelMinHeight) * position; }); } },
              panelBuilder: (ScrollController sc) => _buildPanelContent(sc, textTheme),
              collapsed: Container(decoration: BoxDecoration(color: colorScheme.surface, borderRadius: const BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0))), child: Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12))))),
            ),

          // --- 3. 이미지 검색 UI (조건부 표시) ---
          if (_imageSearchStatus != ImageSearchStatus.none)
            _buildImageSearchUI(context, colorScheme, textTheme),

          // 4. 상단 검색창 및 프로필 아이콘 (항상 표시)
          _buildTopSearchBar(context, colorScheme), // 이미지 검색 상태에 따라 내용 변경

          // 5. GPS 및 Write 버튼 (이미지 검색 UI가 활성화되지 않았을 때만 보이도록)
          if (_imageSearchStatus == ImageSearchStatus.none)
            _buildActionButtons(context, colorScheme),
        ],
      ),
    );
  }

  // 슬라이딩 패널 내부 컨텐츠 빌더
  Widget _buildPanelContent(ScrollController sc, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 11.0), // 핸들 영역 확보
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 패널 핸들 (없는게 깔끔해 보이기도)
          // Center(
          //   child: Container(
          //     width: 40,
          //     height: 5,
          //     margin: const EdgeInsets.only(bottom: 8.0),
          //     decoration: BoxDecoration(
          //       color: Colors.grey[300],
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //   ),
          // ),
          // 섹션 제목
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              ' Tourist spots nearby',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 11.0),
          // 가로 스크롤 관광지 목록
          SizedBox(
            height: 180, // 카드 높이에 맞춰 조절
            child: _isLoadingSpots
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              // *** 중요: controller 속성 제거 또는 주석 처리 ***
              // controller: sc, // 이 줄이 있으면 수평 스크롤이 안될 수 있음
              scrollDirection: Axis.horizontal, // 수평 스크롤 설정
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _touristSpots.length,
              itemBuilder: (context, index) {
                return TouristSpotCard(spot: _touristSpots[index]);
              },
            ),
          ),
        ],
      ),
    );
  }


  // --- 상단 검색창 위젯 빌더 (카메라 버튼 추가 및 상태에 따른 힌트 변경) ---
  Widget _buildTopSearchBar(BuildContext context, ColorScheme colorScheme) {
    final isLightMode = colorScheme.brightness == Brightness.light;
    return Positioned(
      top: 0, left: 0, right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // 뒤로가기 버튼 (이미지 검색 UI 활성화 시에만 표시)
              if (_imageSearchStatus != ImageSearchStatus.none)
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
                  onPressed: _closeImageSearchUI, // 이미지 검색 UI 닫기
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (_imageSearchStatus != ImageSearchStatus.none)
                const SizedBox(width: 8),

              // 검색창
              Expanded(
                child: Container(
                  height: 44, // Search Bar Height
                  decoration: BoxDecoration(
                    color: isLightMode ? Colors.white : colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(25.0),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Icon(Icons.search, color: Colors.grey),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                              hintText: _searchBarHintText, // 동적 힌트 텍스트
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(bottom: 4)
                          ),
                          onSubmitted: _imageSearchStatus == ImageSearchStatus.none ? _handleSearch : null, // 이미지 검색 중에는 텍스트 검색 비활성화
                          enabled: _imageSearchStatus == ImageSearchStatus.none, // 이미지 검색 중에는 텍스트 필드 비활성화
                        ),
                      ),
                      // --- 카메라 아이콘 버튼 추가 ---
                      IconButton(
                        icon: Icon(Icons.camera_alt_outlined, color: colorScheme.onSurface.withOpacity(0.7)),
                        onPressed: () {
                          // 이미지 선택 옵션 보여주기 (갤러리 또는 카메라)
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext bc) {
                              return SafeArea(
                                child: Wrap(
                                  children: <Widget>[
                                    ListTile(
                                      leading: const Icon(Icons.photo_library),
                                      title: const Text('Gallery'),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        _pickImageAndSearch(ImageSource.gallery);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.photo_camera),
                                      title: const Text('Camera'),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        _pickImageAndSearch(ImageSource.camera);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        tooltip: 'Search with image',
                      ),
                      const SizedBox(width: 4), // 버튼 오른쪽 여백
                      // --- 카메라 아이콘 버튼 끝 ---
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 프로필 아이콘 (이미지 검색 UI 활성화 시에는 숨김 - 선택 사항)
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/mypage');
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: const NetworkImage('https://source.unsplash.com/random/100x100/?person&sig=99'),
                    ),
                    // 프로필 알림 표시 코드
                    // Positioned(
                    //   top: -2,
                    //   right: -2,
                    //   child: Container(
                    //     padding: const EdgeInsets.all(5),
                    //     decoration: BoxDecoration(
                    //       color: Colors.tealAccent[400],
                    //       shape: BoxShape.circle,
                    //       border: Border.all(color: colorScheme.surface, width: 1.5),
                    //     ),
                    //     child: const Text(
                    //       '3',
                    //       style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // GPS 및 Write 버튼 위젯 빌더 (동적 위치)
  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    final isLightMode = colorScheme.brightness == Brightness.light;
    final buttonColor = isLightMode ? Colors.white : colorScheme.surfaceVariant;
    final iconColor = colorScheme.onSurface.withOpacity(0.8);

    // *** 중요: Positioned 위젯 사용 및 bottom 속성에 _buttonBottomOffset 적용 ***
    return Positioned(
      bottom: _buttonBottomOffset, // 동적으로 계산된 값 사용
      left: 16.0,
      child: Row(
        children: [
          // GPS 버튼
          FloatingActionButton.small(
            heroTag: 'fab_gps', // 고유 Hero 태그
            onPressed: _goToCurrentLocation,
            backgroundColor: buttonColor,
            elevation: 3,
            child: Icon(Icons.my_location, color: iconColor),
          ),
          const SizedBox(width: 12),
          // --- 수정된 Write 버튼 ---
          FloatingActionButton.small( // ElevatedButton 대신 사용
            heroTag: 'fab_write',
            onPressed: _navigateToWriteSpotScreen, // 수정된 함수 호출
            backgroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            child: Icon(Icons.edit_outlined, color: writeIconColor),
            ),
        ],
      ),
    );
  }


  // --- 이미지 검색 UI 빌더 ---
  Widget _buildImageSearchUI(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Positioned.fill( // 전체 화면을 덮도록
      child: Container(
        color: colorScheme.background, // 배경색
        padding: EdgeInsets.only(top: kToolbarHeight + MediaQuery.of(context).padding.top + 12 + 50 + 12), // AppBar 및 검색창 높이만큼 패딩
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_imageSearchStatus == ImageSearchStatus.searching) ...[
              // 로고 (임시 아이콘)
              Icon(Icons.travel_explore, size: 40, color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Please wait for a moment...',
                style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.8)),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(), // 로딩 인디케이터
            ],
            if (_imageSearchStatus == ImageSearchStatus.found && _geminiSearchResult != null) ...[
              // Gemini 결과 표시
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _geminiSearchResult!,
                    style: textTheme.bodyLarge,
                  ),
                ),
              ),
            ],
            if (_imageSearchStatus == ImageSearchStatus.error) ...[
              Icon(Icons.error_outline, color: colorScheme.error, size: 40),
              const SizedBox(height: 16),
              Text(
                'Failed to get information from the image.',
                style: textTheme.titleMedium?.copyWith(color: colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
} // _MapScreenState 끝