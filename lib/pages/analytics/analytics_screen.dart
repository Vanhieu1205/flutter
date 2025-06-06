import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../viewmodels/income_viewmodel.dart';
import '../../viewmodels/expense_viewmodel.dart';
import 'daily_analytics_view.dart'; // Import view phân tích theo ngày
import 'weekly_analytics_view.dart'; // Import view phân tích theo tuần
import 'monthly_analytics_view.dart'; // Import view phân tích theo tháng
import 'yearly_analytics_view.dart'; // Import view phân tích theo năm

class CalendarButton extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final CalendarFormat format;

  const CalendarButton({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.format = CalendarFormat.month,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.calendar_today),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: selectedDate,
                    calendarFormat: format,
                    selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      onDateSelected(selectedDay);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Widget chính cho màn hình phân tích
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Số lượng tab (Ngày, Tuần, Tháng, Năm)
      child: Scaffold(
        backgroundColor: const Color(
          0xFF3ACBAB,
        ), // Set background color to match AppBar
        appBar: AppBar(
          title: const Text('Analysis'), // Tiêu đề của AppBar
          backgroundColor: const Color(0xFF3ACBAB), // Màu nền của AppBar
          elevation: 0, // Remove the shadow line
          automaticallyImplyLeading: false, // Ẩn nút back trên màn hình chính
          centerTitle: true, // Căn giữa tiêu đề AppBar
          bottom: TabBar(
            // Tùy chỉnh style cho TabBar
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: Color(0xFF3ACBAB)),
            ), // Remove indicator line
            indicatorColor: Color(
              0xFF3ACBAB,
            ), // Make indicator color transparent to remove potential line
            labelColor: Colors.yellow, // Màu của tab được chọn
            unselectedLabelColor: Colors.black, // Màu của tab chưa được chọn
            tabs: const [
              Tab(text: 'Daily'), // Tab phân tích theo ngày
              Tab(text: 'Weekly'), // Tab phân tích theo tuần
              Tab(text: 'Monthly'), // Tab phân tích theo tháng
              Tab(text: 'Yearly'), // Tab phân tích theo năm
            ],
          ),
        ),
        // Sử dụng Consumer2 để lắng nghe thay đổi từ cả IncomeViewModel và ExpenseViewModel
        body: Consumer2<IncomeViewModel, ExpenseViewModel>(
          builder: (context, incomeViewModel, expenseViewModel, child) {
            // Hiển thị loading indicator khi đang tải dữ liệu
            if (incomeViewModel.isLoading || expenseViewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Tính tổng thu nhập
            final totalIncome = incomeViewModel.incomes.fold<double>(
              0,
              (sum, income) => sum + income.amount,
            );

            // Tính tổng chi tiêu
            final totalExpense = expenseViewModel.expenses.fold<double>(
              0,
              (sum, expense) => sum + expense.amount,
            );

            // Tính số dư tổng cộng
            final totalBalance = totalIncome - totalExpense;

            // Hiển thị nội dung tương ứng với từng tab
            return Column(
              children: [
                // TabBar đã nằm trong AppBar
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors
                          .white, // Background color for the rounded container
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          40.0,
                        ), // Increase radius to match image
                        topRight: Radius.circular(
                          40.0,
                        ), // Increase radius to match image
                      ),
                    ),
                    clipBehavior:
                        Clip.antiAlias, // Clip content to the rounded corners
                    child: TabBarView(
                      children: [
                        // Nội dung tab phân tích theo ngày
                        DailyAnalyticsView(
                          incomes: incomeViewModel.incomes,
                          expenses: expenseViewModel.expenses,
                        ),
                        // Nội dung tab phân tích theo tuần
                        WeeklyAnalyticsView(
                          incomes: incomeViewModel.incomes,
                          expenses: expenseViewModel.expenses,
                        ),
                        // Nội dung tab phân tích theo tháng
                        MonthlyAnalyticsView(
                          incomes: incomeViewModel.incomes,
                          expenses: expenseViewModel.expenses,
                        ),
                        // Nội dung tab phân tích theo năm
                        YearlyAnalyticsView(
                          incomes: incomeViewModel.incomes,
                          expenses: expenseViewModel.expenses,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
