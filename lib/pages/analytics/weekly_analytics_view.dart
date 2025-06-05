import 'package:flutter/material.dart';
import '../../models/income_model.dart';
import '../../models/expense_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';

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
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
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
      final date = (transaction as dynamic).date;
      return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          date.isBefore(endOfWeek.add(const Duration(days: 1)));
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
    // Lọc các giao dịch cho tuần được chọn
    final weeklyIncomes = _filterTransactionsForWeek(
      widget.incomes,
      _selectedDay ?? DateTime.now(),
    );
    final weeklyExpenses = _filterTransactionsForWeek(
      widget.expenses,
      _selectedDay ?? DateTime.now(),
    );

    // Kết hợp và sắp xếp các giao dịch theo ngày trong tuần cho biểu đồ
    final weeklyTransactions = [
      ...weeklyIncomes.map(
        (inc) => {
          'amount': (inc as dynamic).amount,
          'date': (inc as dynamic).date,
          'isIncome': true,
        },
      ),
      ...weeklyExpenses.map(
        (exp) => {
          'amount': (exp as dynamic).amount,
          'date': (exp as dynamic).date,
          'isIncome': false,
        },
      ),
    ];

    // Nhóm các giao dịch theo ngày trong tuần và tính tổng cho mỗi ngày
    Map<int, double> incomeTotalsPerDay = {};
    Map<int, double> expenseTotalsPerDay = {};

    for (var transaction in weeklyTransactions) {
      final day = (transaction['date'] as DateTime)
          .weekday; // Thứ 2 là 1, Chủ nhật là 7
      if (transaction['isIncome']) {
        incomeTotalsPerDay[day] =
            (incomeTotalsPerDay[day] ?? 0) + transaction['amount'];
      } else {
        expenseTotalsPerDay[day] =
            (expenseTotalsPerDay[day] ?? 0) + transaction['amount'];
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
      (sum, income) => sum + (income as dynamic).amount,
    );

    // Tính tổng chi tiêu trong tuần
    final totalWeeklyExpense = weeklyExpenses.fold<double>(
      0,
      (sum, expense) => sum + (expense as dynamic).amount,
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  '${weeklyBalance.toStringAsFixed(0)} VNĐ',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: weeklyBalance >= 0 ? Colors.green : Colors.red,
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
                        '${totalWeeklyExpense.toStringAsFixed(0)} VNĐ',
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
        // Biểu đồ phân tích theo tuần
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
        // const SizedBox(height: 24),
        // // TODO: Implement list of weekly transactions
        // const Text(
        //   'Weekly Transactions',
        //   style: TextStyle(
        //     fontSize: 18,
        //     fontWeight: FontWeight.bold,
        //     color: Colors.teal,
        //   ),
        // ),
        // const SizedBox(height: 16),
        // const Center(child: Text('List of weekly transactions placeholder')),
      ],
    );
  }
}
