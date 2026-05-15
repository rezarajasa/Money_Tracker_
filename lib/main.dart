import 'package:flutter/material.dart';

void main() {
  runApp(const RapiKasApp());
}

class RapiKasApp extends StatelessWidget {
  const RapiKasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RapiKas',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF16A34A)),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int balance = 12500000;
  int income = 5500000;
  int expense = 2300000;
  final List<String> transactions = [];

  void addIncome() {
    setState(() {
      income += 100000;
      balance += 100000;
      transactions.insert(0, 'Income Rp 100.000');
    });
  }

  void addExpense() {
    setState(() {
      expense += 50000;
      balance -= 50000;
      transactions.insert(0, 'Expense Rp 50.000');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RapiKas')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Total Saldo'),
                Text('Rp $balance', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('Income: Rp $income'),
                Text('Expense: Rp $expense'),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: FilledButton(onPressed: addIncome, child: const Text('Income'))),
            const SizedBox(width: 8),
            Expanded(child: FilledButton(onPressed: addExpense, child: const Text('Expense'))),
          ]),
          const SizedBox(height: 20),
          const Text('Transaksi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          for (final item in transactions) ListTile(title: Text(item)),
        ],
      ),
    );
  }
}
