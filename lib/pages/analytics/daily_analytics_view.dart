import 'package:flutter/material.dart';
import '../../models/income_model.dart';
import '../../models/expense_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'analytics_screen.dart';

// Widget hiển thị phân tích theo ngày
class DailyAnalyticsView extends StatefulWidget {
  final List<dynamic> incomes; // Danh sách thu nhập
  final List<dynamic> expenses; // Danh sách chi tiêu

  const DailyAnalyticsView({
    super.key,
    required this.incomes,
    required this.expenses,
  });

  @override
  _DailyAnalyticsViewState createState() => _DailyAnalyticsViewState();
}

class _DailyAnalyticsViewState extends State<DailyAnalyticsView> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  // Phương thức hỗ trợ lọc các giao dịch trong ngày được chọn
  List<dynamic> _filterTransactionsForSelectedDay(
    List<dynamic> transactions,
    DateTime selectedDay,
  ) {
    final targetDay = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );

    return transactions
        .where(
          (transaction) =>
              (transaction as dynamic).date.year == targetDay.year &&
              (transaction as dynamic).date.month == targetDay.month &&
              (transaction as dynamic).date.day == targetDay.day,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Lọc các giao dịch cho ngày được chọn
    final dailyIncomes = _filterTransactionsForSelectedDay(
      widget.incomes,
      selectedDate,
    );
    final dailyExpenses = _filterTransactionsForSelectedDay(
      widget.expenses,
      selectedDate,
    );

    // Kết hợp và sắp xếp các giao dịch theo thời gian cho biểu đồ
    final dailyTransactions = [
      ...dailyIncomes.map(
        (inc) => {
          'amount': (inc as dynamic).amount,
          'date': (inc as dynamic).date,
          'isIncome': true,
        },
      ),
      ...dailyExpenses.map(
        (exp) => {
          'amount': (exp as dynamic).amount,
          'date': (exp as dynamic).date,
          'isIncome': false,
        },
      ),
    ]..sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    // Tạo dữ liệu cho biểu đồ cột
    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < dailyTransactions.length; i++) {
      final transaction = dailyTransactions[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: transaction['amount'], // Luôn hiển thị giá trị dương
              color: transaction['isIncome'] ? Colors.green : Colors.red,
              width: 15,
            ),
          ],
        ),
      );
    }

    // Tính tổng thu nhập trong ngày
    final totalDailyIncome = dailyIncomes.fold<double>(
      0,
      (sum, income) => sum + (income as dynamic).amount,
    );

    // Tính tổng chi tiêu trong ngày
    final totalDailyExpense = dailyExpenses.fold<double>(
      0,
      (sum, expense) => sum + (expense as dynamic).amount,
    );

    // Tính số dư trong ngày
    final dailyBalance = totalDailyIncome - totalDailyExpense;

    // Tính toán giá trị cho trục Y
    final maxY =
        (totalDailyIncome > totalDailyExpense
            ? totalDailyIncome
            : totalDailyExpense) *
        1.2;
    // Set minY to 0 as we are only showing positive values
    final minY = 0.0;

    // Calculate horizontal interval for approximately 4 grid lines
    final interval = maxY / 4; // Chia thành 4 khoảng từ 0 đến maxY
    final horizontalInterval = interval == 0 ? 10.0 : interval;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CalendarButton(
                selectedDate: selectedDate,
                onDateSelected: (date) {
                  setState(() {
                    selectedDate = date;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Card tổng quan số dư trong ngày
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Balance',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${dailyBalance.toStringAsFixed(0)} VNĐ',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: dailyBalance >= 0
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Hàng hiển thị thu nhập và chi tiêu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Card thu nhập
                    Expanded(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Income',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${totalDailyIncome.toStringAsFixed(0)} VNĐ',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Card chi tiêu
                    Expanded(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expense',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${totalDailyExpense.toStringAsFixed(0)} VNĐ',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Biểu đồ phân tích theo ngày
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          barGroups: barGroups,
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  // Hiển thị nhãn cho các giá trị tại các khoảng lưới
                                  if (value >= 0 &&
                                      value % horizontalInterval == 0) {
                                    return Text(
                                      value.toStringAsFixed(0),
                                      style: const TextStyle(fontSize: 10),
                                      textAlign: TextAlign.right,
                                    );
                                  }
                                  // Không hiển thị nhãn cho các giá trị khác
                                  return const Text('');
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() <
                                      dailyTransactions.length) {
                                    final transactionTime =
                                        (dailyTransactions[value
                                                .toInt()]['date']
                                            as DateTime);
                                    return Text(
                                      '${transactionTime.hour}:${transactionTime.minute.toString().padLeft(2, '0')}\'',
                                      style: const TextStyle(fontSize: 10),
                                      textAlign: TextAlign.center,
                                    );
                                  }
                                  return Container();
                                },
                                reservedSize: 20,
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            drawHorizontalLine: true,
                            horizontalInterval: maxY == 0
                                ? 1.0
                                : maxY / 4, // Đảm bảo interval không bằng 0
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey,
                                strokeWidth: 0.5,
                              );
                            },
                          ),
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxY,
                          minY: minY, // minY là 0
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
