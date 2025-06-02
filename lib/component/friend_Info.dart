import 'package:flutter/material.dart';
import 'package:test1/const/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Widget InfoBox({
  required String email,
}) {
  return FutureBuilder<DocumentSnapshot>(
    // Firestore에서 이메일이 일치하는 유저 데이터를 가져옴
    future: FirebaseFirestore.instance
        .collection('users')
        .where('author', isEqualTo: email) // 'author' 필드가 email과 동일한 문서 필터링
        .limit(1) // 하나의 문서만 가져옴
        .get()
        .then((querySnapshot) => querySnapshot.docs.first), // 첫 번째 문서 가져오기
    builder: (context, snapshot) {
      // 데이터 로딩 중 상태 표시
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      // 데이터가 없거나 에러가 발생한 경우 처리
      if (!snapshot.hasData || snapshot.data == null) {
        return Center(child: Text("No data found"));
      }

      // Firestore 문서에서 데이터 추출
      final userDoc = snapshot.data!;
      final data = userDoc.data() as Map<String, dynamic>; // 데이터를 Map으로 변환
      final int favoriteColor = data.containsKey('favoriteColor')
          ? data['favoriteColor']
          : Colors.yellow.value; // 필드가 없으면 회색으로 설정

      final String name = userDoc['name']; // Firestore에서 가져온 'name'

      // UI 구조는 기존 코드와 동일
      return Container(
        margin: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0), // 맨 위쪽만 여백 추가
        width: 360,
        height: 124,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0), // 바깥쪽 둥근 모서리
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8799B3).withOpacity(0.15), // 바깥쪽 그림자 색상
              blurRadius: 8.0, // 바깥쪽 그림자 흐림
              spreadRadius: 6.0,
              offset: const Offset(4, 4), // 바깥쪽 그림자 위치
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(8.0), // 바깥 테두리와의 간격
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0), // 안쪽 둥근 모서리
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8799B3).withOpacity(0.5), // 그림자 색상
                blurRadius: 4.0, // 흐림 효과
                offset: Offset(-1.5, -1.5), // 안쪽 위-왼쪽 방향으로 그림자 이동
                spreadRadius: -1.0, // 안쪽 그림자 효과
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.8), // 반대 방향 그림자
                blurRadius: 4.0,
                offset: const Offset(2, 2),
                spreadRadius: -2.0,
              ),
            ],
          ),
          child: Center(
            // 가져온 데이터를 UserInfoCard에 전달
            child: UserInfoCard(
              favoritColor: favoriteColor.toString(), // UserInfoCard에 전달할 때 문자열로 변환
              name: name, // Firestore의 name 필드를 전달
              email: email, // email은 그대로 전달
            ),
          ),
        ),
      );
    },
  );
}




//친구 정보, 사진 - InfoBox 안에 들어갈 내용
Widget UserInfoCard({
  required String favoritColor, // favoriteColor를 문자열로 받음
  required String name,
  required String email,
  TextStyle? nameStyle, // 이름 텍스트 스타일
  TextStyle? emailStyle, // 이메일 텍스트 스타일
  AlignmentGeometry alignment = Alignment.centerLeft, // 전체 위치 조정
  EdgeInsetsGeometry padding = const EdgeInsets.all(10), // 전체 여백
}) {
  return Align(
    alignment: alignment, // 전체 카드 위치
    child: Padding(
      padding: padding, // 전체 카드 여백
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 프로필 이미지 대신 색상 원과 텍스트
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: Color(int.parse(favoritColor)), // 문자열을 int로 변환하여 색상 적용
              shape: BoxShape.circle, // 원형 컨테이너
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '', // 이름의 첫 글자
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // 텍스트 색상
                ),
              ),
            ),
          ),
          const SizedBox(width: 10), // 이미지와 텍스트 간 간격
          // 텍스트 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8), // 텍스트 위쪽에 간격 추가
              Text(
                name,
                style: nameStyle ??
                    const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              Text(
                email,
                style: emailStyle ??
                    const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}



//승인 수락/거절 버튼
Widget infoBoxButton({
  required VoidCallback cancleButtonPressed, // 왼쪽 버튼 콜백
  required VoidCallback acceptButtonPressed, // 오른쪽 버튼 콜백
  double buttonSize = 40.0, // 버튼 크기
  Color cancleButtonColor = Colors.redAccent, // 왼쪽 버튼 색상
  Color acceptButtonColor = PRIMARY_COLOR, // 오른쪽 버튼 색상
  double spacing = 12.0, // 버튼 간격
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      // 왼쪽 버튼 (X)
      GestureDetector(
        onTap: cancleButtonPressed,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: cancleButtonColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8799B3).withOpacity(0.4),
                blurRadius: 6.0,
                spreadRadius: 3.0,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.close,
            color: Colors.white,
            size: buttonSize * 0.6, // 아이콘 크기
          ),
        ),
      ),
      SizedBox(width: spacing), // 버튼 간격
      // 오른쪽 버튼 (체크)
      GestureDetector(
        onTap: acceptButtonPressed,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: acceptButtonColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8799B3).withOpacity(0.4),
                blurRadius: 6.0,
                spreadRadius: 3.0,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: buttonSize * 0.6, // 아이콘 크기
          ),
        ),
      ),
    ],
  );
}

