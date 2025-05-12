// lib/screens/tabs/map_screen.dart
import 'dart:async';
import 'dart:io' if (dart.library.html) 'dart:typed_data'; // 조건부 import
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb; // kIsWeb 사용
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../models/spot_detail_model.dart';
import '../../models/tourist_spot_model.dart';
import '../../widgets/tourist_spot_card.dart';
import '../../services/api_service.dart';

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

  // --- 이미지 검색 관련 함수 (ApiService.locatePhoto 연동) ---
  Future<void> _pickImageAndSearch(ImageSource source) async {
    if (!mounted) return;
    setState(() {
      _imageSearchStatus = ImageSearchStatus.picking;
      _searchBarHintText = 'Selecting image...';
      _geminiSearchResult = null;
      _pickedImageFile = null;
    });

    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        if (!mounted) return;
        setState(() {
          _pickedImageFile = pickedFile;
          _imageSearchStatus = ImageSearchStatus.searching;
          _searchBarHintText = 'Searching image...';
        });
        // --- ApiService.locatePhoto 호출 ---
        // *** 수정된 부분: XFile 객체를 직접 전달 ***
        _callLocatePhotoApi(pickedFile);
      } else {
        if (!mounted) return;
        setState(() {
          _imageSearchStatus = ImageSearchStatus.none;
          _searchBarHintText = 'Search places or with picture...';
        });
      }
    } catch (e) {
      print("Image picker error: $e");
      if (mounted) {
        setState(() {
          _imageSearchStatus = ImageSearchStatus.error;
          _searchBarHintText = 'Error picking image.';
          _geminiSearchResult = 'Could not pick image: $e';
        });
      }
    }
  }

  // ApiService.locatePhoto 호출 함수 (플랫폼 분기 처리)
  Future<void> _callLocatePhotoApi(XFile imageXFile) async {
    if (!mounted) return;
    try {
      String locationResult;
      if (kIsWeb) {
        // 웹 환경: 바이트 데이터와 파일명, MIME 타입 전달
        final Uint8List imageBytes = await imageXFile.readAsBytes();
        locationResult = await ApiService.locatePhoto(
          fileBytes: imageBytes,
          fileName: imageXFile.name, // XFile의 name 속성 사용
          mimeType: imageXFile.mimeType, // XFile의 mimeType 속성 사용
          filePath: '', // 웹에서는 filePath 불필요
        );
      } else {
        // 모바일 환경: 파일 경로 전달
        locationResult = await ApiService.locatePhoto(
          filePath: imageXFile.path, // XFile의 path 속성 사용
        );
      }

      if (mounted) {
        setState(() { _geminiSearchResult = locationResult; _imageSearchStatus = ImageSearchStatus.found; _searchBarHintText = 'Location found!'; });
      }
    } catch (e) {
      print("Locate photo API error: $e");
      if (mounted) {
        setState(() { _imageSearchStatus = ImageSearchStatus.error; _searchBarHintText = 'Error finding location.'; _geminiSearchResult = 'Failed to find location from image: $e'; });
      }
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


  // --- 이미지 검색 UI 빌더 (Gemini 결과 대신 API 결과 표시) ---
  Widget _buildImageSearchUI(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Positioned.fill(
      child: Container(
        color: colorScheme.background,
        padding: EdgeInsets.only(top: kToolbarHeight + MediaQuery.of(context).padding.top + 12 + 50 + 12),
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
              const CircularProgressIndicator(),
            ],
            // *** API 결과 표시 (Gemini -> Location) ***
            if (_imageSearchStatus == ImageSearchStatus.found && _geminiSearchResult != null) ...[
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column( // 더 나은 가독성을 위해 Column 사용
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   'Identified Location:', // 제목 추가
                      //   style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      // ),
                      const SizedBox(height: 8),
                      Text(
                        _geminiSearchResult!, // 이제 API의 위치 정보
                        style: textTheme.bodyLarge,
                      ),
                      // TODO: 필요한 경우, 이 위치로 지도 이동 버튼 추가 가능
                    ],
                  ),
                ),
              ),
            ],
            if (_imageSearchStatus == ImageSearchStatus.error) ...[
              Icon(Icons.error_outline, color: colorScheme.error, size: 40),
              const SizedBox(height: 16),
              Text(
                _geminiSearchResult ?? 'Failed to get information from the image.', // 에러 메시지 표시
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