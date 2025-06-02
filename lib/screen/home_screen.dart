import 'package:flutter/material.dart';
import 'package:test1/model/schedule_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test1/component/main_calendar.dart';
import 'package:test1/component/schedule_card.dart';
import 'package:test1/component/today_banner.dart';
import 'package:test1/component/schedule_bottom_sheet.dart';
import 'package:test1/const/colors.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:test1/screen/auth_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:test1/screen/cam_screen.dart';
import 'dart:async';
import 'package:test1/utils/weather_utils.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:test1/screen/colorpicker_screen.dart';
import 'package:test1/component/friend_menu.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  StreamSubscription<Position>? positionStream;
  late GoogleMapController _mapController;
  late Timer locationUpdateTimer;
  Marker? selectedMarker; // 선택된 마커 정보를 저장할 변수
  Color _currentColor = Colors.blue; // 마커 기본 색상
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
  String? friendRequest;

  //static final LatLng companyLatLng = LatLng(36.8336871, 127.179960);
  static Marker marker = Marker(
    markerId: MarkerId('company'),
    position: LatLng(36.8336871, 127.179960),
    infoWindow: InfoWindow(
      title: '사용자 이름', // 사용자 이름
      snippet: 'userId',
    ),
  );


  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  late TabController _tabController;

  String? temperature;
  String? description;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchWeather(); // 날씨 정보 초기화
    _initializeWeather();

    _initializeLocation();
    _startLocationUpdates();
    firebaseUpdates();
    _subscribeToLocationUpdates();
    _subscribeToUserRequests();
  }

  @override
  void dispose() {
    _mapController.dispose();
    locationUpdateTimer.cancel();
    positionStream?.cancel();
    super.dispose();
  }

  // 날씨 데이터 초기화
  Future<void> _initializeWeather() async {
    final weatherData = await fetchWeather();
    setState(() {
      temperature = weatherData['temperature'];
      description = weatherData['description'];
    });
  }

  // Firestore 위치 데이터 구독
  void _subscribeToLocationUpdates() {
    // 현재 로그인한 사용자의 이메일을 가져옴
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // friend_{user.email} 컬렉션 이름 생성
      String friendCollection =
          'friend_${user.email?.replaceAll('.', '_')}'; // Firestore 컬렉션 이름 변환

      // 해당 friend_{user.email} 컬렉션을 구독
      FirebaseFirestore.instance.collection(friendCollection).snapshots().listen((snapshot) async {
        Map<String, Marker> updatedMarkers = {};
        for (var doc in snapshot.docs) {
          final data = doc.data();
          if (data.containsKey('latitude') && data.containsKey('longitude')) {
            final LatLng position = LatLng(data['latitude'], data['longitude']);
            final String userId = doc.id; // 각 사용자 ID를 마커 ID로 사용
            final String useremail = data['author'];
            final String userName = data['username'];

            // 사용자 ID의 첫 글자를 추출
            final String firstLetter = userName.isNotEmpty ? userName[0] : '?';

            // 커스텀 마커 생성
            final BitmapDescriptor customIcon = await createCustomMarker(userId, firstLetter);

            // 새로운 마커 추가
            updatedMarkers[userId] = Marker(
              markerId: MarkerId(userId),
              position: position,
              infoWindow: InfoWindow(
                title: useremail, // 사용자 이메일 표시
              ),
              icon: customIcon,
              onTap: () {
                // 마커 클릭 시 이벤트 처리
                setState(() {
                  selectedMarker = updatedMarkers[userId]; // 선택된 마커 저장
                });

                // 하단 시트 열기
                _showMarkerDetails(context, updatedMarkers[userId]!);
              },
            );
          }
        }

        // 마커 상태 업데이트 (mounted 체크 추가)
        if (mounted) {
          setState(() {
            _markers = updatedMarkers;
          });
        }
      });
    }
  }

  void _subscribeToUserRequests() {
    // 현재 로그인한 사용자의 이메일을 가져옴
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // user_request 컬렉션 구독
      FirebaseFirestore.instance
          .collection('user_request')
          .snapshots()
          .listen((snapshot) {
        bool requestFound = false;

        // 모든 문서를 순회하여 상태를 동기화
        for (var doc in snapshot.docs) {
          final data = doc.data();

          // receive 필드와 request 필드가 존재하는지 확인
          if (data != null &&
              data.containsKey('receive') &&
              data.containsKey('request')) {
            final String receiveEmail = data['receive'];
            final String requestEmail = data['request'];

            // receive 값이 현재 사용자의 이메일과 같은 경우
            if (receiveEmail == user.email) {
              requestFound = true; // 요청이 존재함을 표시
              setState(() {
                friendRequest = requestEmail; // friendRequest 값 갱신
                print("123"); // 친구 요청 확인
              });

              // 친구 요청 메시지 표시
              Future.delayed(const Duration(seconds: 1), () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      '친구 요청이 왔습니다.',
                      style: TextStyle(color: Colors.white), // 텍스트 색상 변경
                    ),
                    backgroundColor: PRIMARY_COLOR, // 배경색 변경
                    duration: const Duration(seconds: 2),
                  ),
                );
              });
              break; // 요청을 찾았으면 순회 종료
            }
          }
        }

        // 요청을 찾지 못한 경우 friendRequest를 null로 설정
        if (!requestFound) {
          setState(() {
            friendRequest = null;
            print(friendRequest); // 요청 없음 또는 삭제 시 출력
          });
        }
      });
    }
  }

  void saveUserColor(String userId, Color newColor) {
    // userId가 정확한지 확인
    print('Saving color for user: $userId');

    // Color를 ARGB 값으로 변환
    int colorValue = newColor.value;

    // Firestore에 데이터 저장
    FirebaseFirestore.instance
        .collection('users') // Firestore에서 사용자 컬렉션
        .doc(userId) // 정확한 사용자 ID로 문서 지정
        .set({
      'favoriteColor': colorValue,
    }, SetOptions(merge: true)) // 기존 데이터에 덮어쓰지 않도록 merge: true 사용
        .then((_) {
      print('Color saved successfully for user: $userId');
    }).catchError((error) {
      print('Failed to save color: $error');
    });
  }

  bool isLoading = true; // 초기 상태: 로딩 중
  LatLng _initialPosition = LatLng(37.7749, -122.4194); // 기본 위치값
  Map<String, Marker> _markers = {}; // 사용자별 마커 저장

  // 위치 초기화 함수
  Future<void> _initializeLocation() async {
    setState(() {
      isLoading = true; // 위치 로딩 시작 시 로딩 상태로 변경
    });

    LatLng? userLocation = await getUserLocation();

    setState(() {
      if (userLocation != null) {
        print('사용자 초기 위치 설정: $userLocation');
        _initialPosition = userLocation;
      } else {
        print('사용자 위치를 가져오는 데 실패했습니다. 기본 위치를 사용합니다.');
      }
      isLoading = false; // 위치 로딩 완료 후 로딩 상태 종료
    });
  }

  Future<LatLng?> getUserLocation() async {
    // 위치 서비스 활성화 확인
    bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      print("위치 서비스가 비활성화되었습니다.");
      return null;
    }

    // 위치 권한 확인 및 요청
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("위치 권한이 거부되었습니다.");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("위치 권한이 영구적으로 거부되었습니다.");
      return null;
    }

    // 현재 위치 가져오기
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high, // 최신 방식에 맞게 수정
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print("위치를 가져오는 중 오류 발생: $e");
      return null;
    }
  }

  void _startLocationUpdates() {
    // 위치 스트림 수신
    positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10m 이상 이동 시 업데이트
      ),
    ).listen((Position position) async {
      LatLng newPosition = LatLng(position.latitude, position.longitude);
      _mapController.animateCamera(CameraUpdate.newLatLng(newPosition));

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          String friendCollection =
              'friend_${user.email?.replaceAll('.', '_')}'; // Firestore 컬렉션 이름 변환

          // 위치 데이터 생성
          Map<String, dynamic> locationData = {
            'latitude': newPosition.latitude,
            'longitude': newPosition.longitude,
          };

          // Firestore에서 모든 'friend_'로 시작하는 컬렉션을 대상으로 작업 수행
          QuerySnapshot friendCollections = await FirebaseFirestore.instance
              .collectionGroup('friend_')
              .where('author', isEqualTo: user.email)
              .get();

          // 모든 'friend_' 컬렉션에서 author가 일치하는 문서를 업데이트
          for (QueryDocumentSnapshot doc in friendCollections.docs) {
            await doc.reference.set(locationData, SetOptions(merge: true));
          }

          // 현재 사용자 위치를 friendCollection에 업데이트
          QuerySnapshot userDocs = await FirebaseFirestore.instance
              .collection(friendCollection)
              .where('author', isEqualTo: user.email)
              .get();

          if (userDocs.docs.isNotEmpty) {
            // 기존 문서 업데이트
            for (QueryDocumentSnapshot doc in userDocs.docs) {
              await doc.reference.set(locationData, SetOptions(merge: true));
            }
          } else {
            // 문서가 없으면 새 문서 생성
            locationData['author'] = user.email;
            await FirebaseFirestore.instance
                .collection(friendCollection)
                .add(locationData);
          }

          print("Firestore에 위치가 업데이트되었습니다.");
        } catch (e) {
          print("Firestore 업데이트 중 오류 발생: $e");
        }
      }
    });
  }


  void onDaySelected(
      DateTime selectedDate, DateTime focusedDate, BuildContext context) {
    setState(() {
      this.selectedDate = selectedDate;
    });
  }

  //10초마다 firebase 업데이트
  void firebaseUpdates() {
    locationUpdateTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      try {
        // 사용자의 현재 위치를 가져옴
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high, // 높은 정확도로 위치 가져오기
          ),
        );

        LatLng userLocation = LatLng(position.latitude, position.longitude);

        // Firestore에 업로드
        final user = FirebaseAuth.instance.currentUser;
        List<String> friendCollections = []; // 동적으로 생성할 리스트 초기화

        if (user != null) {
          String userEmail = user.email!.replaceAll('.', '_'); // 사용자 이메일 변환

          // 'users' 컬렉션에서 사용자 문서 가져오기
          QuerySnapshot userQuery = await FirebaseFirestore.instance
              .collection('users')
              .where('author', isEqualTo: user.email)
              .limit(1)
              .get();

          if (userQuery.docs.isNotEmpty) {
            QueryDocumentSnapshot userDoc = userQuery.docs.first; // 사용자 문서
            String username = userDoc['name']; // username 값 추출
            String userDocId = userDoc.id; // 사용자 문서 ID 가져오기
            print('사용자의 문서 ID: $userDocId');

            Map<String, dynamic> data = {
              'author': user.email,
              'latitude': userLocation.latitude,
              'longitude': userLocation.longitude,
              'username': username,
            };

            try {
              // Firestore의 users 컬렉션에서 모든 문서 가져오기
              QuerySnapshot usersSnapshot =
              await FirebaseFirestore.instance.collection('users').get();

              for (var userDoc in usersSnapshot.docs) {
                // 각 문서의 `author` 값 가져오기
                String author = userDoc['author'];

                // author의 "."을 "_"로 바꾸고, 앞에 "friend_"를 붙임
                String friendCollectionName =
                    'friend_${author.replaceAll('.', '_')}';

                // 리스트에 추가
                friendCollections.add(friendCollectionName);
              }

              print("Friend Collections: $friendCollections");
            } catch (e) {
              print("Error fetching author values: $e");
            }

            // 각 컬렉션의 문서 업데이트
            for (String collectionName in friendCollections) {
              QuerySnapshot friendDocs = await FirebaseFirestore.instance
                  .collection(collectionName)
                  .where('author', isEqualTo: user.email)
                  .get();

              if (friendDocs.docs.isNotEmpty) {
                for (QueryDocumentSnapshot doc in friendDocs.docs) {
                  print("업데이트 대상 문서: ${doc.id} in $collectionName");
                  await doc.reference.set(
                    data,
                    SetOptions(merge: true),
                  );
                }
              } else {
                print("$collectionName 컬렉션에 해당 문서가 없습니다.");
              }
            }

            // 현재 사용자의 개인 friendCollection에도 업데이트
            String personalCollection = 'friend_$userEmail';
            await FirebaseFirestore.instance
                .collection(personalCollection)
                .doc(userDocId) // users 컬렉션의 문서 ID 사용
                .set(
              data,
              SetOptions(merge: true),
            );

            print(
                'Firestore 위치 업데이트 완료: 위도: ${userLocation.latitude}, 경도: ${userLocation.longitude}');
            print(
                '-----------------------------------------------------------------------------------------------------------------------------');
          } else {
            print('users 컬렉션에서 해당 사용자 문서를 찾을 수 없습니다.');
          }
        }
      } catch (e) {
        print('위치 업데이트 실패: $e');
      }
    });
  }


  // user마다 마커의 색상을 변경하는 함수
  Future<Color> fetchUserColor(String userId) async {
    try {
      // Firestore에서 해당 userId의 데이터를 가져옵니다.
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        int? colorValue = data['favoriteColor'] as int?;
        if (colorValue != null) {
          return Color(colorValue); // 저장된 색상을 Color로 변환
        }
      }
    } catch (error) {
      print('Failed to fetch color: $error');
    }

    // 기본 색상을 반환 (만약 Firestore에 색상이 없다면)
    return Colors.grey;
  }


  Future<BitmapDescriptor> createCustomMarker(
      String userId, String markerText) async {
    const int size = 150; // 마커 크기
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // 해당 userId에 대한 색상 가져오기
    Color userColor = await fetchUserColor(userId);

    // 사용자 색상으로 원 그리기
    final Paint paint = Paint()..color = userColor;
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2.0,
      paint,
    );

    // 텍스트 스타일 설정
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      text: TextSpan(
        text: markerText,
        style: TextStyle(
          fontSize: size / 3,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // 텍스트를 중앙에 배치
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    // 캔버스 저장
    final ui.Image image =
    await pictureRecorder.endRecording().toImage(size, size);
    final ByteData? byteData =
    await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List imageData = byteData!.buffer.asUint8List();

    // 비트맵 디스크립터 생성
    return BitmapDescriptor.fromBytes(imageData);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppBar(),
      body: Stack(
        children: [
          SafeArea(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(), // 스와이프 비활성화
              children: [
                // 첫 번째 탭: 지도 화면
                Container(
                  color: Colors.white, // 배경색 설정
                  child: isLoading
                      ? Center(child: CircularProgressIndicator()) // 로딩 중이면 로딩 표시
                      : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _initialPosition,
                      zoom: 16,
                    ),
                    myLocationButtonEnabled: true,
                    markers: Set<Marker>.from(_markers.values),
                    // 모든 마커를 지도에 추가
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    onTap: (LatLng position) {
                      // 지도를 탭했을 때 선택 마커 해제
                      setState(() {
                        selectedMarker = null;
                      });
                    },
                  ),
                ),

                // 두 번째 탭: 일정 화면 (일정 추가 버튼 포함)
                Container(
                  color: Colors.white, // 배경색 설정
                  child: Column(
                    children: [
                      MainCalendar(
                        selectedDate: selectedDate,
                        onDaySelected: (selectedDate, focusedDate) =>
                            onDaySelected(selectedDate, focusedDate, context),
                      ),
                      SizedBox(height: 8.0),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('schedule')
                            .where(
                          'date',
                          isEqualTo:
                          '${selectedDate.year}${selectedDate.month.toString().padLeft(2, "0")}${selectedDate.day.toString().padLeft(2, "0")}',
                        )
                            .where('author',
                            isEqualTo: FirebaseAuth.instance.currentUser!.email)
                            .snapshots(),
                        builder: (context, snapshot) {
                          return TodayBanner(
                            selectedDate: selectedDate,
                            count: snapshot.data?.docs.length ?? 0,
                          );
                        },
                      ),
                      SizedBox(height: 8.0),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('schedule')
                              .where(
                            'date',
                            isEqualTo:
                            '${selectedDate.year}${selectedDate.month.toString().padLeft(2, "0")}${selectedDate.day.toString().padLeft(2, "0")}',
                          )
                              .where('author',
                              isEqualTo: FirebaseAuth.instance.currentUser!.email)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(child: Text('일정 정보를 가져오지 못했습니다.'));
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container();
                            }

                            final schedules = snapshot.data!.docs
                                .map((QueryDocumentSnapshot e) =>
                                ScheduleModel.fromJson(
                                    json: (e.data() as Map<String, dynamic>)))
                                .toList();

                            return ListView.builder(
                              itemCount: schedules.length,
                              itemBuilder: (context, index) {
                                final schedule = schedules[index];
                                return Dismissible(
                                  key: ObjectKey(schedule.id),
                                  direction: DismissDirection.startToEnd,
                                  onDismissed: (DismissDirection direction) {
                                    FirebaseFirestore.instance
                                        .collection('schedule')
                                        .doc(schedule.id)
                                        .delete();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 8.0),
                                    child: ScheduleCard(
                                      id: schedule.id,
                                      startTime: schedule.startTime,
                                      endTime: schedule.endTime,
                                      content: schedule.content,
                                      date: schedule.date,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: FloatingActionButton(
                          backgroundColor: PRIMARY_COLOR,
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isDismissible: true,
                              isScrollControlled: true,
                              builder: (_) => ScheduleBottomSheet(
                                selectedDate: selectedDate,
                              ),
                            );
                          },
                          child: Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!isLoading)
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: FriendMenu(request: friendRequest),
            ),
        ],
      ),
    );
  }



  AppBar renderAppBar() {
    final weatherInfo = getWeatherIcon(description);
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Row(
            children: [
              Icon(
                weatherInfo['icon'],
                color: weatherInfo['color'],
                size: 32.0,
              ),
              SizedBox(width: 4),
              Text(
                '$temperature°C\n' '$description',
                style: TextStyle(
                  color: PRIMARY_COLOR,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),

      backgroundColor: Colors.white,
      // 다크모드 제거, 항상 흰색 배경
      actions: [
        IconButton(
          icon: const Icon(Icons.color_lens),
          onPressed: () {
            ColorPickerDialog.open(
              context,
              userId,
              _currentColor,
                  (Color newColor) {
                setState(() {
                  _currentColor = newColor;
                });
                saveUserColor(userId, newColor);
              },
            );
          },
        ),
        GestureDetector(
          onTap: () async {
            bool googleLoggedOut = false;
            bool kakaoLoggedOut = false;

            try {
              // 구글 로그아웃
              await GoogleSignIn().signOut();
              await FirebaseAuth.instance.signOut();
              print('구글 로그아웃 성공');
              googleLoggedOut = true;
            } catch (googleError) {
              print('구글 로그아웃 실패: $googleError');
            }

            try {
              // 카카오 로그아웃
              await UserApi.instance.logout();
              print('카카오 로그아웃 성공, SDK에서 토큰 삭제');
              kakaoLoggedOut = true;
            } catch (kakaoError) {
              print('카카오 로그아웃 실패, SDK에서 토큰 삭제: $kakaoError');
            }

            // 로그아웃 성공 여부에 따라 처리
            if (googleLoggedOut || kakaoLoggedOut) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AuthScreen()),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('로그아웃하여 로그인 화면으로 돌아갑니다.'),
                  backgroundColor: Colors.black,
                ),
              );
            } else {
              // 로그아웃 실패 시 사용자에게 알림 표시
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('로그아웃에 실패했습니다. 다시 시도해주세요.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(
              Icons.logout,
              size: 24.0,
              color: PRIMARY_COLOR, // 로그아웃 아이콘 색상 (필요에 따라 변경 가능)
            ),
          ),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: PRIMARY_COLOR,
        // 활성 탭 텍스트 색상
        unselectedLabelColor: PRIMARY_COLOR,
        // 비활성 탭 텍스트 색상
        indicatorColor: PRIMARY_COLOR,
        // 활성 탭 하단에 표시되는 색상
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold, // 활성 탭 텍스트 굵게
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal, // 비활성 탭 텍스트 얇게
        ),
        tabs: [
          Tab(text: '지도'),
          Tab(text: '일정'),
        ],
      ),
    );
  }
}