//첫번째 페이지 친구 목록
Widget FriendListWidget({
  required String userEmail,
  required VoidCallback rebuildModal,
}) {
  return FutureBuilder(
    future: FirebaseFirestore.instance
        .collection('friend_${userEmail.replaceAll('.', '_')}')
        .get(),
    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return const Center(child: Text('오류가 발생했습니다.'));
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center( // Center로 텍스트를 가운데 정렬
          child: Padding(
            padding: const EdgeInsets.only(top: 190), // 위치 조정
            child: const Text(
              "친구 목록이 없습니다",
              style: TextStyle(
                fontSize: 15.0,
                color: Color(0xFF8799B3), // 색상 조정
              ),
            ),
          ),
        );
      }

      final docs = snapshot.data!.docs;
      final filteredDocs = docs
          .where((doc) => doc['author'] != userEmail)
          .toList();

      return filteredDocs.isNotEmpty
          ? SizedBox(
        height: 300.0, // 원하는 높이 설정
        child: ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final author = filteredDocs[index]['author'];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: InfoBox(
                email: author,
              ),
            );
          },
        ),
      )
          : Padding(
        padding: const EdgeInsets.only(top: 190), // 위치 조정
        child: Align(
          alignment: Alignment.center, // 수평 및 수직 중앙 정렬
          child: const Text(
            "친구가 없습니다",
            style: TextStyle(
              fontSize: 15.0,
              color: Color(0xFF8799B3), // 색상 조정
            ),
          ),
        ),
      );

    },
  );
}



//두번째 페이지 UI
Widget buildFriendAddPage({
  required TextEditingController emailController,
  required VoidCallback onAddButtonPressed,
  required String userEmail,
}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 30.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F5),
                    borderRadius: BorderRadius.circular(50.0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8799B3).withOpacity(0.5),
                        blurRadius: 4.0,
                        offset: const Offset(-2, -2),
                        spreadRadius: -1.0,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 4.0,
                        offset: const Offset(2, 2),
                        spreadRadius: -2.0,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: emailController,
                    cursorColor: const Color(0xFF3C4654),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      hintText: '친구 이메일을 입력',
                      hintStyle: const TextStyle(
                        color: Color(0xFF8799B3),
                        fontSize: 13.0,
                      ),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3C4654),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              GestureDetector(
                onTap: onAddButtonPressed,
                child: Container(
                  width: 35.0,
                  height: 35.0,
                  decoration: BoxDecoration(
                    color: PRIMARY_COLOR,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8799B3).withOpacity(0.4),
                        blurRadius: 8.0,
                        spreadRadius: 2.0,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 0.0), // 입력창과 목록 간의 간격
        FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('user_request')
              .where('request', isEqualTo: userEmail)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('데이터를 가져오는 중 오류가 발생했습니다.'),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 110), // 텍스트 위치 조정
                child: const Text(
                  "친구 신청 중인 유저가 없습니다",
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Color(0xFF8799B3), // 색상 변경
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final email = data['receive'] ?? 'Unknown';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Stack(
                      children: [
                        InfoBox(email: email),
                        Positioned(
                          bottom: 17.0, // 텍스트의 Y축 위치
                          right: 35.0, // 텍스트의 X축 위치
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F5),
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8799B3)
                                      .withOpacity(0.5),
                                  // 그림자 색상
                                  blurRadius: 4.0,
                                  // 흐림 효과
                                  offset: const Offset(-2, -2),
                                  // 안쪽 위-왼쪽 방향으로 그림자 이동
                                  spreadRadius: -1.0, // 안쪽 그림자 효과
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  // 반대 방향 그림자
                                  blurRadius: 4.0,
                                  offset: const Offset(2, 2),
                                  spreadRadius: -2.0,
                                ),
                              ],
                            ),
                            child: Text(
                              "신청 중",
                              style: const TextStyle(
                                fontSize: 12.0,// 텍스트를 두껍게
                                color: Color(0xFF8799B3), // 텍스트 색상
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
            ;
          },
        )
        ,
      ],
    ),
  );
}



