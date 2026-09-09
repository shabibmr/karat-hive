import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/announcements/model/announcement_enums.dart';
import 'package:kh_admin/features/announcements/model/create_announcement_dto.dart';

/// Comprehensive Compose Announcement Modal with bilingual fields,
/// audience & channel selection, scheduling, and SAM-GAP-10 notice.
///
/// Extracted verbatim from `announcements_screen.dart` (TR-S2-09).
class ComposeAnnouncementDialog extends StatefulWidget {
  const ComposeAnnouncementDialog({super.key, required this.onSubmit});

  final Future<void> Function(CreateAnnouncementDto dto) onSubmit;

  @override
  State<ComposeAnnouncementDialog> createState() =>
      _ComposeAnnouncementDialogState();
}

class _ComposeAnnouncementDialogState extends State<ComposeAnnouncementDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final _titleEnController = TextEditingController();
  final _titleArController = TextEditingController();
  final _bodyEnController = TextEditingController();
  final _bodyArController = TextEditingController();

  AudienceType _selectedAudience = AudienceType.all;
  bool _channelInApp = true;
  bool _channelPush = false;
  bool _channelEmail = false;
  bool _isCritical = false;

  bool _scheduleForLater = false;
  DateTime? _scheduledDateTime;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleEnController.dispose();
    _titleArController.dispose();
    _bodyEnController.dispose();
    _bodyArController.dispose();
    super.dispose();
  }

  Future<void> _pickScheduleDateTime() async {
    final now = DateTime.now();
    final initialDate = _scheduledDateTime ?? now.add(const Duration(hours: 1));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null || !mounted) return;

    setState(() {
      _scheduledDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _handleSubmit() async {
    setState(() => _errorMessage = null);

    final titleEn = _titleEnController.text.trim();
    final titleAr = _titleArController.text.trim();
    final bodyEn = _bodyEnController.text.trim();
    final bodyAr = _bodyArController.text.trim();

    if (titleEn.isEmpty || bodyEn.isEmpty) {
      setState(() => _errorMessage = 'Please complete the English title and body.');
      _tabController.animateTo(0);
      return;
    }

    if (titleAr.isEmpty || bodyAr.isEmpty) {
      setState(() => _errorMessage = 'Please complete the Arabic title and body.');
      _tabController.animateTo(1);
      return;
    }

    if (!_channelInApp && !_channelPush && !_channelEmail) {
      setState(() => _errorMessage = 'Select at least one delivery channel.');
      return;
    }

    if (_scheduleForLater) {
      if (_scheduledDateTime == null) {
        setState(() => _errorMessage = 'Please select a scheduled date and time.');
        return;
      }
      if (_scheduledDateTime!.isBefore(DateTime.now())) {
        setState(() => _errorMessage = 'Scheduled time must be in the future.');
        return;
      }
    }

    final dto = CreateAnnouncementDto(
      titleEn: titleEn,
      titleAr: titleAr,
      bodyEn: bodyEn,
      bodyAr: bodyAr,
      audience: {'userType': _selectedAudience.wireValue},
      channels: {
        'inApp': _channelInApp,
        'push': _channelPush,
        'email': _channelEmail,
      },
      critical: _isCritical,
      scheduledFor: _scheduleForLater ? _scheduledDateTime : null,
    );

    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(dto);
      if (mounted) Navigator.of(context).pop();
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.campaign, color: kh.colors.goldPrimary),
          SizedBox(width: kh.spacing.sm),
          Text('Compose Announcement', style: kh.typography.title),
        ],
      ),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_errorMessage != null) ...[
                  Container(
                    key: const Key('announcement-form-error'),
                    padding: EdgeInsets.all(kh.spacing.sm),
                    margin: EdgeInsets.only(bottom: kh.spacing.md),
                    decoration: BoxDecoration(
                      color: kh.colors.error.withValues(alpha: 0.1),
                      borderRadius: kh.shapes.roundedSm,
                      border: Border.all(color: kh.colors.error),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, size: 18, color: kh.colors.error),
                        SizedBox(width: kh.spacing.xs),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: kh.typography.bodySmall.copyWith(color: kh.colors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Bilingual Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: kh.colors.goldPrimary,
                  unselectedLabelColor: kh.colors.textMuted,
                  indicatorColor: kh.colors.goldPrimary,
                  tabs: const [
                    Tab(text: 'English'),
                    Tab(text: 'العربية (Arabic)'),
                  ],
                ),
                SizedBox(height: kh.spacing.md),
                SizedBox(
                  height: 200,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // English Fields
                      Column(
                        children: [
                          TextField(
                            key: const Key('announcement-title-en-field'),
                            controller: _titleEnController,
                            decoration: const InputDecoration(
                              labelText: 'Announcement Title (English) *',
                              hintText: 'e.g. Gold Souk Holiday Trading Hours',
                              isDense: true,
                            ),
                          ),
                          SizedBox(height: kh.spacing.sm),
                          Expanded(
                            child: TextField(
                              key: const Key('announcement-body-en-field'),
                              controller: _bodyEnController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                labelText: 'Message Body (English) *',
                                hintText:
                                    'Enter full announcement broadcast text in English...',
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Arabic Fields
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Column(
                          children: [
                            TextField(
                              key: const Key('announcement-title-ar-field'),
                              controller: _titleArController,
                              textDirection: TextDirection.rtl,
                              decoration: const InputDecoration(
                                labelText: 'عنوان الإعلان (بالعربية) *',
                                hintText: 'مثال: مواعيد عمل سوق الذهب خلال العيد',
                                isDense: true,
                              ),
                            ),
                            SizedBox(height: kh.spacing.sm),
                            Expanded(
                              child: TextField(
                                key: const Key('announcement-body-ar-field'),
                                controller: _bodyArController,
                                maxLines: 4,
                                textDirection: TextDirection.rtl,
                                decoration: const InputDecoration(
                                  labelText: 'نص الرسالة (بالعربية) *',
                                  hintText: 'أدخل نص الإعلان كاملاً باللغة العربية...',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: kh.spacing.md),
                const Divider(),
                SizedBox(height: kh.spacing.sm),
                // Target Audience
                Text('TARGET AUDIENCE',
                    style: kh.typography.caption.copyWith(
                      color: kh.colors.goldPrimary,
                      fontWeight: FontWeight.bold,
                    )),
                SizedBox(height: kh.spacing.xs),
                DropdownButtonFormField<AudienceType>(
                  key: const Key('announcement-audience-select'),
                  initialValue: _selectedAudience,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: AudienceType.values
                      .map((a) => DropdownMenuItem(value: a, child: Text(a.label)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedAudience = val);
                  },
                ),
                SizedBox(height: kh.spacing.md),
                // Delivery Channels
                Text('DELIVERY CHANNELS',
                    style: kh.typography.caption.copyWith(
                      color: kh.colors.goldPrimary,
                      fontWeight: FontWeight.bold,
                    )),
                SizedBox(height: kh.spacing.xs),
                Wrap(
                  spacing: kh.spacing.lg,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          key: const Key('announcement-channel-inapp'),
                          value: _channelInApp,
                          onChanged: (val) => setState(() => _channelInApp = val ?? false),
                        ),
                        const Text('In-App Notification'),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          key: const Key('announcement-channel-push'),
                          value: _channelPush,
                          onChanged: (val) => setState(() => _channelPush = val ?? false),
                        ),
                        const Text('Mobile Push'),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          key: const Key('announcement-channel-email'),
                          value: _channelEmail,
                          onChanged: (val) => setState(() => _channelEmail = val ?? false),
                        ),
                        const Text('Email'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: kh.spacing.sm),
                // Critical Notice Switch
                SwitchListTile(
                  key: const Key('announcement-critical-switch'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Critical Announcement'),
                  subtitle: Text(
                    'Flags priority alert and overrides user notification preferences for outages or policy changes.',
                    style: kh.typography.caption.copyWith(color: kh.colors.textMuted),
                  ),
                  value: _isCritical,
                  onChanged: (val) => setState(() => _isCritical = val),
                ),
                SizedBox(height: kh.spacing.sm),
                SwitchListTile(
                  key: const Key('announcement-schedule-radio'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Schedule for later'),
                  subtitle: Text(
                    _scheduleForLater
                        ? 'Dispatch at the selected date and time (GST).'
                        : 'Dispatch immediately after compose.',
                    style: kh.typography.caption.copyWith(color: kh.colors.textMuted),
                  ),
                  value: _scheduleForLater,
                  onChanged: (val) => setState(() => _scheduleForLater = val),
                ),
                if (_scheduleForLater) ...[
                  SizedBox(height: kh.spacing.xs),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        key: const Key('announcement-pick-datetime-button'),
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          _scheduledDateTime != null
                              ? 'Scheduled: ${_scheduledDateTime!.toLocal().toString().substring(0, 16)}'
                              : 'Select Date & Time',
                        ),
                        onPressed: _pickScheduleDateTime,
                      ),
                      if (_scheduledDateTime != null) ...[
                        SizedBox(width: kh.spacing.sm),
                        IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          tooltip: 'Clear schedule',
                          onPressed: () => setState(() => _scheduledDateTime = null),
                        ),
                      ],
                    ],
                  ),
                ],
                SizedBox(height: kh.spacing.md),
                // SAM-GAP-10 Notice
                Container(
                  padding: EdgeInsets.all(kh.spacing.sm),
                  decoration: BoxDecoration(
                    color: kh.colors.gold400.withValues(alpha: 0.08),
                    borderRadius: kh.shapes.roundedSm,
                    border: Border.all(color: kh.colors.borderSubtle),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 18, color: kh.colors.goldPrimary),
                      SizedBox(width: kh.spacing.xs),
                      Expanded(
                        child: Text(
                          'Dynamic Recipient Evaluation (SAM-GAP-10): Pre-send recipient counts are not previewed. The target audience is evaluated dynamically at the scheduled dispatch moment.',
                          style: kh.typography.caption.copyWith(color: kh.colors.goldPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('announcement-submit-button'),
          onPressed: _isSubmitting ? null : _handleSubmit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_scheduleForLater ? 'Schedule Announcement' : 'Broadcast Now'),
        ),
      ],
    );
  }
}
