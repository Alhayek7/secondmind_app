// lib/features/tasks/widgets/task_card.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:secondmind/core/theme/app_theme.dart';
import 'package:secondmind/data/models/task_model.dart';
import 'package:get/get.dart';
import 'package:secondmind/features/tasks/controllers/task_controller.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onStatusChanged;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  bool get isGridView => Get.find<TaskController>().isGridView.value;


  const TaskCard({
    super.key,
    required this.task,
    required this.onStatusChanged,
    required this.onDelete,
    required this.onTap,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool get isGridView => Get.find<TaskController>().isGridView.value;

  //============================================================================
  // HELPER METHODS
  //============================================================================
  String _getStatusName(TaskStatus status) {
    switch (status) {
      case TaskStatus.new_:
        return 'جديد';
      case TaskStatus.inProgress:
        return 'قيد التنفيذ';
      case TaskStatus.completed:
        return 'مكتمل';
      case TaskStatus.missed:
        return 'فائتة';
    }
  }

  Color _getStatusColor() {
    // ✅ الأولوية لها الأولوية على الحالة
    if (widget.task.priority == TaskPriority.urgent) {
      return AppTheme.statusUrgent;
    }
    
    // ✅ ثم نتحقق من الحالة
    switch (widget.task.status) {
      case TaskStatus.completed:
        return AppTheme.statusCompleted;
      case TaskStatus.inProgress:
        return AppTheme.statusPending;
      case TaskStatus.missed:
        return AppTheme.error;
      default:
        return AppTheme.primary;
    }
  }

  String _getStatusText() {
    // ✅ الأولوية العاجلة لها نص خاص
    if (widget.task.priority == TaskPriority.urgent) {
      return 'عاجل';
    }
    return _getStatusName(widget.task.status);
  }

  // ✅ دالة المشاركة
  Future<void> _shareTask() async {
    final String shareText = '''
📌 *${widget.task.title}*

${widget.task.description != null ? '📝 ${widget.task.description}\n\n' : ''}
${widget.task.dueDate != null ? '📅 التاريخ: ${_formatDate(widget.task.dueDate!)}\n' : ''}
${widget.task.location != null ? '📍 المكان: ${widget.task.location}\n' : ''}
${widget.task.organizer != null ? '🏢 الجهة المنظمة: ${widget.task.organizer}\n' : ''}
${widget.task.meetingLink != null ? '🔗 رابط الحضور: ${widget.task.meetingLink}\n' : ''}
${widget.task.registrationLink != null ? '📝 رابط التسجيل: ${widget.task.registrationLink}\n' : ''}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📱 SecondMind - عقلك الثاني الذي لا ينسى
    ''';

    await Share.share(shareText);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return GestureDetector(
    onTapDown: (_) => _controller.forward(),
    onTapUp: (_) => _controller.reverse(),
    onTapCancel: () => _controller.reverse(),
    onTap: widget.onTap,
    child: ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.softShadow,
          border: Border.all(
            color: AppTheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12), // ✅ قللنا المسافة
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildStatusBadge()), // ✅ Expanded
                      _buildActionButtons(),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    widget.task.title,
                    style: AppTheme.headlineMd.copyWith(
                      fontSize: isGridView ? 13 : 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: isGridView ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (widget.task.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.task.description!,
                      style: AppTheme.bodyMd.copyWith(fontSize: isGridView ? 10 : 12),
                      maxLines: isGridView ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Date
                  if (widget.task.dueDate != null)
                    _buildInfoRow(
                      icon: Icons.calendar_today_outlined,
                      text: _formatDate(widget.task.dueDate!),
                    ),

                  // Location (if exists)
                  if (widget.task.location != null)
                    _buildInfoRow(
                      icon: Icons.location_on_outlined,
                      text: widget.task.location!,
                    ),
                ],
              ),
            ),

            // Action Button
            _buildActionButton(),
          ],
        ),
      ),
    ),
  );
}

Widget _buildStatusBadge() {
  final color = _getStatusColor();
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.task.priority == TaskPriority.urgent)
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        Text(
          _getStatusText(),
          style: AppTheme.labelMd.copyWith(
            color: color,
            fontSize: isGridView ? 9 : 10,
          ),
        ),
      ],
    ),
  );
}

  // ✅ زر المشاركة والحذف المعدلين
Widget _buildActionButtons() {
  final iconSize = isGridView ? 16.0 : 20.0;
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: Icon(Icons.share_outlined, size: iconSize, color: AppTheme.outline),
        onPressed: _shareTask,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        tooltip: 'مشاركة المهمة',
      ),
      const SizedBox(width: 8),
      IconButton(
        icon: Icon(Icons.delete_outline, size: iconSize, color: AppTheme.outline),
        onPressed: widget.onDelete,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        tooltip: 'حذف المهمة',
      ),
    ],
  );
}

Widget _buildInfoRow({required IconData icon, required String text}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Row(
      children: [
        Icon(icon, size: isGridView ? 10 : 12, color: AppTheme.outline),
        const SizedBox(width: 4),
        Expanded(  // ✅ أضف Expanded
          child: Text(
            text,
            style: AppTheme.bodyMd.copyWith(fontSize: isGridView ? 9 : 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildActionButton() {
    // ✅ المهام الفائتة لا يمكن إكمالها مباشرة، تحتاج إعادة فتح
    if (widget.task.status == TaskStatus.missed) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.1),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Center(
          child: ElevatedButton.icon(
            onPressed: widget.onStatusChanged,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('إعادة فتح المهمة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      );
    }

    if (widget.task.status == TaskStatus.completed) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: TextButton.icon(
          onPressed: widget.onStatusChanged,
          icon: Icon(Icons.refresh, size: 18, color: AppTheme.onSurfaceVariant),
          label: Text('إعادة فتح',
              style:
                  AppTheme.labelMd.copyWith(color: AppTheme.onSurfaceVariant)),
        ),
      );
    }

    if (widget.task.status == TaskStatus.inProgress) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Center(
          child: ElevatedButton.icon(
            onPressed: widget.onStatusChanged,
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('إكمال المهمة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: widget.onStatusChanged,
          icon: const Icon(Icons.play_arrow_outlined, size: 18),
          label: const Text('بدء العمل'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: AppTheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return months[month - 1];
  }
}