import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/utils/sound_player.dart';
import '../../../data/datasources/mastery_local_datasource.dart';
import '../../../domain/services/parent_stats.dart';
import '../../widgets/cards/chunky_card.dart';
import '../../widgets/dialogs/parent_gate_dialog.dart';
import '../../widgets/dialogs/screen_time_dialog.dart';
import '../../widgets/headers/responsive_scaffold.dart';

class _DashboardData {
  const _DashboardData(this.stats, this.timeLimit, this.muted);
  final ParentStats stats;
  final int timeLimit;
  final bool muted;
}

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({
    super.key,
    this.dataSource,
  });

  final MasteryLocalDataSource? dataSource;

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  static const String _timeLimitKey = '__system_time_limit';
  static const String _muteKey = '__system_mute';
  static const List<int> _timeOptions = [15, 30, 45, 60];
  late Future<_DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant ParentDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _refresh();
  }

  Future<_DashboardData> _load() async {
    final ds = widget.dataSource ?? HiveMasteryLocalDataSource();
    try {
      await ds.init();
      final records = await ds.getAllRecords();
      final globalIndex = await ds.getGlobalUnlockedIndex();
      int limit = 30;
      bool muted = false;
      try {
        if (Hive.isBoxOpen(HiveMasteryLocalDataSource.boxName)) {
          final box = Hive.box(HiveMasteryLocalDataSource.boxName);
          limit = (box.get(_timeLimitKey) as num?)?.toInt() ?? 30;
          muted = (box.get(_muteKey) as bool?) ?? false;
        }
      } catch (_) {}
      try {
        SoundPlayer.instance.setMuted(muted);
      } catch (_) {}
      return _DashboardData(
        ParentStatsService.compute(records, globalIndex),
        limit,
        muted,
      );
    } catch (_) {
      return _DashboardData(
        ParentStatsService.compute(const [], 1),
        30,
        false,
      );
    }
  }

  void _refresh() {
    setState(() => _future = _load());
  }

  Future<void> _setTimeLimit(int v) async {
    try {
      await Hive.box(HiveMasteryLocalDataSource.boxName).put(_timeLimitKey, v);
    } catch (_) {}
    _refresh();
  }

  Future<void> _setMuted(bool v) async {
    try {
      await Hive.box(HiveMasteryLocalDataSource.boxName).put(_muteKey, v);
    } catch (_) {}
    SoundPlayer.instance.setMuted(v);
    _refresh();
  }

  Future<void> _resetData() async {
    final ok = await ParentGateDialog.show(context);
    if (ok != true || !mounted) return;
    try {
      final box = Hive.box(HiveMasteryLocalDataSource.boxName);
      final keys = box.keys
          .whereType<String>()
          .where((k) => !k.startsWith('__system_'))
          .toList();
      await box.deleteAll(keys);
      await box.put('__system_global_node', 1);
    } catch (_) {}
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      body: FutureBuilder<_DashboardData>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data!;
          final s = data.stats;
          final maxWidth = ResponsiveHelper.value(
            context,
            mobile: double.infinity,
            tablet: 720.0,
          );
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.space8),
                    Text('Dasbor Orang Tua',
                        style: AppTypography.uiHeading(fontSize: 22.0)),
                    Text(
                      'Kemajuan belajar anak dari data perangkat ini',
                      style: AppTypography.uiBody(
                        fontSize: 13.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space16),
                    if (s.trainedCount == 0)
                      _emptyCard()
                    else ...[
                      _summaryCard(s),
                      const SizedBox(height: AppSpacing.space16),
                      Text('Kemajuan per Zona',
                          style: AppTypography.uiHeading(fontSize: 18.0)),
                      const SizedBox(height: AppSpacing.space8),
                      _zoneRow('Angka', s.numbers.trained, s.numbers.total,
                          s.numbers.mastered, s.numbers.accuracy,
                          AppColors.numberPrimary),
                      const SizedBox(height: AppSpacing.space8),
                      _zoneRow('Huruf', s.letters.trained, s.letters.total,
                          s.letters.mastered, s.letters.accuracy,
                          AppColors.letterPrimary),
                      const SizedBox(height: AppSpacing.space8),
                      _zoneRow('Kata', s.words.trained, s.words.total,
                          s.words.mastered, s.words.accuracy,
                          AppColors.blendingPrimary),
                      const SizedBox(height: AppSpacing.space16),
                      _recommendationCard(s),
                    ],
                    const SizedBox(height: AppSpacing.space16),
                    _timeCard(data.timeLimit),
                    const SizedBox(height: AppSpacing.space16),
                    _audioCard(data.muted),
                    const SizedBox(height: AppSpacing.space16),
                    _resetCard(),
                    const SizedBox(height: AppSpacing.space16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyCard() {
    return ChunkyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Belum ada sesi latihan',
              style: AppTypography.uiHeading(fontSize: 16.0)),
          const SizedBox(height: AppSpacing.space8),
          Text(
            'Mainkan minimal 1 latihan bersama anak agar statistik muncul di sini.',
            style: AppTypography.uiBody(
                fontSize: 13.0, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(ParentStats s) {
    return ChunkyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan',
              style: AppTypography.uiHeading(fontSize: 16.0)),
          const SizedBox(height: AppSpacing.space12),
          Row(
            children: [
              Expanded(child: _stat('Pelajaran terbuka', '${s.unlockedLessons}/44')),
              const SizedBox(width: AppSpacing.space8),
              Expanded(child: _stat('Item dilatih', '${s.trainedCount}')),
            ],
          ),
          const SizedBox(height: AppSpacing.space8),
          Row(
            children: [
              Expanded(child: _stat('Dikuasai', '${s.masteredCount}')),
              const SizedBox(width: AppSpacing.space8),
              Expanded(child: _stat(
                  'Akurasi', s.attemptsTotal == 0 ? '-' : '${(s.accuracy * 100).round()}%')),
            ],
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            'Jawaban benar ${s.correctTotal} dari ${s.attemptsTotal} percobaan.',
            style: AppTypography.uiBody(
                fontSize: 12.0, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.uiBody(
                fontSize: 11.0, color: AppColors.textSecondary)),
        Text(value, style: AppTypography.uiHeading(fontSize: 24.0)),
      ],
    );
  }

  Widget _zoneRow(String label, int trained, int total, int mastered,
      double accuracy, Color color) {
    final pct = total == 0 ? 0.0 : trained / total;
    return ChunkyCard(
      padding: const EdgeInsets.all(AppSpacing.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.uiButton(fontSize: 15.0)),
              Text('$trained/$total',
                  style: AppTypography.uiButton(fontSize: 15.0)),
            ],
          ),
          const SizedBox(height: 8.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10.0,
              backgroundColor: AppColors.cardBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Dikuasai $mastered · Akurasi ${trained == 0 ? '-' : '${(accuracy * 100).round()}%'}',
            style: AppTypography.uiBody(
                fontSize: 11.0, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _recommendationCard(ParentStats s) {
    final text = s.weakestZone == null
        ? 'Belum cukup data untuk rekomendasi. Lanjutkan 1 zona setiap hari.'
        : 'Zona ${s.weakestZone} memiliki akurasi terendah. Ajak anak mengulang 1 sesi pendek di zona tersebut.';
    return ChunkyCard(
      backgroundColor: AppColors.successBannerBg,
      child: Row(
        children: [
          const Icon(Icons.psychology_rounded,
              size: 36.0, color: AppColors.brandMintDark),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rekomendasi',
                    style: AppTypography.uiHeading(fontSize: 16.0)),
                Text(text,
                    style: AppTypography.uiBody(fontSize: 13.0)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeCard(int limit) {
    return ChunkyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Batas Waktu Layar',
              style: AppTypography.uiHeading(fontSize: 16.0)),
          Text(
            'Pengingat istirahat yang lembut untuk anak.',
            style: AppTypography.uiBody(
                fontSize: 12.0, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space12),
          Wrap(
            spacing: 8.0,
            children: [
              for (final o in _timeOptions)
                ChoiceChip(
                  label: Text('$o mnt'),
                  selected: limit == o,
                  onSelected: (_) => _setTimeLimit(o),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.space12),
          OutlinedButton.icon(
            onPressed: () => ScreenTimeDialog.show(context),
            icon: const Icon(Icons.bedtime_rounded),
            label: const Text('Pratinjau pengingat'),
          ),
        ],
      ),
    );
  }

  Widget _audioCard(bool muted) {
    return ChunkyCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Suara aplikasi',
                    style: AppTypography.uiHeading(fontSize: 16.0)),
                Text(
                  muted ? 'Nonaktif' : 'Aktif',
                  style: AppTypography.uiBody(
                      fontSize: 12.0, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(value: !muted, onChanged: (v) => _setMuted(!v)),
        ],
      ),
    );
  }

  Widget _resetCard() {
    return ChunkyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Data perangkat',
              style: AppTypography.uiHeading(fontSize: 16.0)),
          Text(
            'Hapus seluruh progres latihan di perangkat ini.',
            style: AppTypography.uiBody(
                fontSize: 12.0, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space12),
          OutlinedButton.icon(
            onPressed: _resetData,
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Hapus data'),
          ),
        ],
      ),
    );
  }
}
