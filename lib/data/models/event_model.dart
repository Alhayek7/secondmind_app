import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:secondmind/core/theme/app_theme.dart';

part 'event_model.g.dart';

@HiveType(typeId: 5)
class EventModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String message;
  
  @HiveField(3)
  final String type;
  
  @HiveField(4)
  final DateTime timestamp;
  
  @HiveField(5)
  final String? taskId;
  
  EventModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.taskId,
  });
  
  IconData get icon {
    switch (type) {
      case 'add':
        return Icons.add_circle;
      case 'delete':
        return Icons.delete;
      case 'edit':
        return Icons.edit;
      case 'complete':
        return Icons.check_circle;
      case 'reopen':
        return Icons.refresh;
      case 'missed':
        return Icons.warning_amber;
      default:
        return Icons.notifications;
    }
  }
  
  Color get color {
    switch (type) {
      case 'add':
        return AppTheme.statusCompleted;
      case 'delete':
        return AppTheme.error;
      case 'edit':
        return AppTheme.statusPending;
      case 'complete':
        return AppTheme.statusCompleted;
      case 'reopen':
        return AppTheme.statusPending;
      case 'missed':
        return AppTheme.error;
      default:
        return AppTheme.primary;
    }
  }
}