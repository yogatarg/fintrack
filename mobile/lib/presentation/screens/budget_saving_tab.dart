// lib/presentation/screens/budget_saving_tab.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'budget/budget_list_screen.dart';
import 'saving_goal/saving_goal_list_screen.dart';

class BudgetSavingTab extends StatefulWidget {
  const BudgetSavingTab({super.key});

  @override
  State<BudgetSavingTab> createState() => _BudgetSavingTabState();
}

class _BudgetSavingTabState extends State<BudgetSavingTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Budget & Tabungan'),
          backgroundColor: AppColors.background,
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: 'Budget'),
              Tab(text: 'Tabungan'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            BudgetListScreen(),
            SavingGoalListScreen(),
          ],
        ),
      ),
    );
  }
}