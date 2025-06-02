import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 날씨 데이터를 가져오는 함수
Future<Map<String, String?>> fetchWeather() async {
  const apiKey = "aaf901090c0e0de181c246fbfccce73a"; // OpenWeatherMap API 키
  final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=Seoul&appid=$apiKey&lang=kr&units=metric');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'temperature': data['main']['temp'].toString(),
        'description': data['weather'][0]['description'],
      };
    } else {
      print('Failed to load weather data');
      return {'temperature': null, 'description': null};
    }
  } catch (e) {
    print('Error: $e');
    return {'temperature': null, 'description': null};
  }
}

// 날씨 설명에 따른 아이콘 및 색상 설정
Map<String, dynamic> getWeatherIcon(String? description) {
  if (description == null) {
    return {'icon': Icons.error, 'color': Colors.grey};
  }

  switch (description) {
    case 'clear sky':
    case '맑음':
      return {'icon': Icons.wb_sunny, 'color': Colors.orange};
    case 'few clouds':
    case '구름 조금':
      return {'icon': Icons.cloud, 'color': Colors.lightBlue};
    case 'rain':
    case '비':
      return {'icon': Icons.umbrella, 'color': Colors.blue};
    case 'snow':
    case '눈':
      return {'icon': Icons.ac_unit, 'color': Colors.lightBlueAccent};
    default:
      return {'icon': Icons.cloud, 'color': Colors.grey};
  }
}