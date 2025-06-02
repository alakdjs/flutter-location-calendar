# 📱 친구야 뭐하니! - Flutter 기반 소셜 일정 관리 앱

이 앱은 친구들과 **위치를 실시간으로 공유**하고,  
**영상통화를 하며 소통**할 수 있는 **Flutter 기반 소셜 일정 관리 앱**입니다.

⚠️ 이 프로젝트의 API 키는 모두 폐기되었으며, 보안상 작동하지 않습니다.

<br>

## ✨ 주요 기능

- 🗺 실시간 친구 위치 공유 (Google Maps 연동)
- 👫 친구 추가 기능
- 📞 영상 통화 (Agora SDK 사용)
- 📆 개인 일정 관리 (캘린더 + 메모 + 일정 등록 및 수정)
- 🔐 구글/카카오 소셜 로그인 (Firebase Authentication 연동)
- 🌤 실시간 날씨 정보 표시 (OpenWeatherMap API)

<br>

## 🛠 개발 환경

- Flutter 3.24.4 (Stable) / Dart 3.5.4
- Android Studio 2024.1
- Firebase Authentication & Firestore
- Agora Video SDK
- Kakao Flutter SDK
- Google Maps API
- OpenWeatherMap API

<br>

## 🗓 개발 기간

**2024.11 ~ 2024.12 (약 2개월)**

<br>

## 🎥 시연 영상

[![시연 영상 보기](https://img.youtube.com/vi/l79SWWXp3xg/0.jpg)](https://youtu.be/l79SWWXp3xg)

> 로그인, 위치 공유, 영상통화, 일정관리 등 전체 흐름을 시연한 영상입니다.

<br>

## 📁 GitHub 소스코드

🔗 [프로젝트 바로가기](https://github.com/alakdjs/flutter-location-calendar)

<br>

## ⚠️ 참고사항

- 본 영상과 소스코드는 **포트폴리오 목적**으로 제작되었습니다.
- 로그인 기능은 **Firebase SHA1 인증서 등록 후에만 작동**합니다. (API 키는 전부 폐기한 상태로 커밋)

<br>

## 👥 공동 개발자

- [@alakdjs](https://github.com/alakdjs)
  > Flutter 앱 설계(일정 관리 기반), Firebase 연동, 소셜 로그인 연동(구글, 카카오), 일정 수정하기 기능 추가, 구글 지도 마커 정보 표시

- [@202021042khj](https://github.com/202021042khj)
  > Flutter 앱 설계(일정 관리 기반), home_screen 화면 구성, 상대방 위치 공유(Front), 날씨 기능, 로그인 화면 UI, 지도 화면 UI

- [@Jaetang](https://github.com/Jaetang)
  > Flutter 앱 설계(일정 관리 기반), 영상 통화 기능, 친구 추가 기능(UI 포함), 상대방 위치 공유(Back)
