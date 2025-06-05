import 'package:flutter/material.dart';
import '../../models/income_model.dart';
import '../../models/expense_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'analytics_screen.dart';

// Widget hiển thị phân tích theo tuần
class WeeklyAnalyticsView extends StatefulWidget {
  final List<dynamic> incomes; // Danh sách thu nhập
  final List<dynamic> expenses; // Danh sách chi tiêu

  const WeeklyAnalyticsView({
    super.key,
    required this.incomes,
    required this.expenses,
  });

  @override
  _WeeklyAnalyticsViewState createState() => _WeeklyAnalyticsViewState();
}

class _WeeklyAnalyticsViewState extends State<WeeklyAnalyticsView> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  // Phương thức hỗ trợ lọc các giao dịch trong tuần được chọn
  List<dynamic> _filterTransactionsForWeek(
    List<dynamic> transactions,
    DateTime selectedDay,
  ) {
    final startOfWeek = selectedDay.subtract(
      Duration(days: selectedDay.weekday - 1),
    );
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return transactions.where((transaction) {
      // Safely access date, check for null and correct type
      if (transaction == null) return false;

      DateTime? date;
      if (transaction is Income) date = transaction.date;
      if (transaction is Expense) date = transaction.date;

      if (date == null) return false; // Ensure date is available

      return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          date.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Lọc các giao dịch cho tuần được chọn
    final weeklyIncomes = _filterTransactionsForWeek(
      widget.incomes,
      selectedDate,
    );
    final weeklyExpenses = _filterTransactionsForWeek(
      widget.expenses,
      selectedDate,
    );

    // Kết hợp và sắp xếp các giao dịch theo ngày trong tuần cho biểu đồ
    final weeklyTransactions = [
      ...weeklyIncomes
          .where((inc) => inc != null && inc is Income)
          .map(
            (inc) => {
              'amount': (inc as Income).amount,
              'date': (inc as Income).date,
              'isIncome': true,
            },
          ),
      ...weeklyExpenses
          .where((exp) => exp != null && exp is Expense)
          .map(
            (exp) => {
              'amount': (exp as Expense).amount,
              'date': (exp as Expense).date,
              'isIncome': false,
            },
          ),
    ]..sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    // Nhóm các giao dịch theo ngày trong tuần và tính tổng cho mỗi ngày
    Map<int, double> incomeTotalsPerDay = {};
    Map<int, double> expenseTotalsPerDay = {};

    for (var transaction in weeklyTransactions) {
      final day = (transaction['date'] as DateTime)
          .weekday; // Thứ 2 là 1, Chủ nhật là 7
      if (transaction['isIncome'] as bool) {
        incomeTotalsPerDay[day] =
            (incomeTotalsPerDay[day] ?? 0) + (transaction['amount'] as double);
      } else {
        expenseTotalsPerDay[day] =
            (expenseTotalsPerDay[day] ?? 0) + (transaction['amount'] as double);
      }
    }

    // Tạo dữ liệu cho biểu đồ cột
    List<BarChartGroupData> barGroups = [];
    for (int i = 1; i <= 7; i++) {
      // Duyệt qua các ngày trong tuần (1 đến 7)
      final incomeAmount = incomeTotalsPerDay[i] ?? 0;
      final expenseAmount = expenseTotalsPerDay[i] ?? 0;

      barGroups.add(
        BarChartGroupData(
          x: i, // Sử dụng ngày trong tuần làm giá trị x
          barRods: [
            BarChartRodData(
              toY: incomeAmount,
              color: Colors.green,
              width: 15,
            ), // Thu nhập
            BarChartRodData(
              toY: expenseAmount, // Chi tiêu (hiển thị dương)
              color: Colors.red,
              width: 15,
            ),
          ],
        ),
      );
    }

    // Tính tổng thu nhập trong tuần
    final totalWeeklyIncome = weeklyIncomes.fold<double>(
      0,
      (sum, income) => sum + (income is Income ? income.amount : 0),
    );

    // Tính tổng chi tiêu trong tuần
    final totalWeeklyExpense = weeklyExpenses.fold<double>(
      0,
      (sum, expense) => sum + (expense is Expense ? expense.amount : 0),
    );

    // Tính số dư trong tuần
    final weeklyBalance = totalWeeklyIncome - totalWeeklyExpense;

    // Tính toán giá trị lớn nhất cho trục Y (chỉ cần xem xét giá trị dương)
    final maxY =
        (totalWeeklyIncome > totalWeeklyExpense
            ? totalWeeklyIncome
            : totalWeeklyExpense) *
        1.2;
    // minY là 0 vì chỉ hiển thị giá trị dương
    final minY = 0.0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Week of ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
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
                format: CalendarFormat.week,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Card tổng quan số dư trong tuần
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
                          'Weekly Balance', // Số dư trong tuần
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${weeklyBalance.toStringAsFixed(0)} VNĐ',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: weeklyBalance >= 0
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
                                'Income', // Thu nhập
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${totalWeeklyIncome.toStringAsFixed(0)} VNĐ',
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
                                '${totalWeeklyExpense.toStringAsFixed(0)} VNĐ',
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
                // Biểu đồ phân tích theo tuần
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AspectRatio(
                      aspectRatio:
                          1.7, // Điều chỉnh tỷ lệ khung hình giống các view khác
                      child: BarChart(
                        BarChartData(
                          barGroups: barGroups,
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 60, // Tăng kích thước cho trục Y
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  // Chỉ hiển thị giá trị tại các đường lưới và lớn hơn hoặc bằng 0
                                  if (value >= 0 && value % (maxY / 4) == 0) {
                                    return Text(
                                      value.toStringAsFixed(0),
                                      style: const TextStyle(fontSize: 10),
                                      textAlign: TextAlign.right,
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  // Hiển thị ngày trong tuần
                                  const days = [
                                    '',
                                    'Mon', // Thứ 2
                                    'Tue', // Thứ 3
                                    'Wed', // Thứ 4
                                    'Thu', // Thứ 5
                                    'Fri', // Thứ 6
                                    'Sat', // Thứ 7
                                    'Sun', // Chủ nhật
                                  ];
                                  return Text(
                                    days[value.toInt()],
                                    style: const TextStyle(fontSize: 10),
                                    textAlign: TextAlign.center,
                                  );
                                },
                                interval: 1,
                                reservedSize: 20,
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            drawHorizontalLine: true,
                            horizontalInterval: maxY == 0 ? 1.0 : maxY / 4,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey,
                                strokeWidth: 0.5,
                              );
                            },
                          ),
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxY,
                          minY: minY,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // TODO: Implement list of weekly transactions
                const Text(
                  'Weekly Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 16),
                // Thay thế placeholder bằng ListView hiển thị giao dịch chi tiết
                ListView.builder(
                  shrinkWrap:
                      true, // Quan trọng để ListView hoạt động trong SingleChildScrollView
                  physics:
                      NeverScrollableScrollPhysics(), // Tắt cuộn riêng của ListView
                  itemCount: weeklyTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = weeklyTransactions[index];
                    final date = transaction['date'] as DateTime;
                    final amount = transaction['amount'] as double;
                    final isIncome = transaction['isIncome'] as bool;

                    return ListTile(
                      leading: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                      title: Text(
                        '${date.day}/${date.month}/${date.year}', // Hiển thị ngày giao dịch
                        style: TextStyle(fontSize: 14),
                      ),
                      trailing: Text(
                        '${amount.toStringAsFixed(0)} VNĐ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isIncome ? Colors.green : Colors.red,
                        ),
                      ),
                      // Có thể thêm subtitle hoặc các thông tin khác nếu có
                      // subtitle: Text(transaction['description'] ?? ''), // Nếu có trường description
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
