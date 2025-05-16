import 'dart:async';
import 'dart:math';
import 'dart:io' if (dart.library.html) 'dart:typed_data'; // Conditional import

import 'package:flutter/foundation.dart' show Uint8List, kIsWeb; // Using kIsWeb
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:geocoding/geocoding.dart'; // *** Import geocoding package ***

import '../../models/spot_detail_model.dart';
import '../../models/tourist_spot_model.dart';
import '../../widgets/tourist_spot_card.dart';
import '../../models/spot_detail_model.dart'; // *** Add SpotDetailModel import
import '../../firebase/firestoreManager.dart';
import '../../services/api_service.dart';

// --- Enum to represent image search status ---
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
  List<SpotDetailModel> _allSpotPosts = []; // Store original list of all spot posts

  late UserState userinfo;

  // Initial map position (e.g., Seoul)
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(37.5665, 126.9780),
    zoom: 14.0,
  );

  late Set<Marker> _markers = {
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
    const Marker(
      markerId: MarkerId('marker_3'),
      position: LatLng(37.5685, 126.9760),
    ),
  };

  // Tourist spot data to display in the sliding panel
  List<TouristSpotModel> _touristSpots = [];
  bool _isLoadingSpots = true;

  // Set sliding panel height
  final double _panelMinHeight = 40.0;
  final double _panelMaxHeight = 245.0;

  // State variable for dynamic button bottom offset
  double _buttonBottomOffset = 0;
  final double _buttonMarginAbovePanel = 16.0; // Margin between the button and the top of the panel

  get writeButtonColor => null;
  get writeIconColor => null;


  // --- Modified state variables related to image search ---
  ImageSearchStatus _imageSearchStatus = ImageSearchStatus.none;
  XFile? _pickedImageFile;
  String? _imageSearchFullText; // 'recommendation' from API (body content)
  String? _imageSearchLocationOnly; // 'location' from API (for map movement and filtering)
  String _searchBarHintText = 'Search places or with photo...';

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // *** Initialize userinfo directly in initState ***
    userinfo = mainUserInfo; // Assuming mainUserInfo is available

    _buttonBottomOffset = _panelMinHeight + _buttonMarginAbovePanel;
    _loadAllSpotPosts(); // Now called after userinfo is initialized

    // Markers to display on the map (example)
    for (int i = 0; i < 20; i++) {
      var longtitude = Random().nextDouble()/20 + 37.57;
      var latitude = Random().nextDouble()/20 + 126.97;

      Marker marker = Marker(
        markerId: MarkerId('marker_1'),
        position: LatLng(longtitude, latitude),);

      _markers.add(marker);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- Function to load all spot posts (used as source data for initial load and filtering) ---
  Future<void> _loadAllSpotPosts() async {
    if (!mounted) return;
    setState(() => _isLoadingSpots = true); // Overall loading status
    // userinfo = mainUserInfo; // Initialize UserState if needed

    // Fetch all SpotDetailModel data from actual DB or API.
    // Assuming Firestore's getAllSpotPost() is used here.
    _allSpotPosts = await getAllSpotPost(); // Get all spot posts
    _allSpotPosts.shuffle();

    // Initially display all spots as TouristSpotModel without filtering
    _filterAndDisplayTouristSpots(null); // Pass filterLocation as null

    if (!mounted) return;
    setState(() => _isLoadingSpots = false);
  }

  // --- Function to filter and display the list of tourist spots by specific location or keyword ---
  void _filterAndDisplayTouristSpots(String? filterKeyword) {
    if (!mounted) return;
    setState(() => _isLoadingSpots = true); // Show loading during filtering

    List<SpotDetailModel> filteredSpotPosts;

    print("🥹🥹filterKeyword: $filterKeyword");

    if (filterKeyword != null && filterKeyword.isNotEmpty) {
      // Filter _allSpotPosts using filterKeyword.
      // Here, it checks if the keyword is included in the place name (name) or location.
      // More sophisticated filtering (e.g., description, category, etc.) can also be added.
      filteredSpotPosts = _allSpotPosts.where((spotPost) {
        final keywordLower = filterKeyword.toLowerCase();
        return spotPost.name.toLowerCase().contains(keywordLower) ||
            spotPost.location.toLowerCase().contains(keywordLower);
      }).toList();
    } else {
      // If there is no filter keyword, use all spot posts.
      filteredSpotPosts = List.from(_allSpotPosts);
    }

    // Convert the filtered list of SpotDetailModel to a list of TouristSpotModel.
    _touristSpots = getTouristSpotsBySpotPostInfo(filteredSpotPosts);

    if (mounted) {
      setState(() => _isLoadingSpots = false);
    }
  }


  // --- Search handling function (map movement and spot filtering) ---
  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) return;
    print('Search submitted: $query');
    FocusScope.of(context).unfocus();

    try {
      List<Location> locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        final Location firstLocation = locations.first;
        final LatLng searchedPosition = LatLng(firstLocation.latitude, firstLocation.longitude);
        print('Found location: $searchedPosition');
        _goToLocation(searchedPosition, zoom: 30.0); // Map movement

        if (mounted) {
          setState(() {
            _markers.clear();
            _markers.add(
              Marker(markerId: MarkerId(query), position: searchedPosition, infoWindow: InfoWindow(title: query)),
            );
          });
        }
        // *** Filter tourist spot list by the searched query (place name) ***
        _filterAndDisplayTouristSpots(query);

        // Open sliding panel (optional)
        if (_panelController.isAttached && !_panelController.isPanelOpen) {
          _panelController.open();
        }

      } else {
        print('No location found for: $query');
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location not found for "$query"')));
        // If location is not found, attempt to filter spots by keyword only
        _filterAndDisplayTouristSpots(query);
      }
    } catch (e) {
      print('Error during geocoding for "$query": $e');
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error finding location: ${e.toString()}')));
      // Attempt to filter spots by keyword even if Geocoding error occurs
      _filterAndDisplayTouristSpots(query);
    }
  }


  // // --- Modified function to move to place identified from image search results and display spots ---
  // Future<void> _goToIdentifiedLocationAndShowSpots() async {
  //   if (_imageSearchLocationOnly == null || _imageSearchLocationOnly!.isEmpty) {
  //     if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location information is not available.')));
  //     return;
  //   }
  //
  //   final String placeQuery = _imageSearchLocationOnly!;
  //   print('Attempting to geocode and move to from image: $placeQuery');
  //
  //   try {
  //     List<Location> locations = await locationFromAddress(placeQuery);
  //     if (locations.isNotEmpty) {
  //       final Location firstLocation = locations.first;
  //       final LatLng targetPosition = LatLng(firstLocation.latitude, firstLocation.longitude);
  //
  //       _closeImageSearchUI();
  //       await _goToLocation(targetPosition, zoom: 15.0);
  //       // *** Filter spots by location keyword found from image search ***
  //       _filterAndDisplayTouristSpots(_imageSearchLocationOnly);
  //
  //       if(mounted) {
  //         setState(() {
  //           _markers = {
  //             Marker(markerId: MarkerId(placeQuery), position: targetPosition, infoWindow: InfoWindow(title: placeQuery))
  //           };
  //         });
  //       }
  //
  //       if (_panelController.isAttached && !_panelController.isPanelOpen) {
  //         _panelController.open();
  //       }
  //     } else {
  //       print('Could not geocode location from AI result: $placeQuery');
  //       if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not find map location for "$placeQuery" from AI result.')));
  //       // Even if Geocoding fails, attempt to filter spots using the location keyword provided by AI
  //       _filterAndDisplayTouristSpots(_imageSearchLocationOnly);
  //     }
  //   } catch (e) {
  //     print('Error in _goToIdentifiedLocationAndShowSpots: $e');
  //     if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error processing identified location: ${e.toString()}')));
  //     // Even if an error occurs, attempt to filter spots using the location keyword provided by AI
  //     _filterAndDisplayTouristSpots(_imageSearchLocationOnly);
  //   }
  // }

  // --- 이미지 검색 결과에서 장소로 이동 및 스팟 표시 함수 수정 ---
  Future<void> _goToIdentifiedLocationAndShowSpots() async {
    if (_imageSearchLocationOnly == null || _imageSearchLocationOnly!.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location information is not available.')));
      return;
    }

    final String placeQuery = _imageSearchLocationOnly!;
    print('Attempting to geocode and move to from image: $placeQuery');

    String location = _imageSearchLocationOnly!;

    // 먼저 이미지 검색 UI를 닫고, 지도를 다시 표시하도록 상태 변경
    _closeImageSearchUI();

    // 상태 변경이 반영되어 GoogleMap 위젯이 다시 빌드되고
    // 네이티브 지도가 초기화될 시간을 벌기 위해 다음 프레임 이후에 지도 이동 로직 실행
    WidgetsBinding.instance.addPostFrameCallback((_) async { // <-- 이 부분을 추가
      try {
        List<Location> locations = await locationFromAddress(placeQuery);
        if (locations.isNotEmpty) {
          final Location firstLocation = locations.first;
          final LatLng targetPosition = LatLng(
              firstLocation.latitude, firstLocation.longitude);

          _goToLocation(targetPosition, zoom: 30.0);

          if (mounted) {
            setState(() {
              _markers = {
                Marker(markerId: MarkerId(placeQuery),
                    position: targetPosition,
                    infoWindow: InfoWindow(title: placeQuery))
              };
            });
          }

          print("🥹imageSearchLocationOnly ${location}");
          _filterAndDisplayTouristSpots(location);

          if (_panelController.isAttached && !_panelController.isPanelOpen) {
            _panelController.open();
          }
        } else {
          print('Could not geocode location from AI result: $placeQuery');
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Could not find map location for "$placeQuery" from AI result.')));
          _filterAndDisplayTouristSpots(_imageSearchLocationOnly);
        }
      } catch (e) {
        print(
            'Error in _goToIdentifiedLocationAndShowSpots (after callback): $e'); // 로그 메시지 수정
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Error processing identified location: ${e.toString()}')));
        _filterAndDisplayTouristSpots(_imageSearchLocationOnly);
      }
    }); // <-- addPostFrameCallback 끝
  }

  // --- Modified function to call write screen and process result ---
  Future<void> _navigateToWriteSpotScreen() async {
    // Function name change
    // Navigate to WriteSpotScreen and wait for the result (result is SpotDetailModel or null)
    final result = await Navigator.pushNamed(
        context, '/write_spot'); // *** Route change ***

    // If the result is a SpotDetailModel object, add it to the list (Temporary: needs conversion to TouristSpotModel)
    if (result != null && result is SpotDetailModel) { // *** Return type change ***
      final newSpotData = result;

      // TODO: Logic needed to convert SpotDetailModel to TouristSpotModel
      // (Or modify to use SpotDetailModel directly in the sliding panel)
      // Temporary conversion (using only necessary fields)
      final newTouristSpot = TouristSpotModel(
        id: newSpotData.id,
        name: newSpotData.name,
        location: newSpotData.location,
        imageUrl: newSpotData.imageUrl,
        photographerName: newSpotData.authorName, // Temporarily use authorName
      );

      // Update state to add to the sliding panel list (add to the front)
      setState(() {
        _touristSpots.insert(0, newTouristSpot);
      });
      print('New spot added to list: ${newSpotData.name}');
    } else {
      print('Writing spot cancelled or failed.');
    }
  }

  // --- End of function modifications ---

  // Tourist spot data loading function (example)
  Future<void> _loadTouristSpots({String? filterLocation}) async {
    userinfo = mainUserInfo;

    // Check if the widget is mounted before calling setState (optional but safe)
    if (!mounted) return;
    setState(() => _isLoadingSpots = true);
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading
    // Load dummy data
    //_touristSpots = getDummyTouristSpots();

    List<SpotDetailModel> spotDetailModels = await getAllSpotPost();
    _touristSpots = getTouristSpotsBySpotPostInfo(spotDetailModels);
    if (!mounted) return;
    setState(() => _isLoadingSpots = false);
  }

  // Map movement function (example)
  /*Future<void> _goToLocation(LatLng position) async {
    // Check if mapController is initialized
    if (_mapController == null) {
      final GoogleMapController controller = await _mapControllerCompleter.future;
      _mapController = controller;
    }
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 15.0),
    ));
  }*/

  Future<void> _goToLocation(LatLng position, {double zoom = 30.0}) async {
    // Add zoom parameter
    final GoogleMapController controller = await _mapControllerCompleter.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: zoom),
    ));
  }

  // Go to current location function (Placeholder)
  void _goToCurrentLocation() {
    print('GPS button pressed - Go to current location (Not implemented)');
    // _goToLocation(const LatLng(37.5665, 126.9780)); // Example: Seoul City Hall
  }

  // // Search handling function (Placeholder)
  // void _handleSearch(String query) {
  //   print('Search submitted: $query');
  //   FocusScope.of(context).unfocus();
  //   // _goToLocation(const LatLng(37.5512, 126.9882)); // Example: Namsan Tower
  // }



  Future<void> _pickImageAndSearch(ImageSource source) async {
    if (!mounted) return;
    setState(() {
      _imageSearchStatus = ImageSearchStatus.picking;
      _searchBarHintText = 'Selecting image...';
      _imageSearchFullText = null;
      _imageSearchLocationOnly = null;
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
        _callLocatePhotoApi(pickedFile);
      } else {
        if (!mounted) setState(() { _imageSearchStatus = ImageSearchStatus.none; _searchBarHintText = 'Search places or with photo...'; });
      }
    } catch (e) {
      print("Image picker error: $e");
      if (mounted) setState(() { _imageSearchStatus = ImageSearchStatus.error; _searchBarHintText = 'Error picking image.'; _imageSearchFullText = 'Could not pick image: $e'; });
    }
  }

  // Modify ApiService.locatePhoto call function
  Future<void> _callLocatePhotoApi(XFile imageXFile) async {
    if (!mounted) return;
    try {
      Map<String, String> locationData; // *** Change return type to Map ***
      if (kIsWeb) {
        final Uint8List imageBytes = await imageXFile.readAsBytes();
        locationData = await ApiService.locatePhoto(
          fileBytes: imageBytes, fileName: imageXFile.name, mimeType: imageXFile.mimeType, filePath: '',
        );
      } else {
        locationData = await ApiService.locatePhoto(filePath: imageXFile.path);
      }
      // --- *** Modify key names used in map_screen.dart to match ApiService return keys *** ---
      if (mounted) {
        setState(() {
          _imageSearchFullText = locationData['recommendation'] ?? 'Information not found.'; // 'full_text' -> 'recommendation'
          _imageSearchLocationOnly = locationData['location']; // 'location_only' -> 'location'
          _imageSearchStatus = ImageSearchStatus.found;
          _searchBarHintText = 'Location found!';
          print("🥹location: ${locationData['location']}");
          print("🥹recommendation: ${locationData['recommendation']}");
        });
      }
      // --- End of modification ---
    } catch (e) {
      print("Locate photo API error: $e");
      if (mounted) {
        setState(() {
          _imageSearchStatus = ImageSearchStatus.error;
          _searchBarHintText = 'Error finding location.';
          _imageSearchFullText = 'Failed to find location from image: ${e.toString()}'; // Include details in the error message
          _imageSearchLocationOnly = null;
        });
      }
    }
  }

  void _closeImageSearchUI() {
    if (!mounted) return;
    setState(() {
      _imageSearchStatus = ImageSearchStatus.none;
      _searchBarHintText = 'Search places or with photo...';
      _imageSearchFullText = null;
      _imageSearchLocationOnly = null;
      _pickedImageFile = null;
      _searchController.clear(); // Also clear the search bar
    });
  }


  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme
        .of(context)
        .colorScheme;
    final TextTheme textTheme = Theme
        .of(context)
        .textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map background (only visible when image search UI is not active)
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

          // 2. Sliding Panel (only visible when image search UI is not active)
          if (_imageSearchStatus == ImageSearchStatus.none)
            SlidingUpPanel(
              controller: _panelController,
              minHeight: _panelMinHeight,
              maxHeight: _panelMaxHeight,
              parallaxEnabled: true,
              parallaxOffset: 0.1,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0)),
              color: colorScheme.surface,
              onPanelSlide: (double position) {
                if (mounted) {
                  setState(() {
                    _buttonBottomOffset =
                        (_panelMinHeight + _buttonMarginAbovePanel) +
                            (_panelMaxHeight - _panelMinHeight) * position;
                  });
                }
              },
              panelBuilder: (ScrollController sc) =>
                  _buildPanelContent(sc, textTheme),
              collapsed: Container(decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      topRight: Radius.circular(24.0))),
                  child: Center(child: Container(width: 40,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12))))),
            ),

          // --- 3. Image Search UI (Conditional display) ---
          if (_imageSearchStatus != ImageSearchStatus.none)
            _buildImageSearchUI(context, colorScheme, textTheme),

          // 4. Top Search Bar and Profile Icon (Always displayed)
          _buildTopSearchBar(context, colorScheme), // Change content based on image search status

          // 5. GPS and Write Buttons (only visible when image search UI is not active)
          if (_imageSearchStatus == ImageSearchStatus.none)
            _buildActionButtons(context, colorScheme),
        ],
      ),
    );
  }

  // Sliding panel inner content builder
  Widget _buildPanelContent(ScrollController sc, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 11.0), // Secure space for handle
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel handle (might look cleaner without it)
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
          // Section title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              ' Tourist spots nearby',
              style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 11.0),
          // Horizontal scroll tourist spot list
          SizedBox(
            height: 180, // Adjust to card height
            child: _isLoadingSpots
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              // *** Important: Remove or comment out the controller property ***
              // controller: sc, // If this line exists, horizontal scrolling might not work
              scrollDirection: Axis.horizontal, // Set horizontal scrolling
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


  // --- Top Search Bar widget builder (adds camera button and changes hint based on status) ---
  Widget _buildTopSearchBar(BuildContext context, ColorScheme colorScheme) {
    final isLightMode = colorScheme.brightness == Brightness.light;
    return Positioned(
      top: 0, left: 0, right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Back button (only displayed when image search UI is active)
              if (_imageSearchStatus != ImageSearchStatus.none)
                IconButton(
                  icon: Icon(
                      Icons.arrow_back_ios_new, color: colorScheme.onSurface),
                  onPressed: _closeImageSearchUI, // Close image search UI
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (_imageSearchStatus != ImageSearchStatus.none)
                const SizedBox(width: 8),

              // Search bar
              Expanded(
                child: Container(
                  height: 44, // Search Bar Height
                  decoration: BoxDecoration(
                    color: isLightMode ? Colors.white : colorScheme
                        .surfaceVariant,
                    borderRadius: BorderRadius.circular(25.0),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2))
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
                          decoration: InputDecoration(
                              hintText: _searchBarHintText, // Dynamic hint text
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(bottom: 4)
                          ),
                          onSubmitted: _imageSearchStatus == ImageSearchStatus
                              .none ? _handleSearch : null,
                          // Disable text search during image search
                          enabled: _imageSearchStatus ==
                              ImageSearchStatus.none, // Disable text field during image search
                        ),
                      ),
                      // --- Add Camera Icon Button ---
                      IconButton(
                        icon: Icon(Icons.camera_alt_outlined, color: colorScheme
                            .onSurface.withOpacity(0.7)),
                        onPressed: () {
                          // Show image selection options (Gallery or Camera)
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
                                        _pickImageAndSearch(
                                            ImageSource.gallery);
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
                      const SizedBox(width: 4), // Right margin of button
                      // --- End of Camera Icon Button ---
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Profile icon (hidden when image search UI is active - optional)
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
                      backgroundImage: (userinfo != null &&
                          userinfo.profileURL != null &&
                          userinfo.profileURL.isNotEmpty)
                      // If userinfo exists and profileURL is not null and not empty, use NetworkImage
                          ? NetworkImage(userinfo.profileURL) as ImageProvider<
                          Object>?
                      // Otherwise use default image (AssetImage etc.) or display a different widget entirely
                          : AssetImage(
                          'assets/images/user_profile.jpg') as ImageProvider<
                          Object>?,
                    ),
                    // Profile notification display code
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


  // GPS and Write Button widget builder (dynamic position)
  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    final isLightMode = colorScheme.brightness == Brightness.light;
    final buttonColor = isLightMode ? Colors.white : colorScheme.surfaceVariant;
    final iconColor = colorScheme.onSurface.withOpacity(0.8);

    // *** Important: Use Positioned widget and apply _buttonBottomOffset to the bottom property ***
    return Positioned(
      bottom: _buttonBottomOffset, // Use dynamically calculated value
      left: 16.0,
      child: Row(
        children: [
          // GPS button
          FloatingActionButton.small(
            heroTag: 'fab_gps',
            // Unique Hero tag
            onPressed: _goToCurrentLocation,
            backgroundColor: buttonColor,
            elevation: 3,
            child: Icon(Icons.my_location, color: iconColor),
          ),
          const SizedBox(width: 10),
          // --- Modified Write Button ---
          FloatingActionButton.small( // Use instead of ElevatedButton
            heroTag: 'fab_write',
            onPressed: _navigateToWriteSpotScreen,
            // Call modified function
            backgroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            child: Icon(Icons.edit_outlined, color: writeIconColor),
          ),
        ],
      ),
    );
  }


  // --- Image Search UI builder (Design improvements and top padding adjustment) ---
  Widget _buildImageSearchUI(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    final Color cardBackgroundColor = colorScheme.brightness == Brightness.light
        ? Colors.white
        : colorScheme.surfaceVariant.withOpacity(0.8);
    final Color buttonBackgroundColor = Colors.deepPurple.shade400;
    final Color buttonTextColor = Colors.white;

    // Approximate height calculation of AppBar and search bar (Actual AppBar height + search bar height + top padding)
    // MediaQuery.of(context).padding.top is status bar height
    // kToolbarHeight is the default height of AppBar
    // Need to consider the search bar's height and additional padding
    final double topOffset = MediaQuery.of(context).padding.top + kToolbarHeight + 12.0 + 10.0 + 12.0; // Adjust values
    // (Status Bar) + (AppBar default height) + (Search bar top/bottom padding) + (Search bar height) + (Search bar bottom margin)

    return Positioned.fill(
      child: Container(
        color: colorScheme.background.withOpacity(0.95),
        child: SafeArea(
          bottom: true, top: false,
          child: Padding(
            padding: EdgeInsets.only(top: topOffset),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_imageSearchStatus == ImageSearchStatus.searching)
                          _buildSearchingIndicator(context, colorScheme, textTheme),

                        // *** Display _imageSearchFullText ***
                        if (_imageSearchStatus == ImageSearchStatus.found && _imageSearchFullText != null)
                          _buildFoundResult(context, colorScheme, textTheme, _imageSearchFullText!, cardBackgroundColor),

                        if (_imageSearchStatus == ImageSearchStatus.error)
                          _buildErrorState(context, colorScheme, textTheme, _imageSearchFullText), // Message is also included in fullText on error
                      ],
                    ),
                  ),
                ),
                // Button display condition: Consider enabling only when there is a result or error + location_only information exists
                if ((_imageSearchStatus == ImageSearchStatus.found && _imageSearchLocationOnly != null && _imageSearchLocationOnly!.isNotEmpty) || _imageSearchStatus == ImageSearchStatus.error)
                  _buildExploreButton(context, buttonBackgroundColor, buttonTextColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Searching UI
  Widget _buildSearchingIndicator(BuildContext context, ColorScheme colorScheme,
      TextTheme textTheme) {
    return Center( // Center alignment
      child: Padding(
        padding: const EdgeInsets.only(top: 100), // Top margin
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo (temporary icon)
            // Icon(Icons.travel_explore, size: 50,
            //     color: colorScheme.primary.withOpacity(0.7)),
            Image.asset(
              'assets/images/egg.png', // Path to egg.png image
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Text(
                'Please wait for a moment...\nGemini is searching for the place',
                style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.8))
                ,textAlign: TextAlign.center
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  // UI when search result is found
  Widget _buildFoundResult(BuildContext context, ColorScheme colorScheme,
      TextTheme textTheme, String resultText, Color cardBackgroundColor) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [ // Subtle shadow effect (optional)
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI icon (design reference)
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.deepPurple.shade100.withOpacity(0.7),
                child: Icon(Icons.auto_awesome, size: 14,
                    color: Colors.deepPurple.shade700),
              ),
              const SizedBox(width: 8),
              // Text( // Add text like "AI Response" if needed
              //   'Information by AI',
              //   style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
              // ),
            ],
          ),
          const SizedBox(height: 12),
          // API result text
          Text(
            resultText, // Location information from API (or Gemini response)
            style: textTheme.bodyLarge?.copyWith(height: 1.5), // Line spacing
          ),
        ],
      ),
    );
  }

  // UI on error
  Widget _buildErrorState(BuildContext context, ColorScheme colorScheme,
      TextTheme textTheme, String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 50),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Failed to get information from the image.',
              style: textTheme.titleMedium?.copyWith(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Bottom "Explore the place" button
  Widget _buildExploreButton(BuildContext context, Color backgroundColor,
      Color textColor) {
    return Container( // Set padding and background using a Container wrapping the button
      width: double.infinity, // Maximize width
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      // Can apply background color directly to the button, or to the Container to include padding
      // color: Theme.of(context).colorScheme.surface, // Match screen background color or
      decoration: BoxDecoration( // Separator line effect at the top of the button area (optional)
        border: Border(top: BorderSide(color: Theme
            .of(context)
            .dividerColor
            .withOpacity(0.2), width: 1)),
        color: Theme
            .of(context)
            .colorScheme
            .background, // Match SafeArea background
      ),
      child: ElevatedButton(
        onPressed: _goToIdentifiedLocationAndShowSpots, //1111111111111
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          // Adjust button height
          textStyle: Theme
              .of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Corner radius
          ),
          elevation: 2, // Subtle shadow
        ),
        child: const Text('Explore this place'),
      ),
    );
  }
}