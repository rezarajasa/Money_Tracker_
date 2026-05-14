import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RapiKasApp());
}

class Wallet {
  final String id;
  final String name;
  final String type;
  final IconData icon;
  final int balance;

  const Wallet({required this.id, required this.name, required this.type, required this.icon, required this.balance});

  Wallet copyWith({int? balance}) => Wallet(id: id, name: name, type: type, icon: icon, balance: balance ?? this.balance);

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'type': type, 'balance': balance};
}

class MoneyTransaction {
  final String id;
  final String type;
  final String title;
  final String category;
  final String walletId;
  final int amount;
  final DateTime date;

  const MoneyTransaction({required this.id, required this.type, required this.title, required this.category, required this.walletId, required this.amount, required this.date});

  Map<String, dynamic> toJson() => {'id': id, 'type': type, 'title': title, 'category': category, 'walletId': walletId, 'amount': amount, 'date': date.toIso8601String()};
}

class RapiKasApp extends StatelessWidget {
  const RapiKasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RapiKas Money Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF16A34A)),
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
        fontFamily: 'sans',
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const platform = MethodChannel('rapikas/local_store');
  int index = 0;
  bool loaded = false;

  List<Wallet> wallets = const [
    Wallet(id: 'cash', name: 'Tunai', type: 'Cash', icon: Icons.payments_rounded, balance: 1500000),
    Wallet(id: 'bca', name: 'Bank BCA', type: 'Bank', icon: Icons.account_balance_rounded, balance: 5000000),
    Wallet(id: 'bri', name: 'Bank BRI', type: 'Bank', icon: Icons.account_balance_rounded, balance: 2500000),
    Wallet(id: 'mandiri', name: 'Bank Mandiri', type: 'Bank', icon: Icons.account_balance_rounded, balance: 2000000),
    Wallet(id: 'bni', name: 'Bank BNI', type: 'Bank', icon: Icons.account_balance_rounded, balance: 1000000),
    Wallet(id: 'dana', name: 'DANA', type: 'E-Money', icon: Icons.account_balance_wallet_rounded, balance: 350000),
    Wallet(id: 'gopay', name: 'GoPay', type: 'E-Money', icon: Icons.account_balance_wallet_rounded, balance: 275000),
    Wallet(id: 'ovo', name: 'OVO', type: 'E-Money', icon: Icons.account_balance_wallet_rounded, balance: 250000),
    Wallet(id: 'shopeepay', name: 'ShopeePay', type: 'E-Money', icon: Icons.account_balance_wallet_rounded, balance: 180000),
  ];

  List<MoneyTransaction> transactions = const [
    MoneyTransaction(id: '1', type: 'expense', title: 'Makan siang', category: 'Makanan', walletId: 'cash', amount: 25000, date: nullDate),
    MoneyTransaction(id: '2', type: 'income', title: 'Gaji', category: 'Gaji', walletId: 'bca', amount: 5500000, date: nullDate),
  ];

  static const nullDate = DateTime(2026, 1, 1);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  int get totalBalance => wallets.fold(0, (sum, item) => sum + item.balance);
  int get monthlyIncome => transactions.where((e) => e.type == 'income').fold(0, (sum, item) => sum + item.amount);
  int get monthlyExpense => transactions.where((e) => e.type == 'expense').fold(0, (sum, item) => sum + item.amount);
  String walletName(String id) => wallets.firstWhere((e) => e.id == id, orElse: () => wallets.first).name;

  Future<void> _loadData() async {
    try {
      final raw = await platform.invokeMethod<String>('loadData');
      if (raw != null && raw.isNotEmpty) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final savedWallets = (map['wallets'] as List).map((e) {
          final type = e['type'] as String;
          return Wallet(id: e['id'], name: e['name'], type: type, icon: type == 'Bank' ? Icons.account_balance_rounded : type == 'E-Money' ? Icons.account_balance_wallet_rounded : Icons.payments_rounded, balance: e['balance']);
        }).toList();
        final savedTransactions = (map['transactions'] as List).map((e) => MoneyTransaction(id: e['id'], type: e['type'], title: e['title'], category: e['category'], walletId: e['walletId'], amount: e['amount'], date: DateTime.tryParse(e['date']) ?? DateTime.now())).toList();
        setState(() {
          wallets = savedWallets;
          transactions = savedTransactions;
          loaded = true;
        });
        return;
      }
    } catch (_) {}
    setState(() => loaded = true);
  }

  Future<void> _saveData() async {
    final raw = jsonEncode({'wallets': wallets.map((e) => e.toJson()).toList(), 'transactions': transactions.map((e) => e.toJson()).toList()});
    try { await platform.invokeMethod('saveData', {'json': raw}); } catch (_) {}
  }

  Future<void> _addTransaction(MoneyTransaction transaction) async {
    setState(() {
      transactions.insert(0, transaction);
      final idx = wallets.indexWhere((w) => w.id == transaction.walletId);
      if (idx >= 0) {
        final old = wallets[idx];
        final newBalance = transaction.type == 'income' ? old.balance + transaction.amount : old.balance - transaction.amount;
        wallets[idx] = old.copyWith(balance: newBalance);
      }
    });
    await _saveData();
  }

  Future<void> _addWallet(Wallet wallet) async {
    setState(() => wallets.add(wallet));
    await _saveData();
  }

  Future<void> _transfer(String from, String to, int amount) async {
    if (from == to || amount <= 0) return;
    setState(() {
      final fromIndex = wallets.indexWhere((w) => w.id == from);
      final toIndex = wallets.indexWhere((w) => w.id == to);
      if (fromIndex >= 0 && toIndex >= 0) {
        wallets[fromIndex] = wallets[fromIndex].copyWith(balance: wallets[fromIndex].balance - amount);
        wallets[toIndex] = wallets[toIndex].copyWith(balance: wallets[toIndex].balance + amount);
        transactions.insert(0, MoneyTransaction(id: DateTime.now().microsecondsSinceEpoch.toString(), type: 'transfer', title: 'Transfer ${wallets[fromIndex].name} ke ${wallets[toIndex].name}', category: 'Transfer', walletId: from, amount: amount, date: DateTime.now()));
      }
    });
    await _saveData();
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final pages = [
      DashboardPage(totalBalance: totalBalance, income: monthlyIncome, expense: monthlyExpense, onAdd: _openAddTransaction, onTransfer: _openTransfer),
      TransactionsPage(transactions: transactions, wallets: wallets, walletName: walletName, onAdd: _openAddTransaction),
      WalletsPage(wallets: wallets, onAddWallet: _openAddWallet, onTransfer: _openTransfer),
      ReportsPage(totalBalance: totalBalance, income: monthlyIncome, expense: monthlyExpense, wallets: wallets, transactions: transactions),
      ProfilePage(wallets: wallets),
    ];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_rounded), label: 'Transaksi'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Dompet'),
          NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: 'Laporan'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }

  void _openAddTransaction(String type) {
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => AddTransactionSheet(wallets: wallets, initialType: type, onSave: _addTransaction));
  }

  void _openAddWallet() {
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => AddWalletSheet(onSave: _addWallet));
  }

  void _openTransfer() {
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => TransferSheet(wallets: wallets, onSave: _transfer));
  }
}