void _showMarkerDetails(BuildContext context, Marker marker) async {
  final double modalHeight = 200.0; // BottomSheet 높이
  final currentUser = FirebaseAuth.instance.currentUser;
  final String currentUserEmail = currentUser?.email ?? '';

  // 기본 사용자 이름과 이메일
  String userName = 'Unknown Name'; // 기본 사용자 이름
  String userEmail = 'Unknown Email'; // 기본 사용자 이메일
  print('Initial userName: $userName'); // 기본 사용자 이름 확인
  print('Initial userEmail: $userEmail'); // 기본 사용자 이메일 확인


  // 마커에 연결된 사용자 이메일 가져오기 (마커에 이메일이 저장되어 있다고 가정)
  String markerUserEmail =
      marker.infoWindow.title ?? ''; // 이메일을 title에 저장했다고 가정
  print('Marker user email: $markerUserEmail'); // markerUserEmail 확인

  Color? favoriteColor; // 사용자 favoriteColor 변수

  // 이메일이 존재하면 해당 사용자의 이름을 Firestore에서 가져옵니다.
  if (markerUserEmail.isNotEmpty) {
    userEmail = markerUserEmail; // 사용자 이메일 업데이트
    try {
      // Firestore에서 이메일로 사용자 정보 가져오기
      var userQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('author', isEqualTo: markerUserEmail)
          .get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        var userDoc = userQuerySnapshot.docs.first; // 해당 이메일을 가진 사용자 문서
        print(
            'User found in Firestore: ${userDoc.id}'); // 사용자가 Firestore에 존재하는지 확인
        // 해당 사용자 이름 가져오기
        String fetchedUserName =
            userDoc['name'] ?? ''; // Firestore에서 가져온 사용자 이름
        print(
            'Fetched userName from Firestore: $fetchedUserName'); // Firestore에서 가져온 이름 확인
        if (fetchedUserName.isNotEmpty) {
          userName = fetchedUserName; // 해당 사용자 이름으로 업데이트
        }
        // favoriteColor 필드 가져오기
        int? fetchedFavoriteColor = userDoc['favoriteColor'];
        if (fetchedFavoriteColor != null) {
          favoriteColor = Color(fetchedFavoriteColor); // int 값을 Color로 변환
        }
      } else {
        print('No user found in Firestore with email: $markerUserEmail');
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  print('Final userName: $userName'); // 최종적으로 사용되는 userName 확인
  print('Final userEmail: $userEmail'); // 최종적으로 사용되는 userEmail 확인

  // BottomSheet 띄우기
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (BuildContext context) {
      return Container(
        width: double.infinity,
        height: modalHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.0),
            Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24.0,
                    backgroundColor: favoriteColor ?? Colors.grey, // 배경 색
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      // 첫 글자를 크게 표시
                      style: TextStyle(
                        fontSize: 24.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      userName, // 사용자의 이름 표시
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                (' $userEmail'), // 사용자 이메일 표시
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: Center(
                child: markerUserEmail == currentUserEmail
                    ? SizedBox.shrink() // 현재 사용자의 마커일 경우 버튼 숨김
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // PRIMARY_COLOR로 교체
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CamScreen(), // 영상통화 화면
                      ),
                    );
                  },
                  child: Text('영상 통화'),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

