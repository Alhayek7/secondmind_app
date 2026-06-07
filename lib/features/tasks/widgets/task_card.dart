// lib/features/tasks/widgets/task_card.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:secondmind/core/theme/app_theme.dart';
import 'package:secondmind/data/models/task_model.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onStatusChanged;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  
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

class _TaskCardState extends State<TaskCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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
    }
  }

  Color _getStatusColor() {
    switch (widget.task.priority) {
      case TaskPriority.urgent:
        return AppTheme.statusUrgent;
      case TaskPriority.high:
        return AppTheme.statusPending;
      default:
        return AppTheme.primary;
    }
  }
  
  String _getStatusText() {
    if (widget.task.priority == TaskPriority.urgent) return 'عاجل';
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusBadge(),
                        _buildActionButtons(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Title
                    Text(
                      widget.task.title,
                      style: AppTheme.headlineMd.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (widget.task.description != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.task.description!,
                        style: AppTheme.bodyMd.copyWith(fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const SizedBox(height: 12),
                    
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.task.priority == TaskPriority.urgent)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
          Text(
            _getStatusText(),
            style: AppTheme.labelMd.copyWith(
              color: color,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ زر المشاركة والحذف المعدلين
  Widget _buildActionButtons() {
    return Row(
      children: [
        // زر المشاركة
        IconButton(
          icon: Icon(Icons.share_outlined, size: 20, color: AppTheme.outline),
          onPressed: _shareTask,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          tooltip: 'مشاركة المهمة',
        ),
        const SizedBox(width: 12),
        // زر الحذف
        IconButton(
          icon: Icon(Icons.delete_outline, size: 20, color: AppTheme.outline),
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.outline),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodyMd.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
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
          label: Text('إعادة فتح', style: AppTheme.labelMd.copyWith(color: AppTheme.onSurfaceVariant)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    return months[month - 1];
  }
}