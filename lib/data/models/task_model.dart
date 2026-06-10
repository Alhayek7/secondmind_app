// lib/data/models/task_model.dart
import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 1)
enum TaskStatus {
  @HiveField(0)
  new_,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  completed,
  @HiveField(3)
  missed,
}

@HiveType(typeId: 2)
enum TaskPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
  @HiveField(3)
  urgent,
}

@HiveType(typeId: 3)
enum TaskCategory {
  @HiveField(0)
  work,
  @HiveField(1)
  personal,
  @HiveField(2)
  study,
  @HiveField(3)
  urgent,
  @HiveField(4)
  other,
}

@HiveType(typeId: 4)
enum AttendanceType {
  @HiveField(0)
  online,
  @HiveField(1)
  inPerson,
  @HiveField(2)
  hybrid,
}

extension AttendanceTypeExtension on AttendanceType {
  String get displayName {
    switch (this) {
      case AttendanceType.online:
        return 'أونلاين';
      case AttendanceType.inPerson:
        return 'وجاهي';
      case AttendanceType.hybrid:
        return 'مختلط';
    }
  }
}

@HiveType(typeId: 0)
class TaskModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String? description;
  
  @HiveField(3)
  DateTime? dueDate;
  
  @HiveField(4)
  TaskStatus status;
  
  @HiveField(5)
  TaskPriority priority;
  
  @HiveField(6)
  DateTime createdAt;
  
  @HiveField(7)
  DateTime? completedAt;
  
  @HiveField(8)
  int? timeSpent;
  
  @HiveField(9)
  TaskCategory category;
  
  @HiveField(10)
  String? location;
  
  @HiveField(11)
  AttendanceType? attendanceType;
  
  @HiveField(12)
  String? meetingLink;
  
  @HiveField(13)
  String? organizer;
  
  @HiveField(14)
  String? contactPhone;
  
  @HiveField(15)
  String? contactEmail;
  
  @HiveField(16)
  String? registrationLink;
  
  @HiveField(17)
  String? fee;
  
  @HiveField(18)
  String? additionalNotes;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.status = TaskStatus.new_,
    this.priority = TaskPriority.medium,
    required this.createdAt,
    this.completedAt,
    this.timeSpent,
    this.category = TaskCategory.other,
    this.location,
    this.attendanceType,
    this.meetingLink,
    this.organizer,
    this.contactPhone,
    this.contactEmail,
    this.registrationLink,
    this.fee,
    this.additionalNotes,
  });
  
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? completedAt,
    int? timeSpent,
    TaskCategory? category,
    String? location,
    AttendanceType? attendanceType,
    String? meetingLink,
    String? organizer,
    String? contactPhone,
    String? contactEmail,
    String? registrationLink,
    String? fee,
    String? additionalNotes,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      timeSpent: timeSpent ?? this.timeSpent,
      category: category ?? this.category,
      location: location ?? this.location,
      attendanceType: attendanceType ?? this.attendanceType,
      meetingLink: meetingLink ?? this.meetingLink,
      organizer: organizer ?? this.organizer,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      registrationLink: registrationLink ?? this.registrationLink,
      fee: fee ?? this.fee,
      additionalNotes: additionalNotes ?? this.additionalNotes,
    );
  }
}