class DashboardPage extends StatelessWidget {
  final int totalBalance;
  final int income;
  final int expense;
  final void Function(String type) onAdd;
  final VoidCallback onTransfer;
  const DashboardPage({super.key, required this.totalBalance, required this.income, required this.expense, required this.onAdd, required this.onTransfer});

  @override
  Widget build(BuildContext context) {
    final c = rupiah;
    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('RapiKas', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Money Tracker Pro', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF16A34A), Color(0xFF0F766E)]), borderRadius: BorderRadius.circular(28), boxShadow: const [BoxShadow(blurRadius: 18, offset: Offset(0, 10), color: Color(0x22000000))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Total Saldo', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(c.format(totalBalance), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            Row(children: [_MiniMetric(title: 'Income', value: c.format(income)), const SizedBox(width: 12), _MiniMetric(title: 'Expense', value: c.format(expense))])
          ]),
        ),
        const SizedBox(height: 20),
        const SectionTitle('Quick Action'),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: QuickAction(icon: Icons.add_rounded, label: 'Income', onTap: () => onAdd('income'))), const SizedBox(width: 12), Expanded(child: QuickAction(icon: Icons.remove_rounded, label: 'Expense', onTap: () => onAdd('expense'))), const SizedBox(width: 12), Expanded(child: QuickAction(icon: Icons.swap_horiz_rounded, label: 'Transfer', onTap: onTransfer))]),
        const SizedBox(height: 20),
        const SectionTitle('Insight AI'),
        const SizedBox(height: 12),
        InfoCard(icon: Icons.auto_awesome_rounded, title: expense <= income ? 'Keuangan bulan ini aman' : 'Pengeluaran perlu dikontrol', body: expense <= income ? 'Pengeluaran masih di bawah pemasukan. Pertahankan kebiasaan ini.' : 'Pengeluaran lebih besar dari pemasukan. Cek kategori terbesar di laporan.'),
      ]),
    );
  }
}

