// lib/data/models/task_model.dart
import 'package:hive/hive.dart';

enum TaskStatus { new_, inProgress, completed }
enum TaskPriority { low, medium, high, urgent }
enum TaskCategory { work, personal, study, urgent, other }
enum AttendanceType { online, inPerson, hybrid }

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
  
  // ============ الحقول الجديدة (اختيارية) ============
  @HiveField(10)
  String? location;           // المكان
  
  @HiveField(11)
  AttendanceType? attendanceType;  // أونلاين / وجاهي / مختلط
  
  @HiveField(12)
  String? meetingLink;        // رابط الحضور (Google Meet, Zoom, Teams)
  
  @HiveField(13)
  String? organizer;          // الجهة المنظمة
  
  @HiveField(14)
  String? contactPhone;       // رقم الاتصال
  
  @HiveField(15)
  String? contactEmail;       // البريد الإلكتروني للتواصل
  
  @HiveField(16)
  String? registrationLink;   // رابط التسجيل
  
  @HiveField(17)
  String? fee;                // الرسوم (مجاني / 50 ريال / ...)
  
  @HiveField(18)
  String? additionalNotes;    // ملاحظات إضافية

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

// TaskModelAdapter (تحديث)
class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 0;
  
  @override
  TaskModel read(BinaryReader reader) {
    return TaskModel(
      id: reader.readString(),
      title: reader.readString(),
      description: _readStringOrNull(reader),
      dueDate: _readDateTimeOrNull(reader),
      status: TaskStatus.values[reader.readInt()],
      priority: TaskPriority.values[reader.readInt()],
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      completedAt: _readDateTimeOrNull(reader),
      timeSpent: _readIntOrNull(reader),
      category: TaskCategory.values[reader.readInt()],
      location: _readStringOrNull(reader),
      attendanceType: _readAttendanceTypeOrNull(reader),
      meetingLink: _readStringOrNull(reader),
      organizer: _readStringOrNull(reader),
      contactPhone: _readStringOrNull(reader),
      contactEmail: _readStringOrNull(reader),
      registrationLink: _readStringOrNull(reader),
      fee: _readStringOrNull(reader),
      additionalNotes: _readStringOrNull(reader),
    );
  }
  
  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description ?? '');
    writer.writeInt(obj.dueDate?.millisecondsSinceEpoch ?? -1);
    writer.writeInt(obj.status.index);
    writer.writeInt(obj.priority.index);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeInt(obj.completedAt?.millisecondsSinceEpoch ?? -1);
    writer.writeInt(obj.timeSpent ?? -1);
    writer.writeInt(obj.category.index);
    writer.writeString(obj.location ?? '');
    writer.writeInt(obj.attendanceType?.index ?? -1);
    writer.writeString(obj.meetingLink ?? '');
    writer.writeString(obj.organizer ?? '');
    writer.writeString(obj.contactPhone ?? '');
    writer.writeString(obj.contactEmail ?? '');
    writer.writeString(obj.registrationLink ?? '');
    writer.writeString(obj.fee ?? '');
    writer.writeString(obj.additionalNotes ?? '');
  }
  
  String? _readStringOrNull(BinaryReader reader) {
    final value = reader.readString();
    return value.isEmpty ? null : value;
  }
  
  DateTime? _readDateTimeOrNull(BinaryReader reader) {
    final value = reader.readInt();
    return value == -1 ? null : DateTime.fromMillisecondsSinceEpoch(value);
  }
  
  int? _readIntOrNull(BinaryReader reader) {
    final value = reader.readInt();
    return value == -1 ? null : value;
  }
  
  AttendanceType? _readAttendanceTypeOrNull(BinaryReader reader) {
    final value = reader.readInt();
    return value == -1 ? null : AttendanceType.values[value];
  }
}