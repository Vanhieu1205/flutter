import 'package:flutter/material.dart';
import '../../models/income_model.dart';
import '../../models/expense_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'analytics_screen.dart';
import 'package:intl/intl.dart';

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

    // Kết hợp và sắp xếp các giao dịch theo thời gian cho biểu đồ và danh sách chi tiết
    final allDailyTransactions = [
      ...dailyIncomes.map(
        (inc) => {
          'amount': (inc as dynamic).amount,
          'date': (inc as dynamic).date,
          'isIncome': true,
          'original': inc, // Keep a reference to the original object
        },
      ),
      ...dailyExpenses.map(
        (exp) => {
          'amount': (exp as dynamic).amount,
          'date': (exp as dynamic).date,
          'isIncome': false,
          'original': exp, // Keep a reference to the original object
        },
      ),
    ]..sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    // Tạo dữ liệu cho biểu đồ cột (sử dụng allDailyTransactions)
    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < allDailyTransactions.length; i++) {
      final transaction = allDailyTransactions[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: transaction['amount'],
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
    final minY = 0.0;

    // Calculate horizontal interval for approximately 4 grid lines
    final interval = maxY / 4;
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
                                reservedSize: 50,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  // Tính toán maxY, minY và interval
                                  final calculatedMaxY =
                                      (totalDailyIncome > totalDailyExpense
                                          ? totalDailyIncome
                                          : totalDailyExpense) *
                                      1.2;
                                  // Đảm bảo interval không bằng 0 để tránh lỗi chia cho 0
                                  final interval = (calculatedMaxY / 4) > 0
                                      ? (calculatedMaxY / 4)
                                      : 1.0;

                                  // Kiểm tra xem giá trị có đủ gần với một bội số của interval (tính từ minY) hay không
                                  const double epsilon = 0.01; // Ngưỡng sai số
                                  bool isCloseToGrid = false;
                                  if (interval > 0) {
                                    // Iterate through potential grid line multiples
                                    for (int i = 0; ; i++) {
                                      final expectedValue = minY + i * interval;
                                      if ((value - expectedValue).abs() <
                                          epsilon) {
                                        isCloseToGrid = true;
                                        break;
                                      }
                                      // Stop if we've gone past the max value
                                      if (expectedValue >
                                          calculatedMaxY + epsilon) {
                                        break;
                                      }
                                    }
                                  }

                                  // Hiển thị nhãn nếu giá trị đủ gần với một đường lưới
                                  if (isCloseToGrid) {
                                    return Text(
                                      value.toStringAsFixed(
                                        0,
                                      ), // Định dạng số nguyên
                                      style: const TextStyle(fontSize: 10),
                                      textAlign: TextAlign.right, // Căn phải
                                    );
                                  }
                                  return const SizedBox.shrink(); // Sử dụng SizedBox.shrink()
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() <
                                      allDailyTransactions.length) {
                                    final transactionTime =
                                        (allDailyTransactions[value
                                                .toInt()]['date']
                                            as DateTime);
                                    return Text(
                                      '${transactionTime.hour}:${transactionTime.minute.toString().padLeft(2, '0')}',
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
                            border: Border.all(color: Colors.grey, width: 1),
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
                const SizedBox(height: 24),
                // Daily Transactions List
                const Text(
                  'Daily Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allDailyTransactions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final transactionMap = allDailyTransactions[index];
                    // Pass the original transaction object to the helper method
                    final originalTransaction = transactionMap['original'];
                    if (originalTransaction != null) {
                      return _buildTransactionCard(originalTransaction);
                    } else {
                      return Container(); // Handle case where original object is missing
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(dynamic transaction) {
    final isIncome = transaction is Income;
    final icon = isIncome ? Icons.arrow_upward : Icons.arrow_downward;
    final color = isIncome ? Colors.green : Colors.red;
    final amount = isIncome
        ? '+${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(transaction.amount)}'
        : '-${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(transaction.amount)}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(transaction.date),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