class TransactionsPage extends StatelessWidget {
  final List<MoneyTransaction> transactions;
  final List<Wallet> wallets;
  final String Function(String id) walletName;
  final void Function(String type) onAdd;
  const TransactionsPage({super.key, required this.transactions, required this.wallets, required this.walletName, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [
      Row(children: [const Expanded(child: Text('Transaksi', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800))), FilledButton.icon(onPressed: () => onAdd('expense'), icon: const Icon(Icons.add), label: const Text('Catat'))]),
      const SizedBox(height: 16),
      if (transactions.isEmpty) const InfoCard(icon: Icons.receipt_long_rounded, title: 'Belum ada transaksi', body: 'Tekan tombol Catat untuk mulai mencatat pemasukan atau pengeluaran.'),
      ...transactions.map((t) => InfoCard(icon: t.type == 'income' ? Icons.arrow_downward_rounded : t.type == 'transfer' ? Icons.swap_horiz_rounded : Icons.arrow_upward_rounded, title: t.title, body: '${labelType(t.type)} • ${rupiah.format(t.amount)} • ${walletName(t.walletId)} • ${t.category}')),
    ]));
  }
}

class WalletsPage extends StatelessWidget {
  final List<Wallet> wallets;
  final VoidCallback onAddWallet;
  final VoidCallback onTransfer;
  const WalletsPage({super.key, required this.wallets, required this.onAddWallet, required this.onTransfer});

  @override
  Widget build(BuildContext context) {
    final groups = ['Cash', 'Bank', 'E-Money'];
    return SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [
      Row(children: [const Expanded(child: Text('Dompet', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800))), IconButton.filled(onPressed: onAddWallet, icon: const Icon(Icons.add)), const SizedBox(width: 8), IconButton.filledTonal(onPressed: onTransfer, icon: const Icon(Icons.swap_horiz_rounded))]),
      const SizedBox(height: 8),
      const Text('Wallet lengkap: tunai, bank, dan e-money. Saldo otomatis berubah saat transaksi dicatat.', style: TextStyle(color: Colors.black54)),
      const SizedBox(height: 18),
      for (final group in groups) ...[
        SectionTitle(group == 'Cash' ? 'Tunai' : group),
        const SizedBox(height: 10),
        ...wallets.where((w) => w.type == group).map((w) => WalletCard(wallet: w)),
        const SizedBox(height: 12),
      ]
    ]));
  }
}

class ReportsPage extends StatelessWidget {
  final int totalBalance;
  final int income;
  final int expense;
  final List<Wallet> wallets;
  final List<MoneyTransaction> transactions;
  const ReportsPage({super.key, required this.totalBalance, required this.income, required this.expense, required this.wallets, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final bank = wallets.where((w) => w.type == 'Bank').fold(0, (s, w) => s + w.balance);
    final emoney = wallets.where((w) => w.type == 'E-Money').fold(0, (s, w) => s + w.balance);
    final cash = wallets.where((w) => w.type == 'Cash').fold(0, (s, w) => s + w.balance);
    return PageScaffold(title: 'Laporan', children: [
      InfoCard(icon: Icons.savings_rounded, title: 'Total Saldo', body: rupiah.format(totalBalance)),
      InfoCard(icon: Icons.account_balance_rounded, title: 'Saldo Bank', body: rupiah.format(bank)),
      InfoCard(icon: Icons.account_balance_wallet_rounded, title: 'Saldo E-Money', body: rupiah.format(emoney)),
      InfoCard(icon: Icons.payments_rounded, title: 'Saldo Tunai', body: rupiah.format(cash)),
      InfoCard(icon: Icons.trending_up_rounded, title: 'Cashflow', body: 'Pemasukan ${rupiah.format(income)} • Pengeluaran ${rupiah.format(expense)}'),
    ]);
  }
}

class ProfilePage extends StatelessWidget {
  final List<Wallet> wallets;
  const ProfilePage({super.key, required this.wallets});

