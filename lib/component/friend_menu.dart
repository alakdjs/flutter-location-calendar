import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test1/const/colors.dart';
import 'package:test1/component/friend_Info.dart';

class FriendMenu extends StatefulWidget {
  final String? request;

  const FriendMenu({
    Key? key,
    required this.request,
  }) : super(key: key);

  @override
  _FriendMenuState createState() => _FriendMenuState();
}

class _FriendMenuState extends State<FriendMenu> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0; // 현재 선택된 버튼의 인덱스
  bool _isPressed = false; // 버튼 눌림 상태를 추적하는 변수


  void _showBottomSheet() {
    setState(() {
      _selectedIndex = 0; // 버튼 상태 초기화
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // ModalBottomSheet 내부 상태를 업데이트하기 위해 StatefulBuilder 사용
            return Container(
              height: 600, // 창 높이 설정
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Stack(
                children: [

                  // 페이지 표시 영역
                  Positioned(
                    top: 53.0,
                    left: 0,
                    right: 0,
                    bottom: 155.0,
                    child: PageView(
                      controller: _pageController,
                      children: [
                        SingleChildScrollView(
                          child: FriendListWidget(
                            userEmail: FirebaseAuth.instance.currentUser!.email!,
                            rebuildModal: () {
                              setModalState(() {}); // 리빌드 콜백 전달
                            },
                          ),
                        ),
                        SingleChildScrollView(
                          child: FriendAddWidget(
                            context: context,
                            emailController: TextEditingController(),
                            user: FirebaseAuth.instance.currentUser,
                            rebuildModal: () {
                              setModalState(() {}); // 리빌드 콜백 전달
                            },
                          ),
                        ),
                        SingleChildScrollView(
                          child: Center(
                            child: Column(
                              children: [
                                if (widget.request != null &&
                                    widget.request!.isNotEmpty) ...[
                                  thirdpage_request(
                                    request: widget.request,
                                    rebuildModal: () {
                                      setModalState(() {}); // 리빌드 콜백 전달
                                    },
                                  ), // 함수를 호출합니다.
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                  ),
                                ] else
                                  Padding(
                                    padding: EdgeInsets.only(top: 190),
                                    // 여기서 숫자를 조정해 텍스트 위치를 변경
                                    child: Text(
                                      "승인 대기 중인 플레이어는 없습니다",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        color: Color(0xFF8799B3),
                                      ),
                                    ),
                                  ),

                              ],
                            ),
                          ),
                        )
                        ,
                      ],
                    ),
                  ),


                  // 상단 선과 텍스트
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 52.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8799B3).withOpacity(0.4),
                            blurRadius: 100.0,
                            spreadRadius: 12.0,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Align(
                        alignment: Alignment(0, -0.2),
                        child: Text(
                          "친구",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 상단 하이라이트 선
                  Positioned(
                    top: 46.5,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 3.0,
                      color: PRIMARY_COLOR,
                    ),
                  ),

                  // 하단 영역
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 155.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8799B3).withOpacity(0.2),
                            blurRadius: 200.0,
                            spreadRadius: 50.0,
                            offset: const Offset(-50, 10),
                          ),
                        ],
                      ),
                    ),
                  ),


                  // 하단 새로운 선 (기존 하단 선 위로 겹쳐서 나타나도록 위치 조정)
                  Positioned(
                    bottom: 116.5, // 기존 하단 선 위로 겹치도록 설정
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 38.0, // 선의 높이
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8799B3).withOpacity(0.2),
                            blurRadius: 20.0,
                            spreadRadius: 6.0,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                  ),


                  // 버튼과 그림자
                  Positioned(
                    bottom: 118.0,
                    left: 13.0,
                    right: 13.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i = 0; i < 3; i++)
                          GestureDetector(
                            onTap: () {
                              setModalState(() {
                                _selectedIndex = i; // 선택된 버튼 갱신
                              });
                              _pageController.animateToPage(
                                i, // 전환할 페이지 인덱스
                                duration: Duration(milliseconds: 300),
                                // 애니메이션 지속 시간
                                curve: Curves.easeInOut, // 애니메이션 커브
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.3, // 화면 너비의 30%
                              height: MediaQuery.of(context).size.height * 0.043, // 화면 높이의 5%
                              decoration: BoxDecoration(
                                color: _selectedIndex == i
                                    ? const Color(0xFFF1F3F5)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(50.0),
                                boxShadow: _selectedIndex == i
                                    ? [
                                  BoxShadow(
                                    color: const Color(0xFF8799B3)
                                        .withOpacity(0.5),
                                    // 그림자 색상
                                    blurRadius: 4.0,
                                    // 흐림 효과
                                    offset: const Offset(-2, -3),
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
                                ]
                                    : [],
                              ),
                              child: Align(
                                alignment: Alignment(0, -0.2), // 텍스트를 살짝 위로 정렬
                                child: Text(
                                  ["친구", "친구 추가", "승인"][i],
                                  style: TextStyle(
                                    color: _selectedIndex == i
                                        ? const Color(0xFF3C4654)
                                        : const Color(0xFF8799B3), // 텍스트 색상 변경
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),


                  // 닫기 버튼 Positioned 함수
                  Positioned(
                    bottom: 52.0,
                    right: 0.0,
                    left: 0.0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // BottomSheet 닫기
                      },
                      onTapDown: (_) {
                        setModalState(() {
                          _isPressed = true; // 눌림 상태
                        });
                      },
                      onTapUp: (_) {
                        setModalState(() {
                          _isPressed = false; // 원상복구
                        });
                      },
                      onTapCancel: () {
                        setModalState(() {
                          _isPressed = false; // 원상복구
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200), // 애니메이션 지속 시간
                        curve: Curves.easeInOut, // 애니메이션 커브
                        child: Transform.scale(
                          scale: _isPressed ? 0.9 : 1.0, // 크기 애니메이션
                          child: Container(
                            width: 47.0, // 원래 크기
                            height: 47.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8799B3).withOpacity(0.2),
                                  blurRadius: 8.0,
                                  spreadRadius: 4.0,
                                  offset: const Offset(6, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.close, // X 아이콘
                                size: 30.0,
                                color: Color(0xFF8799B3), // 아이콘 색상
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 110.0,
      right: 7.0,
      child: SizedBox(
        width: 47.0,
        height: 47.0,
        child: FloatingActionButton(
          onPressed: _showBottomSheet,
          shape: CircleBorder(),
          backgroundColor: PRIMARY_COLOR,
          child: Icon(
            Icons.people,
            color: Colors.white,
            size: 30.0,
          ),
        ),
      ),
    );
  }
}
