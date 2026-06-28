// lib/presentation/widgets/dashboard/expense_chart.dart — rewrite bersih

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/dashboard_model.dart';

class ExpenseChart extends StatefulWidget {
  final List<ExpenseByCategoryModel> data;

  const ExpenseChart({super.key, required this.data});

  @override
  State<ExpenseChart> createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart> {
  int _touchedIndex = -1;

  static const List<Color> _palette = [
    Color(0xFF4E9AF1), // biru soft
    Color(0xFF56C596), // hijau mint
    Color(0xFFE8825A), // oranye terra
    Color(0xFFB57BED), // ungu lavender
    Color(0xFFF0C93A), // kuning amber
    Color(0xFF5BC8D5), // teal
    Color(0xFFE87BA0), // pink muted
    Color(0xFF8EB4E3), // biru muda
    Color(0xFF7ED9A0), // hijau muda
    Color(0xFFD4956A), // coklat kayu
  ];

  Color _colorFor(int index) => _palette[index % _palette.length];

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'Belum ada pengeluaran bulan ini',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
      );
    }

    final total = widget.data.fold<double>(0, (s, e) => s + e.total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pie chart — ukuran tetap, tidak pakai Stack dengan Positioned
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex =
                        response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: widget.data.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final isTouched = i == _touchedIndex;
                final color = _colorFor(i);
                final pct = (item.total / total * 100);

                return PieChartSectionData(
                  color: color,
                  value: item.total,
                  // Persentase di dalam slice jika cukup besar
                  title: pct >= 10
                      ? '${pct.toStringAsFixed(0)}%'
                      : '',
                  radius: isTouched ? 88 : 75,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black38, blurRadius: 3),
                    ],
                  ),
                );
              }).toList(),
              centerSpaceRadius: 38,
              sectionsSpace: 2,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Legend di bawah chart — bukan di samping
        // Ini lebih reliabel daripada label mengambang
        _buildLegend(total),

        // Detail card saat ada yang di-tap
        if (_touchedIndex >= 0 &&
            _touchedIndex < widget.data.length) ...[
          const SizedBox(height: 12),
          _buildTouchedDetail(
            widget.data[_touchedIndex],
            _colorFor(_touchedIndex),
            total,
          ),
        ],
      ],
    );
  }

  Widget _buildLegend(double total) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: widget.data.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        final isTouched = i == _touchedIndex;
        final color = _colorFor(i);
        final pct = (item.total / total * 100).toStringAsFixed(0);

        return GestureDetector(
          onTap: () => setState(() {
            _touchedIndex = _touchedIndex == i ? -1 : i;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isTouched
                  ? color.withOpacity(0.15)
                  : AppColors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: isTouched ? color : AppColors.border,
                width: isTouched ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${item.categoryName} $pct%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isTouched
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: isTouched ? color : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTouchedDetail(
    ExpenseByCategoryModel item,
    Color color,
    double total,
  ) {
    final pct = (item.total / total * 100).toStringAsFixed(1);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.categoryName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(item.total),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$pct% dari total',
                style: AppTextStyles.label,
              ),
            ],
          ),
        ],
      ),
    );
  }
}