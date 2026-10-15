import 'package:flutter/material.dart';

import '../core/utils/date_helpers.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final DateTime createdAt;
  final TimeOfDay? notifTime;
  final bool darkTheme;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
    this.notifTime,
    this.darkTheme = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final email = (json['email'] ?? '') as String;
    final defaultUsername =
        email.contains('@') ? email.split('@').first : email;

    return UserModel(
      id: json['id'] as String,
      email: email,
      username: (json['username'] as String?) ?? defaultUsername,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      notifTime: DateHelpers.parseTime(json['notif_time'] as String?),
      darkTheme: json['dark_theme'] as bool? ?? false,
    );
  }

  UserModel copyWith({String? username, TimeOfDay? notifTime, bool? darkTheme}) {
    return UserModel(
      id: id,
      email: email,
      username: username ?? this.username,
      createdAt: createdAt,
      notifTime: notifTime ?? this.notifTime,
      darkTheme: darkTheme ?? this.darkTheme,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'created_at': createdAt.toIso8601String(),
      'notif_time':
          notifTime == null ? null : DateHelpers.toTimeString(notifTime!),
      'dark_theme': darkTheme,
    };
  }
}