  @override
  Widget build(BuildContext context) => PageScaffold(title: 'Profil & Pengaturan', children: [
    InfoCard(icon: Icons.check_circle_rounded, title: 'Transaksi aktif', body: 'Aplikasi sekarang bisa mencatat income, expense, dan transfer.'),
    InfoCard(icon: Icons.wallet_rounded, title: '${wallets.length} wallet tersedia', body: 'Tunai, bank, DANA, GoPay, OVO, ShopeePay, dan wallet custom.'),
    const InfoCard(icon: Icons.cloud_sync_rounded, title: 'Tahap berikutnya', body: 'Setelah APK stabil, data bisa disambungkan lagi ke Supabase login dan cloud sync.'),
  ]);
}

class AddTransactionSheet extends StatefulWidget {
  final List<Wallet> wallets;
  final String initialType;
  final Future<void> Function(MoneyTransaction transaction) onSave;
  const AddTransactionSheet({super.key, required this.wallets, required this.initialType, required this.onSave});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  late String type = widget.initialType;
  late String walletId = widget.wallets.first.id;
  final amount = TextEditingController();
  final title = TextEditingController();
  String category = 'Makanan';
  final categories = ['Makanan', 'Transportasi', 'Belanja', 'Pendidikan', 'Kesehatan', 'Tagihan', 'Gaji', 'Usaha', 'Sedekah', 'Lainnya'];

  @override
  Widget build(BuildContext context) {
    return SheetShell(title: 'Catat Transaksi', children: [
      SegmentedButton<String>(segments: const [ButtonSegment(value: 'income', label: Text('Income')), ButtonSegment(value: 'expense', label: Text('Expense'))], selected: {type}, onSelectionChanged: (v) => setState(() => type = v.first)),
      const SizedBox(height: 12),
      TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nominal', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: title, decoration: const InputDecoration(labelText: 'Judul / Catatan', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      DropdownButtonFormField(value: walletId, decoration: const InputDecoration(labelText: 'Wallet', border: OutlineInputBorder()), items: widget.wallets.map((w) => DropdownMenuItem(value: w.id, child: Text('${w.name} • ${rupiah.format(w.balance)}'))).toList(), onChanged: (v) => setState(() => walletId = v!)),
      const SizedBox(height: 12),
      DropdownButtonFormField(value: category, decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()), items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => category = v!)),
      const SizedBox(height: 18),
      FilledButton(onPressed: () async {
        final value = int.tryParse(amount.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
        if (value <= 0) return;
        await widget.onSave(MoneyTransaction(id: DateTime.now().microsecondsSinceEpoch.toString(), type: type, title: title.text.trim().isEmpty ? category : title.text.trim(), category: category, walletId: walletId, amount: value, date: DateTime.now()));
        if (context.mounted) Navigator.pop(context);
      }, child: const Text('Simpan Transaksi')),
    ]);
  }
}

class AddWalletSheet extends StatefulWidget {
  final Future<void> Function(Wallet wallet) onSave;
  const AddWalletSheet({super.key, required this.onSave});

  @override
  State<AddWalletSheet> createState() => _AddWalletSheetState();
}

class _AddWalletSheetState extends State<AddWalletSheet> {
  String type = 'Bank';
  final name = TextEditingController();
  final balance = TextEditingController();

