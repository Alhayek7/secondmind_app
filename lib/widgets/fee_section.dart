import 'package:flutter/material.dart';
import 'package:secondmind/core/theme/app_theme.dart';

class FeeSection extends StatefulWidget {
  final String? initialFee;
  final String? initialFeeType;
  final String? initialFeeCurrency;
  final double? initialFeeAmount;
  final String? initialFeeNote;
  final Function(Map<String, dynamic>) onChanged;

  const FeeSection({
    super.key,
    this.initialFee,
    this.initialFeeType,
    this.initialFeeCurrency,
    this.initialFeeAmount,
    this.initialFeeNote,
    required this.onChanged,
  });

  @override
  State<FeeSection> createState() => _FeeSectionState();
}

class _FeeSectionState extends State<FeeSection> {
  late String _feeType;
  late String _feeCurrency;
  late TextEditingController _feeAmountController;
  late TextEditingController _feeNoteController;
  late TextEditingController _customFeeController;

  final List<String> _feeTypes = ['مجاني', 'مدفوع', 'مخفض', 'مخصص'];
  
  final Map<String, String> _currencies = {
    'SAR': '🇸🇦 ريال سعودي',
    'USD': '🇺🇸 دولار أمريكي',
    'AED': '🇦🇪 درهم إماراتي',
    'JOD': '🇯🇴 دينار أردني',
    'EGP': '🇪🇬 جنيه مصري',
    'ILS': '🇮🇱 شيكل إسرائيلي',
  };

  @override
  void initState() {
    super.initState();
    _feeType = widget.initialFeeType ?? 'مجاني';
    _feeCurrency = widget.initialFeeCurrency ?? 'SAR';
    _feeAmountController = TextEditingController(
      text: widget.initialFeeAmount?.toString() ?? '',
    );
    _feeNoteController = TextEditingController(text: widget.initialFeeNote ?? '');
    _customFeeController = TextEditingController(text: widget.initialFee ?? '');
    
    _feeAmountController.addListener(_notifyChange);
    _feeNoteController.addListener(_notifyChange);
    _customFeeController.addListener(_notifyChange);
  }

  void _notifyChange() {
    final result = <String, dynamic>{};
    
    if (_feeType == 'مجاني') {
      result['fee'] = 'مجاني';
      result['fee_type'] = 'free';
      result['fee_amount'] = null;
      result['fee_currency'] = null;
      result['fee_note'] = null;
    } else if (_feeType == 'مدفوع') {
      final amount = double.tryParse(_feeAmountController.text);
      result['fee'] = '${_feeAmountController.text} ${_getCurrencySymbol(_feeCurrency)}';
      result['fee_type'] = 'paid';
      result['fee_amount'] = amount;
      result['fee_currency'] = _feeCurrency;
      result['fee_note'] = _feeNoteController.text;
    } else if (_feeType == 'مخفض') {
      final amount = double.tryParse(_feeAmountController.text);
      result['fee'] = '${_feeAmountController.text} ${_getCurrencySymbol(_feeCurrency)} (مخفض)';
      result['fee_type'] = 'discount';
      result['fee_amount'] = amount;
      result['fee_currency'] = _feeCurrency;
      result['fee_note'] = _feeNoteController.text;
    } else if (_feeType == 'مخصص') {
      result['fee'] = _customFeeController.text;
      result['fee_type'] = 'custom';
      result['fee_amount'] = null;
      result['fee_currency'] = null;
      result['fee_note'] = _feeNoteController.text;
    }
    
    widget.onChanged(result);
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'SAR': return '﷼';
      case 'USD': return '\$';
      case 'AED': return 'د.إ';
      case 'JOD': return 'د.أ';
      case 'EGP': return 'ج.م';
      case 'ILS': return '₪';
      default: return '';
    }
  }

  @override
  void dispose() {
    _feeAmountController.dispose();
    _feeNoteController.dispose();
    _customFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.money, size: 16, color: AppTheme.primary),
            ),
            const SizedBox(width: 8),
            Text(
              'الرسوم',
              style: AppTheme.labelMd.copyWith(
                color: AppTheme.outline,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // اختيار نوع الرسوم
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _feeType,
              isExpanded: true,
              icon: Icon(Icons.expand_more, color: AppTheme.primary),
              items: _feeTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        type == 'مجاني' ? Icons.check_circle_outline :
                        type == 'مدفوع' ? Icons.payment :
                        type == 'مخفض' ? Icons.local_offer :
                        Icons.edit_note,
                        size: 18,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(type, style: AppTheme.bodyLg),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _feeType = value!);
                _notifyChange();
              },
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // حقول إضافية حسب النوع
        if (_feeType == 'مدفوع' || _feeType == 'مخفض') ...[
          Row(
            children: [
              // حقل السعر
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _feeAmountController,
                    keyboardType: TextInputType.number,
                    style: AppTheme.bodyLg,
                    decoration: const InputDecoration(
                      hintText: 'المبلغ',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // اختيار العملة
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _feeCurrency,
                      isExpanded: true,
                      icon: Icon(Icons.expand_more, size: 18, color: AppTheme.primary),
                      items: _currencies.keys.map((currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Text(
                            _currencies[currency]!,
                            style: AppTheme.labelMd,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _feeCurrency = value!);
                        _notifyChange();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // ملاحظات إضافية
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _feeNoteController,
              maxLines: 2,
              style: AppTheme.bodyMd,
              decoration: const InputDecoration(
                hintText: 'ملاحظات إضافية (مثال: شامل الضريبة، خصم 20%)',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
        
        // حقل مخصص
        if (_feeType == 'مخصص')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _customFeeController,
              maxLines: 2,
              style: AppTheme.bodyMd,
              decoration: const InputDecoration(
                hintText: 'أدخل تفاصيل الرسوم (مثال: 150 ريال شاملة الضريبة)',
                border: InputBorder.none,
              ),
            ),
          ),
      ],
    );
  }
}