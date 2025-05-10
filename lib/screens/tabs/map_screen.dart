// lib/screens/tabs/map_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
// 프로젝트 구조에 맞게 모델 및 위젯 경로 확인 필요
import '../../models/tourist_spot_model.dart';
import '../../widgets/tourist_spot_card.dart';
import '../../models/spot_detail_model.dart'; // *** SpotDetailModel 임포트 추가
import '../../firebase/firestoreManager.dart';

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

  late UserState userinfo;

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

    userinfo = mainUserInfo;

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

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // resizeToAvoidBottomInset: false, // 키보드가 올라올 때 화면 resize 방지 (선택 사항)
      body: Stack(
        children: [
          // 1. Google Map 배경
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              // Completer가 완료되지 않았을 때만 컨트롤러 설정
              if (!_mapControllerCompleter.isCompleted) {
                _mapControllerCompleter.complete(controller);
                // _mapController 변수에도 할당 (선택 사항, completer로도 접근 가능)
                _mapController = controller;
              }
            },
            markers: _markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            // 지도 하단 패딩: 패널 최소 높이 - (Google 로고 등 가려지지 않을 정도의 여유)
            padding: EdgeInsets.only(bottom: _panelMinHeight - 30),
          ),

          // 2. 슬라이딩 패널
          SlidingUpPanel(
            controller: _panelController,
            minHeight: _panelMinHeight,
            maxHeight: _panelMaxHeight,
            parallaxEnabled: true,
            parallaxOffset: 0.1, // 배경 지도 스크롤 속도 비율
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(27.0),
              topRight: Radius.circular(27.0),
            ),
            color: colorScheme.surface, // 패널 배경색
            // *** 중요: 패널 위치 변경 시 버튼 위치 업데이트 ***
            onPanelSlide: (double position) {
              // position: 0.0 (최소 높이) ~ 1.0 (최대 높이)
              // setState를 호출하여 _buttonBottomOffset 업데이트
              if (mounted) { // 위젯이 여전히 트리에 있는지 확인
                setState(() {
                  _buttonBottomOffset = (_panelMinHeight + _buttonMarginAbovePanel) +
                      (_panelMaxHeight - _panelMinHeight) * position;
                });
              }
            },
            // 패널 빌더: 패널 내부 컨텐츠 정의
            panelBuilder: (ScrollController sc) => _buildPanelContent(sc, textTheme),
            // 패널이 닫혔을 때 보이는 핸들 부분
            collapsed: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(27.0),
                  topRight: Radius.circular(27.0),
                ),
              ),
              child: Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          // 3. 상단 검색창 및 프로필 아이콘
          _buildTopSearchBar(context, colorScheme),

          // 4. GPS 및 Write 버튼 (동적 위치)
          // *** 중요: Stack의 자식으로 배치하고 Positioned 사용 ***
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

  // 상단 검색창 위젯 빌더
  Widget _buildTopSearchBar(BuildContext context, ColorScheme colorScheme) {
    final isLightMode = colorScheme.brightness == Brightness.light;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // 검색창
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: isLightMode ? Colors.white : colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(25.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                          decoration: const InputDecoration(
                              hintText: 'Search places...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(bottom: 8)
                          ),
                          onSubmitted: _handleSearch,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 프로필 아이콘
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
                        backgroundImage: (userinfo != null && userinfo.profileURL != null && userinfo.profileURL.isNotEmpty)
                        // userinfo가 있고 profileURL이 null이 아니며 비어있지 않다면 NetworkImage 사용
                            ? NetworkImage(userinfo.profileURL) as ImageProvider<Object>?
                        // 그렇지 않다면 기본 이미지 (AssetImage 등) 사용 또는 아예 다른 위젯 표시
                            : AssetImage('assets/images/egg.png') as ImageProvider<Object>?,
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
}