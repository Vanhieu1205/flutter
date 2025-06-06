import 'package:flutter/material.dart';
import '../../models/income_model.dart' as income;
import '../../models/expense_model.dart' as expense;
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'analytics_screen.dart';
import 'package:intl/intl.dart';

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
  late DateTime selectedDate; // Use single selectedDate like Daily

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now(); // Initialize with current date
  }

  // Phương thức hỗ trợ lọc các giao dịch trong tuần được chọn
  List<dynamic> _filterTransactionsForWeek(
    List<dynamic> transactions,
    DateTime dayInWeek, // Use a day within the target week
  ) {
    final startOfWeek = dayInWeek.subtract(
      Duration(days: dayInWeek.weekday - 1), // Monday is 1, Sunday is 7
    );
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return transactions.where((transaction) {
      if (transaction == null) return false;

      DateTime? date;
      if (transaction is income.Income) date = transaction.date;
      if (transaction is expense.Expense) date = transaction.date;

      if (date == null) return false;

      // Filter transactions within the calculated week range
      // Add a small duration to endOfWeek to include transactions on the last day
      return date.isAfter(
            startOfWeek.subtract(const Duration(microseconds: 1)),
          ) &&
          date.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Lọc các giao dịch cho tuần được chọn dựa trên selectedDate
    final weeklyIncomes = _filterTransactionsForWeek(
      widget.incomes,
      selectedDate,
    );
    final weeklyExpenses = _filterTransactionsForWeek(
      widget.expenses,
      selectedDate,
    );

    // Combine and sort transactions for the chart and list
    final weeklyTransactions = [
      ...weeklyIncomes
          .where((inc) => inc != null && inc is income.Income)
          .map(
            (inc) => {
              'amount': (inc as income.Income).amount,
              'date': (inc as income.Income).date,
              'isIncome': true,
              'description':
                  (inc as income.Income).description, // Include description
            },
          ),
      ...weeklyExpenses
          .where((exp) => exp != null && exp is expense.Expense)
          .map(
            (exp) => {
              'amount': (exp as expense.Expense).amount,
              'date': (exp as expense.Expense).date,
              'isIncome': false,
              'description':
                  (exp as expense.Expense).description, // Include description
            },
          ),
    ]..sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    // Group transactions by day of the week and calculate totals for the chart
    Map<int, double> incomeTotalsPerDay = {};
    Map<int, double> expenseTotalsPerDay = {};

    // Initialize totals for all days of the week
    for (int i = 1; i <= 7; i++) {
      incomeTotalsPerDay[i] = 0.0;
      expenseTotalsPerDay[i] = 0.0;
    }

    for (var transaction in weeklyTransactions) {
      final date = transaction['date'] as DateTime;
      // Adjust weekday to start from 1 for Monday to 7 for Sunday for chart
      final day = date.weekday;
      if (transaction['isIncome'] as bool) {
        incomeTotalsPerDay[day] =
            (incomeTotalsPerDay[day] ?? 0) + (transaction['amount'] as double);
      } else {
        expenseTotalsPerDay[day] =
            (expenseTotalsPerDay[day] ?? 0) + (transaction['amount'] as double);
      }
    }

    // Create data for the bar chart
    List<BarChartGroupData> barGroups = [];
    for (int i = 1; i <= 7; i++) {
      // Iterate through days of the week (1 to 7)
      final incomeAmount = incomeTotalsPerDay[i] ?? 0;
      final expenseAmount = expenseTotalsPerDay[i] ?? 0;

      barGroups.add(
        BarChartGroupData(
          x: i, // Use weekday as x value (1 for Mon, 7 for Sun)
          barRods: [
            BarChartRodData(
              toY: incomeAmount,
              color: Colors.green,
              width: 15,
            ), // Income
            BarChartRodData(
              toY: expenseAmount, // Expense (display as positive)
              color: Colors.red,
              width: 15,
            ), // Expense
          ],
          barsSpace: 2, // Space between income and expense bars
        ),
      );
    }

    // Calculate weekly totals
    final totalWeeklyIncome = weeklyIncomes.fold<double>(
      0,
      (sum, item) => sum + (item is income.Income ? item.amount : 0),
    );

    final totalWeeklyExpense = weeklyExpenses.fold<double>(
      0,
      (sum, item) => sum + (item is expense.Expense ? item.amount : 0),
    );

    // Calculate weekly balance
    final weeklyBalance = totalWeeklyIncome - totalWeeklyExpense;

    // Calculate max value for Y axis (only consider positive values)
    final maxY =
        (totalWeeklyIncome > totalWeeklyExpense
            ? totalWeeklyIncome
            : totalWeeklyExpense) *
        1.2;
    // minY is 0 as we are only showing positive values
    final minY = 0.0;

    // Calculate interval for approximately 4 intervals (5 labels including 0 and maxY)
    final interval = (maxY / 4) > 0 ? (maxY / 4) : 1.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Background color for the rounded container
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0), // Rounded top-left corner
          topRight: Radius.circular(20.0), // Rounded top-right corner
        ),
      ),
      clipBehavior: Clip.antiAlias, // Clip content to the rounded corners
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Display the week range
                Text(
                  'Week of ${DateFormat('dd/MM/yyyy').format(selectedDate.subtract(Duration(days: selectedDate.weekday - 1)))} - ${DateFormat('dd/MM/yyyy').format(selectedDate.add(Duration(days: 7 - selectedDate.weekday)))}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Calendar Button for Week selection
                CalendarButton(
                  selectedDate: selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      selectedDate = date; // Update selected date
                    });
                  },
                  format: CalendarFormat.week, // Set format to week
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Weekly Summary Cards
                  _buildSummaryCard(
                    'Weekly Balance',
                    NumberFormat.currency(
                      locale: 'vi_VN',
                      symbol: 'VNĐ',
                    ).format(weeklyBalance),
                    weeklyBalance >= 0 ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Income',
                          NumberFormat.currency(
                            locale: 'vi_VN',
                            symbol: 'VNĐ',
                          ).format(totalWeeklyIncome),
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          'Expense',
                          NumberFormat.currency(
                            locale: 'vi_VN',
                            symbol: 'VNĐ',
                          ).format(totalWeeklyExpense),
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Weekly Bar Chart
                  Card(
                    elevation: 4,
                    color: const Color(0xFFDFF7E2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AspectRatio(
                        aspectRatio: 1.7,
                        child: BarChart(
                          BarChartData(
                            barGroups: barGroups,
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  interval: interval,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    // Format the value with thousand separators
                                    final formatter = NumberFormat(
                                      '#,###',
                                      'vi_VN',
                                    );

                                    // Simply return the formatted text widget for the value provided by the library
                                    return Text(
                                      formatter.format(value),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const days = [
                                      '',
                                      'Mon',
                                      'Tue',
                                      'Wed',
                                      'Thu',
                                      'Fri',
                                      'Sat',
                                      'Sun',
                                    ];
                                    if (value.toInt() >= 1 &&
                                        value.toInt() <= 7) {
                                      return Text(
                                        days[value.toInt()],
                                        style: const TextStyle(fontSize: 10),
                                        textAlign: TextAlign.center,
                                      );
                                    }
                                    return const SizedBox.shrink();
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
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              drawHorizontalLine: true,
                              horizontalInterval: interval,
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
                  // Weekly Transactions List
                  const Text(
                    'Weekly Transactions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: weeklyTransactions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final transaction = weeklyTransactions[index];
                      return _buildTransactionCard(
                        transaction,
                      ); // Use helper method
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for summary cards (balance, income, expense)
  Widget _buildSummaryCard(String title, String amount, Color color) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for individual transaction cards
  Widget _buildTransactionCard(dynamic transaction) {
    final isIncome = transaction['isIncome'] as bool; // Check from map
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
                  transaction['description']
                      as String, // Use description from map
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(
                    transaction['date'] as DateTime,
                  ), // Use date from map
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
