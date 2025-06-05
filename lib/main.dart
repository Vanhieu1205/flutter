import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'viewmodels/category_viewmodel.dart';
import 'viewmodels/income_viewmodel.dart';
import 'viewmodels/expense_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'pages/auth/auth_screen.dart';
import 'pages/home/home_page.dart';
import 'pages/splash/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/auth/login_screen.dart';
import 'pages/auth/signup_screen.dart';
import 'pages/transaction/add_income_screen.dart';
import 'pages/transaction/edit_income_screen.dart';
import 'pages/transaction/add_expense_screen.dart';
import 'pages/transaction/edit_expense_screen.dart';
import 'pages/categories/add_category_screen.dart';
import 'pages/categories/edit_category_screen.dart';
import 'models/income_model.dart';
import 'models/expense_model.dart';
import 'models/category_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => IncomeViewModel()),
        ChangeNotifierProvider(create: (_) => ExpenseViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Finance Management',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/': (context) => const AuthGate(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => const HomePage(),
          '/addIncome': (context) => const AddIncomeScreen(),
          '/editIncome': (context) {
            final income = ModalRoute.of(context)!.settings.arguments as Income;
            return EditIncomeScreen(income: income);
          },
          '/addExpense': (context) => const AddExpenseScreen(),
          '/editExpense': (context) {
            final expense =
                ModalRoute.of(context)!.settings.arguments as Expense;
            return EditExpenseScreen(expense: expense);
          },
          '/addCategory': (context) => const AddCategoryScreen(),
          '/editCategory': (context) {
            final category =
                ModalRoute.of(context)!.settings.arguments as Category;
            return EditCategoryScreen(category: category);
          },
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }
        if (snapshot.hasData) {
          return const HomePage();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}
