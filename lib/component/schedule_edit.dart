import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test1/component/custom_text_field.dart';
import 'package:test1/const/colors.dart';
import 'package:test1/model/schedule_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleEditBottomSheet extends StatefulWidget {
  final ScheduleModel schedule; // 수정할 일정 정보

  const ScheduleEditBottomSheet({
    required this.schedule,
    Key? key,
  }) : super(key: key);

  @override
  State<ScheduleEditBottomSheet> createState() => _ScheduleEditBottomSheetState();
}

class _ScheduleEditBottomSheetState extends State<ScheduleEditBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey();

  int? startTime; // 시작 시간 저장 변수
  int? endTime; // 종료 시간 저장 변수
  String? content; // 일정 내용 저장 변수

  @override
  void initState() {
    super.initState();
    // 기존 일정 데이터를 불러와서 초기화
    startTime = widget.schedule.startTime;
    endTime = widget.schedule.endTime;
    content = widget.schedule.content;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Form(
      key: formKey,
      child: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height / 2 + bottomInset,
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: bottomInset),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: '시작 시간',
                        isTime: true,
                        initialValue: startTime?.toString(),
                        onSaved: (String? val) {
                          startTime = int.parse(val!);
                        },
                        validator: timeValidator,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: CustomTextField(
                        label: '종료 시간',
                        isTime: true,
                        initialValue: endTime?.toString(),
                        onSaved: (String? val) {
                          endTime = int.parse(val!);
                        },
                        validator: timeValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Flexible(  // Flexible로 감싸서 내용이 넘칠 때 축소될 수 있도록
                  child: CustomTextField(
                    label: '내용',
                    isTime: false,
                    initialValue: content,
                    onSaved: (String? val) {
                      content = val;
                    },
                    validator: contentValidator,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        onEditSavePressed(context);
                      }
                    },
                    child: const Text('수정하기'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void onEditSavePressed(BuildContext context) async {
    final updatedSchedule = ScheduleModel(
      id: widget.schedule.id,
      content: content!,
      date: widget.schedule.date,
      startTime: startTime!,
      endTime: endTime!,
    );

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('다시 로그인을 해주세요.'),
        ),
      );
      Navigator.of(context).pop();
      return;
    }

    // 수정된 데이터를 Firestore에 업데이트
    await FirebaseFirestore.instance
        .collection('schedule')
        .doc(updatedSchedule.id)
        .update(updatedSchedule.toJson());

    Navigator.of(context).pop();
  }

  String? timeValidator(String? val) {
    if (val == null) {
      return '값을 입력해주세요';
    }

    int? number;
    try {
      number = int.parse(val);
    } catch (e) {
      return '숫자를 입력해주세요';
    }

    if (number < 0 || number > 24) {
      return '0시부터 24시 사이를 입력해주세요';
    }

    return null;
  }

  String? contentValidator(String? val) {
    if (val == null || val.isEmpty) {
      return '값을 입력해주세요';
    }
    return null;
  }
}
