import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RapiKasApp());
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
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
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
  int index = 0;

  final pages = const [
    DashboardPage(),
    TransactionsPage(),
    CurrencyPage(),
    ReportsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_rounded), label: 'Transaksi'),
          NavigationDestination(icon: Icon(Icons.currency_exchange_rounded), label: 'Kurs'),
          NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: 'Laporan'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('RapiKas', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Money Tracker Pro', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF16A34A), Color(0xFF0F766E)]),
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [BoxShadow(blurRadius: 18, offset: Offset(0, 10), color: Color(0x22000000))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Saldo', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Text(currency.format(12500000), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _MiniMetric(title: 'Income', value: currency.format(5500000)),
                    const SizedBox(width: 12),
                    _MiniMetric(title: 'Expense', value: currency.format(2300000)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionTitle('Quick Action'),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(child: QuickAction(icon: Icons.add_rounded, label: 'Income')),
              SizedBox(width: 12),
              Expanded(child: QuickAction(icon: Icons.remove_rounded, label: 'Expense')),
              SizedBox(width: 12),
              Expanded(child: QuickAction(icon: Icons.swap_horiz_rounded, label: 'Transfer')),
            ],
          ),
          const SizedBox(height: 20),
          const SectionTitle('Insight AI'),
          const SizedBox(height: 12),
          const InfoCard(
            icon: Icons.auto_awesome_rounded,
            title: 'Keuangan bulan ini aman',
            body: 'Pengeluaran masih di bawah budget. Pertahankan batas makanan dan transportasi agar saldo tetap stabil.',
          ),
        ],
      ),
    );
  }
}

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Transaksi',
      children: [
        InfoCard(icon: Icons.restaurant_rounded, title: 'Makan siang', body: 'Expense • Rp 25.000 • Cash'),
        InfoCard(icon: Icons.account_balance_wallet_rounded, title: 'Gaji', body: 'Income • Rp 5.000.000 • Bank'),
        InfoCard(icon: Icons.school_rounded, title: 'Pendidikan', body: 'Expense • Rp 350.000 • E-Wallet'),
      ],
    );
  }
}

class CurrencyPage extends StatelessWidget {
  const CurrencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Kurs Mata Uang',
      subtitle: 'Info kurs dan konverter mata uang',
      children: [
        InfoCard(icon: Icons.attach_money_rounded, title: 'USD / IDR', body: '1 USD = Rp 16.000'),
        InfoCard(icon: Icons.euro_rounded, title: 'EUR / IDR', body: '1 EUR = Rp 17.300'),
        InfoCard(icon: Icons.mosque_rounded, title: 'SAR / IDR', body: '1 SAR = Rp 4.260'),
        InfoCard(icon: Icons.currency_exchange_rounded, title: 'Fitur produksi', body: 'Hubungkan Edge Function Supabase untuk update kurs otomatis.'),
      ],
    );
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Laporan',
      children: [
        InfoCard(icon: Icons.pie_chart_rounded, title: 'Pengeluaran terbesar', body: 'Makanan 35%, Transportasi 20%, Pendidikan 15%'),
        InfoCard(icon: Icons.trending_up_rounded, title: 'Cashflow', body: 'Pemasukan lebih besar dari pengeluaran bulan ini.'),
        InfoCard(icon: Icons.picture_as_pdf_rounded, title: 'Export', body: 'Siapkan export PDF, Excel, dan CSV.'),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Profil & Pengaturan',
      children: [
        InfoCard(icon: Icons.login_rounded, title: 'Login Supabase', body: 'Isi URL dan Anon Key di lib/config/app_config.dart untuk mengaktifkan login.'),
        InfoCard(icon: Icons.security_rounded, title: 'Keamanan', body: 'PIN, biometric, dan backup cloud bisa dikembangkan dari starter ini.'),
        InfoCard(icon: Icons.settings_rounded, title: 'Pengaturan', body: 'Dompet, kategori, budget, tagihan, utang-piutang, dan target keuangan.'),
      ],
    );
  }
}

class PageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  const PageScaffold({super.key, required this.title, this.subtitle, required this.children});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: const TextStyle(color: Colors.black54)),
          ],
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String title;
  final String value;
  const _MiniMetric({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white.withOpacity(.14), borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const QuickAction({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: Column(children: [Icon(icon), const SizedBox(height: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.w600))]),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700));
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const InfoCard({super.key, required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: const Color(0xFFE8F8EF), foregroundColor: const Color(0xFF16A34A), child: Icon(icon)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(body, style: const TextStyle(color: Colors.black54))])),
        ],
      ),
    );
  }
}
