import 'package:flutter/material.dart';
import '../../models/income_model.dart';
import '../../models/expense_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';

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
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // Phương thức hỗ trợ lọc các giao dịch trong tháng được chọn
  List<dynamic> _filterTransactionsForMonth(
    List<dynamic> transactions,
    DateTime selectedDay,
  ) {
    final startOfMonth = DateTime(selectedDay.year, selectedDay.month, 1);
    final endOfMonth = DateTime(selectedDay.year, selectedDay.month + 1, 0);

    return transactions.where((transaction) {
      final date = (transaction as dynamic).date;
      return date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          date.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lọc các giao dịch cho tháng được chọn
    final monthlyIncomes = _filterTransactionsForMonth(
      widget.incomes,
      _selectedDay ?? DateTime.now(),
    );
    final monthlyExpenses = _filterTransactionsForMonth(
      widget.expenses,
      _selectedDay ?? DateTime.now(),
    );

    // Kết hợp các giao dịch trong tháng
    final monthlyTransactions = [
      ...monthlyIncomes.map(
        (inc) => {
          'amount': (inc as dynamic).amount,
          'date': (inc as dynamic).date,
          'isIncome': true,
        },
      ),
      ...monthlyExpenses.map(
        (exp) => {
          'amount': (exp as dynamic).amount,
          'date': (exp as dynamic).date,
          'isIncome': false,
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Add TableCalendar here
        TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: _onDaySelected,
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.tealAccent,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.teal,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
        const SizedBox(height: 16),
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  '${monthlyBalance.toStringAsFixed(0)} VNĐ',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: monthlyBalance >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Biểu đồ phân tích theo tháng
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
                    // Cấu hình trục Y bên trái
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          // Chỉ hiển thị giá trị tại các đường lưới và lớn hơn hoặc bằng 0
                          if (value >= 0 && value % (maxY / 4) == 0) {
                            // Chia thành 4 khoảng từ 0 đến maxY
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
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    drawHorizontalLine: true,
                    horizontalInterval: maxY == 0
                        ? 1.0
                        : maxY / 4, // Đảm bảo interval không bằng 0
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: Colors.grey[300]!, strokeWidth: 0.5);
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
                        '${totalMonthlyIncome.toStringAsFixed(0)} VNĐ',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
        // TODO: Implement list of monthly transactions
        // const Text(
        //   'Monthly Transactions',
        //   style: TextStyle(
        //     fontSize: 18,
        //     fontWeight: FontWeight.bold,
        //     color: Colors.teal,
        //   ),
        // ),
        // const SizedBox(height: 16),
        // const Center(child: Text('List of monthly transactions placeholder')),
      ],
    );
  }
}
