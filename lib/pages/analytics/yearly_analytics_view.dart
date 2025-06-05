import 'package:flutter/material.dart';
import '../../models/income_model.dart';
import '../../models/expense_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'analytics_screen.dart';

// Widget hiển thị phân tích theo năm
class YearlyAnalyticsView extends StatefulWidget {
  final List<dynamic> incomes; // Danh sách thu nhập
  final List<dynamic> expenses; // Danh sách chi tiêu

  const YearlyAnalyticsView({
    super.key,
    required this.incomes,
    required this.expenses,
  });

  @override
  _YearlyAnalyticsViewState createState() => _YearlyAnalyticsViewState();
}

class _YearlyAnalyticsViewState extends State<YearlyAnalyticsView> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  // Phương thức hỗ trợ lọc các giao dịch trong năm được chọn
  List<dynamic> _filterTransactionsForYear(
    List<dynamic> transactions,
    DateTime selectedDay,
  ) {
    final startOfYear = DateTime(selectedDay.year, 1, 1);
    final endOfYear = DateTime(selectedDay.year, 12, 31);

    return transactions.where((transaction) {
      final date = (transaction as dynamic).date;
      return date.isAfter(startOfYear.subtract(const Duration(days: 1))) &&
          date.isBefore(endOfYear.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Lọc các giao dịch cho năm được chọn
    final yearlyIncomes = _filterTransactionsForYear(
      widget.incomes,
      selectedDate,
    );
    final yearlyExpenses = _filterTransactionsForYear(
      widget.expenses,
      selectedDate,
    );

    // Kết hợp các giao dịch trong năm
    final yearlyTransactions = [
      ...yearlyIncomes.map(
        (inc) => {
          'amount': (inc as dynamic).amount,
          'date': (inc as dynamic).date,
          'isIncome': true,
        },
      ),
      ...yearlyExpenses.map(
        (exp) => {
          'amount': (exp as dynamic).amount,
          'date': (exp as dynamic).date,
          'isIncome': false,
        },
      ),
    ];

    // Nhóm các giao dịch theo tháng và tính tổng cho mỗi tháng
    Map<int, double> incomeTotalsPerMonth = {};
    Map<int, double> expenseTotalsPerMonth = {};

    for (var transaction in yearlyTransactions) {
      final month = (transaction['date'] as DateTime).month;
      if (transaction['isIncome']) {
        incomeTotalsPerMonth[month] =
            (incomeTotalsPerMonth[month] ?? 0) + transaction['amount'];
      } else {
        expenseTotalsPerMonth[month] =
            (expenseTotalsPerMonth[month] ?? 0) + transaction['amount'];
      }
    }

    // Tạo dữ liệu cho biểu đồ cột
    List<BarChartGroupData> barGroups = [];
    for (int i = 1; i <= 12; i++) {
      // Duyệt qua các tháng (1 đến 12)
      final incomeAmount = incomeTotalsPerMonth[i] ?? 0;
      final expenseAmount = expenseTotalsPerMonth[i] ?? 0;

      barGroups.add(
        BarChartGroupData(
          x: i, // Sử dụng tháng làm giá trị x
          barRods: [
            BarChartRodData(
              toY: incomeAmount,
              color: Colors.green,
              width: 10,
            ), // Thu nhập
            BarChartRodData(
              toY: expenseAmount, // Chi tiêu (hiển thị dương)
              color: Colors.red,
              width: 10,
            ),
          ],
        ),
      );
    }

    // Tính tổng thu nhập trong năm
    final totalYearlyIncome = yearlyIncomes.fold<double>(
      0,
      (sum, income) => sum + (income as dynamic).amount,
    );

    // Tính tổng chi tiêu trong năm
    final totalYearlyExpense = yearlyExpenses.fold<double>(
      0,
      (sum, expense) => sum + (expense as dynamic).amount,
    );

    // Tính số dư trong năm
    final yearlyBalance = totalYearlyIncome - totalYearlyExpense;

    // Tính toán giá trị lớn nhất cho trục Y (chỉ cần xem xét giá trị dương)
    final double maxY =
        (totalYearlyIncome > totalYearlyExpense
            ? totalYearlyIncome
            : totalYearlyExpense) *
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
                '${selectedDate.year}',
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
                // Card tổng quan số dư trong năm
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
                          'Yearly Balance', // Số dư trong năm
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${yearlyBalance.toStringAsFixed(0)} VNĐ',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: yearlyBalance >= 0
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
                                '${totalYearlyIncome.toStringAsFixed(0)} VNĐ',
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
                                '${totalYearlyExpense.toStringAsFixed(0)} VNĐ',
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
                // Biểu đồ phân tích theo năm
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
                                  // Hiển thị số tháng
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(fontSize: 10),
                                    textAlign: TextAlign.center,
                                  );
                                },
                                interval: 1,
                                reservedSize: 20,
                              ),
                            ),
                            // Ẩn trục trên và phải
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
                              color: Colors.grey[300]!,
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
                                color: Colors.grey[300]!,
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
                // TODO: Implement list of yearly transactions
                // const Text(
                //   'Yearly Transactions',
                //   style: TextStyle(
                //     fontSize: 18,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.teal,
                //   ),
                // ),
                // const SizedBox(height: 16),
                // const Center(child: Text('List of yearly transactions placeholder')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
