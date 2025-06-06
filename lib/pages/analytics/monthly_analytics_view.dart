import 'package:flutter/material.dart';
import '../../models/income_model.dart';
import '../../models/expense_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'analytics_screen.dart';
import 'package:intl/intl.dart';

// Widget hiển thị phân tích theo tháng
class MonthlyAnalyticsView extends StatefulWidget {
  final List<dynamic> incomes; // Danh sách thu nhập
  final List<dynamic> expenses; // Danh sách chi tiêu

  const MonthlyAnalyticsView({
    super.key,
    required this.incomes,
    required this.expenses,
  });

  @override
  _MonthlyAnalyticsViewState createState() => _MonthlyAnalyticsViewState();
}

class _MonthlyAnalyticsViewState extends State<MonthlyAnalyticsView> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  // Phương thức hỗ trợ lọc các giao dịch trong tháng được chọn
  List<dynamic> _filterTransactionsForMonth(
    List<dynamic> transactions,
    DateTime selectedDay,
  ) {
    final endOfMonth = DateTime(selectedDay.year, selectedDay.month + 1, 0);

    return transactions.where((transaction) {
      // Lọc giao dịch chỉ trong tháng được chọn
      final date = (transaction as dynamic).date;
      return date.year == selectedDay.year && date.month == selectedDay.month;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Lọc các giao dịch cho tháng được chọn
    final monthlyIncomes = _filterTransactionsForMonth(
      widget.incomes,
      selectedDate,
    );
    final monthlyExpenses = _filterTransactionsForMonth(
      widget.expenses,
      selectedDate,
    );

    // Kết hợp các giao dịch trong tháng
    final monthlyTransactions = [
      ...monthlyIncomes.map(
        (inc) => {
          'amount': (inc as dynamic).amount,
          'date': (inc as dynamic).date,
          'isIncome': true,
          'description': (inc as dynamic).description,
        },
      ),
      ...monthlyExpenses.map(
        (exp) => {
          'amount': (exp as dynamic).amount,
          'date': (exp as dynamic).date,
          'isIncome': false,
          'description': (exp as dynamic).description,
        },
      ),
    ];

    // Nhóm các giao dịch theo ngày trong tháng và tính tổng cho mỗi ngày
    Map<int, double> incomeTotalsPerDay = {};
    Map<int, double> expenseTotalsPerDay = {};

    for (var transaction in monthlyTransactions) {
      final day = (transaction['date'] as DateTime).day;
      if (transaction['isIncome']) {
        incomeTotalsPerDay[day] =
            (incomeTotalsPerDay[day] ?? 0) + transaction['amount'];
      } else {
        expenseTotalsPerDay[day] =
            (expenseTotalsPerDay[day] ?? 0) + transaction['amount'];
      }
    }

    // Xác định số ngày trong tháng hiện tại
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    // Tạo dữ liệu cho biểu đồ cột
    List<BarChartGroupData> barGroups = [];
    for (int i = 1; i <= daysInMonth; i++) {
      final incomeAmount = incomeTotalsPerDay[i] ?? 0;
      final expenseAmount = expenseTotalsPerDay[i] ?? 0;

      barGroups.add(
        BarChartGroupData(
          x: i, // Sử dụng ngày trong tháng làm giá trị x
          barRods: [
            BarChartRodData(
              toY: incomeAmount,
              color: Colors.green,
              width: 5,
            ), // Thu nhập
            BarChartRodData(
              toY: expenseAmount, // Chi tiêu (hiển thị dương)
              color: Colors.red,
              width: 5,
            ),
          ],
        ),
      );
    }

    // Tính tổng thu nhập trong tháng
    final totalMonthlyIncome = monthlyIncomes.fold<double>(
      0,
      (sum, income) => sum + (income as dynamic).amount,
    );

    // Tính tổng chi tiêu trong tháng
    final totalMonthlyExpense = monthlyExpenses.fold<double>(
      0,
      (sum, expense) => sum + (expense as dynamic).amount,
    );

    // Tính số dư trong tháng
    final monthlyBalance = totalMonthlyIncome - totalMonthlyExpense;

    // Tính toán giá trị lớn nhất cho trục Y (chỉ cần xem xét giá trị dương)
    final double maxY =
        (totalMonthlyIncome > totalMonthlyExpense
            ? totalMonthlyIncome
            : totalMonthlyExpense) *
        1.2;
    // minY là 0 vì chỉ hiển thị giá trị dương
    final double minY = 0.0;

    // Tính toán 4 mốc giá trị cho đường lưới ngang dựa trên phạm vi trục Y
    // Không cần tính các mốc trung gian nếu chỉ hiển thị 4 đường lưới chính

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${selectedDate.month}/${selectedDate.year}',
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
                format: CalendarFormat.month,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Card tổng quan số dư trong tháng
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
                          'Monthly Balance', // Số dư trong tháng
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${monthlyBalance.toStringAsFixed(0)} VNĐ',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: monthlyBalance >= 0
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
                                'Income', // Thu nhập
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${totalMonthlyIncome.toStringAsFixed(0)} VNĐ',
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
                                'Expense', // Chi tiêu
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${totalMonthlyExpense.toStringAsFixed(0)} VNĐ',
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
                const SizedBox(height: 16),
                // Biểu đồ phân tích theo tháng
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AspectRatio(
                      aspectRatio: 1.7, // Adjust this ratio as needed
                      child: BarChart(
                        BarChartData(
                          barGroups: barGroups,
                          titlesData: FlTitlesData(
                            // Cấu hình trục Y bên trái
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 50,
                                getTitlesWidget: (value, meta) {
                                  // Tính toán maxY, minY và interval
                                  final calculatedMaxY =
                                      (totalMonthlyIncome > totalMonthlyExpense
                                          ? totalMonthlyIncome
                                          : totalMonthlyExpense) *
                                      1.2;
                                  // Đảm bảo interval không bằng 0 để tránh lỗi chia cho 0
                                  final interval = (calculatedMaxY / 4) > 0
                                      ? (calculatedMaxY / 4)
                                      : 1.0;

                                  // Kiểm tra xem giá trị có đủ gần với một bội số của interval (tính từ minY) hay không
                                  // Đây là cách chính xác hơn để kiểm tra vị trí trên lưới
                                  bool isCloseToGrid = false;
                                  if (interval > 0) {
                                    final ratio = (value - minY) / interval;
                                    const double epsilon =
                                        0.01; // Ngưỡng sai số nhỏ
                                    // Kiểm tra xem tỉ lệ có đủ gần với một số nguyên không
                                    if ((ratio - ratio.round()).abs() <
                                        epsilon) {
                                      isCloseToGrid = true;
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
                            // Cấu hình trục X phía dưới
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() % 5 == 0) {
                                    // Hiển thị mỗi 5 ngày để dễ đọc
                                    return Text(
                                      value.toInt().toString(),
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
                // Monthly Transactions List
                const Text(
                  'Monthly Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: monthlyTransactions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final transaction = monthlyTransactions[index];
                    return _buildTransactionCard(transaction);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper method for individual transaction cards
  Widget _buildTransactionCard(dynamic transaction) {
    final isIncome = transaction['isIncome'] as bool;
    final icon = isIncome ? Icons.arrow_upward : Icons.arrow_downward;
    final color = isIncome ? Colors.green : Colors.red;
    final amount = isIncome
        ? '+${NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(transaction['amount'])}'
        : '-${NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(transaction['amount'])}';

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
                  transaction['description'] ?? 'No description',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat(
                    'dd/MM/yyyy',
                  ).format(transaction['date'] as DateTime),
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
