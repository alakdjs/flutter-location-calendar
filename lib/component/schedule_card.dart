import 'package:test1/component/schedule_edit.dart';
import 'package:test1/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:test1/model/schedule_model.dart';

class ScheduleCard extends StatelessWidget {
  final int startTime;
  final int endTime;
  final String content;
  final String id;  // Firebase 문서 ID를 받기 위한 id 추가
  final DateTime date; // 일정의 날짜를 저장할 변수 추가

  const ScheduleCard({
    required this.startTime,
    required this.endTime,
    required this.content,
    required this.id,  // id 추가
    required this.date, // 생성자에 date 추가
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.0,
          color: PRIMARY_COLOR,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: IntrinsicHeight(  // ➊ 높이를 내부 위젯들의 최대 높이로 설정
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Time(   // ➋ 시작과 종료 시간을 보여줄 위젯
                startTime: startTime,
                endTime: endTime,
              ),
              SizedBox(width: 16.0),
              _Content(   // ➌ 일정 내용을 보여줄 위젯
                content: content,
              ),
              SizedBox(width: 16.0),
              // 수정 버튼 추가
              IconButton(
                icon: Icon(Icons.edit, color: PRIMARY_COLOR),
                onPressed: () {
                  // 수정 버튼을 눌렀을 때, 수정 화면(ScheduleEditBottomSheet)을 띄움
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, // 키보드와 상호작용
                    builder: (BuildContext context) {
                      return ScheduleEditBottomSheet(
                        schedule: ScheduleModel(
                          id: id,
                          startTime: startTime,
                          endTime: endTime,
                          content: content,
                          date: date,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _Time extends StatelessWidget {
  final int startTime;  // ➊ 시작 시간
  final int endTime;    // ➋ 종료 시간

  const _Time({
    required this.startTime,
    required this.endTime,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: PRIMARY_COLOR,
      fontSize: 16.0,
    );

    return Column(  // ➌ 시간을 위에서 아래로 배치
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${startTime.toString().padLeft(2, '0')}:00',  // 숫자가 두 자리수가 안 되면 0으로 채워주기
          style: textStyle,
        ),
        Text(
          '${endTime.toString().padLeft(2, '0')}:00', // 숫자가 두 자리수가 안 되면 0으로 채워주기
          style: textStyle.copyWith(
            fontSize: 10.0,
          ),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final String content;  // ➊ 내용

  const _Content({
    required this.content,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(  // ➋ 최대한 넓게 늘리기
      child: Text(
        content,
      ),
    );
  }
}