//두번째 페이지 + 버튼 누르면 친구 신청기능
Widget FriendAddWidget({
  required BuildContext context,
  required TextEditingController emailController,
  required User? user,
  required VoidCallback rebuildModal, // 리빌드 콜백
}) {
  return buildFriendAddPage(
    emailController: emailController,
    onAddButtonPressed: () async {
      final friendEmail = emailController.text.trim();
      final userEmail = user?.email ?? '';

      if (friendEmail.isEmpty) return;

      // 본인 이메일을 입력했는지 체크
      if (friendEmail == userEmail) {
        showCustomToastWidget(
          context: context,
          message: '자신의 이메일은 추가할 수 없습니다',
          backgroundColor: const Color(0xFF707E93),
        );
        return;
      }

      try {
        // 이미 친구 신청했는지 중복 체크
        final existingRequest = await FirebaseFirestore.instance
            .collection('user_request')
            .where('request', isEqualTo: userEmail)
            .where('receive', isEqualTo: friendEmail)
            .get();

        if (existingRequest.docs.isNotEmpty) {
          showCustomToastWidget(
            context: context,
            message: '이미 신청되었습니다',
            backgroundColor: const Color(0xFF707E93),
          );
          return;
        }

        // 친구가 존재하는지 확인
        final querySnapshot = await FirebaseFirestore.instance
            .collection('friend_${friendEmail.replaceAll('.', '_')}')
            .get();

        if (querySnapshot.docs.isEmpty) {
          showCustomToastWidget(
            context: context,
            message: '해당하는 플레이어를 찾지 못했습니다.',
            backgroundColor: const Color(0xFF707E93),
          );
          return;
        }

        // 친구 요청 추가
        await FirebaseFirestore.instance.collection('user_request').add({
          'request': userEmail,
          'receive': friendEmail,
        });

        showCustomToastWidget(
          context: context,
          message: '친구 신청을 보냈습니다',
          backgroundColor: PRIMARY_COLOR,
        );
      } catch (e) {
        showCustomToastWidget(
          context: context,
          message: '오류 발생: $e',
          backgroundColor: Colors.red,
        );
      }

      rebuildModal(); // 리빌드 호출
    },
    userEmail: user?.email ?? '',
  );
}





//세번째 승인 페이지 함수 - request값이 있으면 승인 정보 뜸
Widget thirdpage_request({
  required String? request,
  required VoidCallback rebuildModal, // 리빌드 콜백 추가
}) {
  return Center(
    child: request != null
        ? Stack(
      children: [
        // Add Padding to the InfoBox with top padding
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8), // Add space at the top
          child: InfoBox(
            email: request, // request 값이 이메일로 설정
          ),
        ), // InfoBox만 배경으로 사용
        Positioned(
          bottom: 15,
          right: 25,
          child: infoBoxButton(
            cancleButtonPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              final userEmail = user?.email;
              rebuildModal(); // 리빌드 호출
              if (userEmail != null && request != null) {
                final querySnapshot = await FirebaseFirestore.instance
                    .collection('user_request')
                    .where('receive', isEqualTo: userEmail)
                    .where('request', isEqualTo: request)
                    .get();

                if (querySnapshot.docs.isNotEmpty) {
                  for (var doc in querySnapshot.docs) {
                    await doc.reference.delete();
                  }
                }
              }
              rebuildModal(); // 리빌드 호출
            },
            acceptButtonPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              final userEmail = user?.email;

              if (userEmail != null && request != null) {
                // 'user_request' 컬렉션에서 문서 삭제
                final querySnapshot = await FirebaseFirestore.instance
                    .collection('user_request')
                    .where('receive', isEqualTo: userEmail)
                    .where('request', isEqualTo: request)
                    .get();

                if (querySnapshot.docs.isNotEmpty) {
                  for (var doc in querySnapshot.docs) {
                    await doc.reference.delete();
                  }
                }

                // 사용자 문서의 ID 가져오기
                final userDocSnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .where('author', isEqualTo: userEmail)
                    .limit(1)
                    .get();

                String userDocId = userDocSnapshot.docs.isNotEmpty
                    ? userDocSnapshot.docs.first.id
                    : '';

                // 친구 문서의 ID 가져오기
                final friendDocSnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .where('author', isEqualTo: request)
                    .limit(1)
                    .get();

                String friendDocId = friendDocSnapshot.docs.isNotEmpty
                    ? friendDocSnapshot.docs.first.id
                    : '';

                // 'friend_(사용자이메일)' 컬렉션에 데이터 추가
                if (userDocId.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('friend_${userEmail.replaceAll('.', '_')}')
                      .doc(friendDocId) // 친구의 문서 ID를 문서 ID로 사용
                      .set({
                    'author': request,
                    'latitude': 0.0,
                    'longitude': 0.0,
                  });
                }

                // 'friend_(친구이메일)' 컬렉션에 데이터 추가
                if (friendDocId.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('friend_${request.replaceAll('.', '_')}')
                      .doc(userDocId) // 사용자의 문서 ID를 문서 ID로 사용
                      .set({
                    'author': userEmail,
                    'latitude': 0.0,
                    'longitude': 0.0,
                  });
                }
              }
              rebuildModal(); // 리빌드 호출
            },
          ),
        ),
      ],
    )
        : const SizedBox.shrink(), // request 값이 없을 때 빈 위젯 처리
  );
}



// 중앙에 2초동안 나왔다가 사라지는 팝업창?
void showCustomToastWidget({
  required BuildContext context,
  required String message,
  double height = 70,
  Color backgroundColor = Colors.black,
  Color textColor = Colors.white,
  double fontSize = 16,
}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) {
      final screenSize = MediaQuery.of(context).size;
      final width = screenSize.width * 0.9; // 화면 너비의 90%로 설정
      return Positioned(
        top: screenSize.height / 2 - height / 2,
        left: (screenSize.width - width) / 2,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}


