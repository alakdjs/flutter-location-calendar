import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:test1/const/colors.dart';
import 'package:test1/screen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:video_player/video_player.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // 동영상 컨트롤러 초기화
    _controller = VideoPlayerController.asset('asset/img/background.mp4')
      ..initialize().then((_) {
        setState(() {}); // 초기화 후 UI 업데이트
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 동영상
          Positioned.fill(
            child: _controller.value.isInitialized
                ? VideoPlayer(_controller)
                : Container(color: Colors.black), // 로딩 중 검은색 배경
          ),
          // 로그인 페이지 UI
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                SizedBox(height: 16.0),
                // 로고 이미지 표시
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.15,
                    child: Image.asset(
                      'asset/img/logo_school.jpg',
                    ),
                  ),
                ),

                // 타이틀 문구
                Text(
                  '친구야 뭐하니?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 32.0),
                // 구글 로그인 버튼
                getGoogleLoginButton(context),
                // 카카오 로그인 버튼
                getKakaoLoginButton(context),
              ],
            ),
          ),
          // 화면 하단 앱 개발 정보 관련
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '※ 베타 버전입니다 ※',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(width: 10.0),
                  // 개발자 정보 보기 블럭
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('개발자 정보'),
                            content: Text(
                              '상명대학교\n스마트정보통신공학과\n201921100 최준영\n202021042 강호진\n202221120 송예준',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('확인'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Text(
                        '개발자 정보 보기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 구글 로그인 버튼 UI 생성
  Widget getGoogleLoginButton(BuildContext context) {
    return InkWell(
      onTap: () {
        // 구글 로그인 함수 호출
        onGoogleLoginPress(context);
      },
      child: Card(
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        elevation: 2,
        child: Container(
          padding: EdgeInsets.only(left: 30.0), // 왼쪽에 30픽셀 여백 추가
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('asset/img/google_login.png', height: 40),
              const SizedBox(width: 70),
              Text(
                '구글 로그인',
                style: TextStyle(
                  color: Colors.black, // 텍스트 색상
                  fontSize: 14.0, // 텍스트 크기
                  fontWeight: FontWeight.w500, // 텍스트 두께
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 카카오 로그인 버튼 UI 생성
  Widget getKakaoLoginButton(BuildContext context) {
    return InkWell(
      onTap: () {
        // 카카오 로그인 함수 호출
        signInWithKakao(context);
      },
      child: Card(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        elevation: 2,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.yellow,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('asset/img/kakao_login.png', height: 40),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }

  // 구글 로그인 함수
  Future<void> updateGoogleUserProfile() async {
    var user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // 구글 로그인 사용자 정보 가져오기
        String email = user.email ?? 'Unknown_email';
        String name = user.displayName ?? 'Unknown_name'; // 사용자 이름
        String content = '구글'; // 사용자 종류

        // Firestore에 사용자 정보 저장
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'author': email,
          'name': name, // 구글 사용자 이름
          'content': content, // 사용자 종류
          'createdAt': FieldValue.serverTimestamp(), // 생성 시각
        }, SetOptions(merge: true)); // 기존 데이터가 덮어쓰이지 않도록 merge 사용

        print("Firestore에 구글 사용자 정보 저장 성공!");
      } catch (e) {
        print("Firestore에 구글 사용자 정보 저장 중 오류 발생: $e");
      }
    }
  }
// 구글 로그인 함수
  onGoogleLoginPress(BuildContext context) async {
    GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
    try {
      // 구글 로그인 시도
      GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        // 로그인 실패 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('구글 로그인 실패')),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth = await account.authentication;

      // Firebase 인증 자격 증명 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      // 구글 사용자 정보를 Firestore에 저장
      await updateGoogleUserProfile();

      // 성공 시 홈 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } catch (error) {
      // 로그인 중 에러 발생 시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('구글 로그인 실패')),
      );
    }
  }
  // 홈 화면으로 이동
  void navigateToMainPage(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }

  // 카카오 계정으로 로그인 함수
  Future<void> signInWithKakao(BuildContext context) async {
    try {
      // 카카오 계정으로 로그인 시도
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();

      print('value from kakao: $token');

      // Firebase 인증 연동
      await _firebaseLoginWithKakao(token);

      // 로그인 후 Firestore 데이터 초기화
      await initializeKakaoUserData();
      navigateToMainPage(context);
      print('카카오 계정으로 로그인 성공');

      // 카카오 로그인 후 사용자 정보 가져오기
      kakao.User user = await UserApi.instance.me();
      print('Kakao Email: ${user.kakaoAccount?.email}');
    } catch (error) {
      print('카카오 계정으로 로그인 실패: $error');
    }
  }

// Firebase에 카카오 로그인 정보 연동
  Future<void> _firebaseLoginWithKakao(OAuthToken token) async {
    try {
      // Firebase OAuthProvider 생성
      var provider = OAuthProvider("oidc.test1");

      // Firebase 인증 정보 생성
      var credential = provider.credential(
        idToken: token.idToken,
        accessToken: token.accessToken,
      );

      // Firebase Auth로 로그인
      var result = await FirebaseAuth.instance.signInWithCredential(credential);

      // 로그인 후 Firebase 인증 상태 확인
      firebase_auth.User? user = result.user;
      if (user != null) {
        print('Firebase 로그인 성공: ${user.email}');

        // Firebase에서 uid 확인
        if (user.uid == "-") {
          print('Firebase uid가 잘못 설정되어 있습니다. 새로운 사용자를 생성합니다.');

          // 새로운 사용자로 등록하는 로직
          await _createNewFirebaseUser(user);
        } else {
          print('Firebase uid: ${user.uid}');
        }

        // 카카오에서 이메일 정보 가져오기
        kakao.User kakaoUser = await UserApi.instance.me();
        String? kakaoEmail = kakaoUser.kakaoAccount?.email;

        // 이메일 정보가 없으면 카카오에서 이메일을 가져와 Firebase 사용자 정보에 업데이트
        if (user.email == null || user.email!.isEmpty) {
          if (kakaoEmail != null && kakaoEmail.isNotEmpty) {
            await user.verifyBeforeUpdateEmail(kakaoEmail);
            print('Firebase 이메일 업데이트: $kakaoEmail');
          }
        }
      } else {
        print('Firebase 로그인 실패1: 인증된 사용자 없음');
      }

      // Firebase 상태 확인을 위한 로그 추가
      firebase_auth.User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        print('현재 Firebase 사용자: ${currentUser.email}');
      } else {
        print('현재 Firebase 사용자 정보가 없습니다.');
      }
    } catch (error) {
      print('Firebase 로그인 실패2: $error');
    }
  }

// 새로운 Firebase 사용자 등록
  Future<void> _createNewFirebaseUser(firebase_auth.User user) async {
    try {
      // Firebase에 새로운 사용자 정보 등록
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'displayName': user.displayName ?? 'Unknown_name',  // Firebase 인증에서 제공하는 displayName
      }, SetOptions(merge: true));

      print('새로운 Firebase 사용자 등록 완료: ${user.email}');
    } catch (error) {
      print('새로운 사용자 등록 실패: $error');
    }
  }

// 카카오 사용자 정보 Firestore에 초기화
  Future<void> initializeKakaoUserData() async {
    try {
      // 카카오 사용자 정보 가져오기
      kakao.User user = await UserApi.instance.me();


      // Firestore에 사용자 정보 저장(카카오)
      await FirebaseFirestore.instance.collection('users').doc(user.id.toString()).set({
        'author': user.kakaoAccount?.email ?? 'Unknown_email',
        'name': user.kakaoAccount?.profile?.nickname ?? 'Unknown_name', // 이름
        'content': '카카오', // 사용자 종류
        'createdAt': FieldValue.serverTimestamp(), // 생성 시각
      }, SetOptions(merge: true)); // 기존 데이터 덮어쓰지 않도록 merge 사용

      // 카카오 프로필 정보 디버깅
      print('카카오 프로필 정보: ${user.kakaoAccount?.profile?.profileImageUrl}');

      print('Firestore에 사용자 정보 저장 성공');
    } catch (error) {
      print('사용자 정보 초기화 실패: $error');
    }
  }

  Future<void> requestKakaoPermissions() async {
    try {
      // 카카오 사용자 정보 요청
      kakao.User user = await UserApi.instance.me();
      List<String> optionalScopes = [];

      // 이메일, 닉네임은 필수 항목: 동의되지 않았으면 에러 처리
      if (user.kakaoAccount?.email == null || user.kakaoAccount?.profile?.nickname == null) {
        throw Exception('필수 동의 항목(이메일 또는 닉네임)이 누락되었습니다. 카카오 설정을 확인하세요.');
      }

      // 선택 항목 동의 요청 (프로필 사진은 더 이상 필요하지 않음)
      if (user.kakaoAccount?.profileNeedsAgreement == true) {
        optionalScopes.add('profile');
      }

      // 선택 동의 후 사용자 정보 재요청
      if (optionalScopes.isNotEmpty) {
        print('선택 동의 항목 요청: $optionalScopes');

        // 추가 동의 요청
        OAuthToken token = await UserApi.instance.loginWithNewScopes(optionalScopes);

        // 동의 완료된 스코프 확인
        print('선택 동의 완료: ${token.scopes}');

        // 선택 동의 후 사용자 정보 재요청
        user = await UserApi.instance.me();
      }

      // 사용자 정보 Firestore에 업데이트 (이미지 관련 필드 제외)
      await FirebaseFirestore.instance.collection('users').doc(user.id.toString()).set({
        'email': user.kakaoAccount?.email ?? 'Unknown_email', // 이메일 (필수)
        'name': user.kakaoAccount?.profile?.nickname ?? 'Unknown_name', // 닉네임 (필수)
      }, SetOptions(merge: true));

      print('Firestore에 사용자 정보 업데이트 성공: ${user.kakaoAccount?.email}');
    } catch (error) {
      // 에러 처리
      print('카카오 권한 요청 실패: $error');
    }
  }


}