  @override
  Widget build(BuildContext context) => SheetShell(title: 'Tambah Wallet', children: [
    DropdownButtonFormField(value: type, decoration: const InputDecoration(labelText: 'Jenis wallet', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'Cash', child: Text('Tunai')), DropdownMenuItem(value: 'Bank', child: Text('Bank')), DropdownMenuItem(value: 'E-Money', child: Text('E-Money'))], onChanged: (v) => setState(() => type = v!)),
    const SizedBox(height: 12),
    TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama wallet, contoh Bank Syariah / LinkAja', border: OutlineInputBorder())),
    const SizedBox(height: 12),
    TextField(controller: balance, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Saldo awal', border: OutlineInputBorder())),
    const SizedBox(height: 18),
    FilledButton(onPressed: () async {
      final value = int.tryParse(balance.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
      final walletName = name.text.trim().isEmpty ? type : name.text.trim();
      await widget.onSave(Wallet(id: DateTime.now().microsecondsSinceEpoch.toString(), name: walletName, type: type, icon: type == 'Bank' ? Icons.account_balance_rounded : type == 'E-Money' ? Icons.account_balance_wallet_rounded : Icons.payments_rounded, balance: value));
      if (context.mounted) Navigator.pop(context);
    }, child: const Text('Simpan Wallet')),
  ]);
}

class TransferSheet extends StatefulWidget {
  final List<Wallet> wallets;
  final Future<void> Function(String from, String to, int amount) onSave;
  const TransferSheet({super.key, required this.wallets, required this.onSave});

  @override
  State<TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends State<TransferSheet> {
  late String from = widget.wallets.first.id;
  late String to = widget.wallets.length > 1 ? widget.wallets[1].id : widget.wallets.first.id;
  final amount = TextEditingController();

  @override
  Widget build(BuildContext context) => SheetShell(title: 'Transfer Antar Wallet', children: [
    DropdownButtonFormField(value: from, decoration: const InputDecoration(labelText: 'Dari wallet', border: OutlineInputBorder()), items: widget.wallets.map((w) => DropdownMenuItem(value: w.id, child: Text(w.name))).toList(), onChanged: (v) => setState(() => from = v!)),
    const SizedBox(height: 12),
    DropdownButtonFormField(value: to, decoration: const InputDecoration(labelText: 'Ke wallet', border: OutlineInputBorder()), items: widget.wallets.map((w) => DropdownMenuItem(value: w.id, child: Text(w.name))).toList(), onChanged: (v) => setState(() => to = v!)),
    const SizedBox(height: 12),
    TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nominal transfer', border: OutlineInputBorder())),
    const SizedBox(height: 18),
    FilledButton(onPressed: () async {
      final value = int.tryParse(amount.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
      await widget.onSave(from, to, value);
      if (context.mounted) Navigator.pop(context);
    }, child: const Text('Simpan Transfer')),
  ]);
}

class WalletCard extends StatelessWidget {
  final Wallet wallet;
  const WalletCard({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)), child: Row(children: [CircleAvatar(backgroundColor: const Color(0xFFE8F8EF), foregroundColor: const Color(0xFF16A34A), child: Icon(wallet.icon)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(wallet.name, style: const TextStyle(fontWeight: FontWeight.w800)), Text(wallet.type, style: const TextStyle(color: Colors.black54))])), Text(rupiah.format(wallet.balance), style: const TextStyle(fontWeight: FontWeight.w800))]));
}

class SheetShell extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const SheetShell({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Padding(padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20), child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)), const SizedBox(height: 16), ...children])));
}

class PageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  const PageScaffold({super.key, required this.title, this.subtitle, required this.children});

  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)), if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle!, style: const TextStyle(color: Colors.black54))], const SizedBox(height: 18), ...children]));
}

class _MiniMetric extends StatelessWidget {
  final String title;
  final String value;
  const _MiniMetric({required this.title, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withOpacity(.14), borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white70)), const SizedBox(height: 6), Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))])));
}

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const QuickAction({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: Container(padding: const EdgeInsets.symmetric(vertical: 18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)), child: Column(children: [Icon(icon), const SizedBox(height: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.w600))])));
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700));
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const InfoCard({super.key, required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [CircleAvatar(backgroundColor: const Color(0xFFE8F8EF), foregroundColor: const Color(0xFF16A34A), child: Icon(icon)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(body, style: const TextStyle(color: Colors.black54))]))]));
}

final rupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
String labelType(String type) => type == 'income' ? 'Income' : type == 'expense' ? 'Expense' : 'Transfer';
