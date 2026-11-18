import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/app_models.dart';
import 'screens/admin_screen.dart';
import 'screens/games_screen.dart';
import 'screens/home_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/withdraw_screen.dart';

void main() {
  runApp(const GoldenRewardsApp());
}

class GoldenRewardsApp extends StatelessWidget {
  const GoldenRewardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Golden Rewards',
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [Locale('ar', 'EG'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.cairoTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B0E5B),
          primary: const Color(0xFF5B0E5B),
        ),
      ),
      home: const MainShellScreen(),
    );
  }
}

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  final AppStateController _state = AppStateController();
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _state.balanceEgp = prefs.getDouble('balanceEgp') ?? 0.0;
      _state.points = prefs.getInt('points') ?? 0;
      _state.xp = prefs.getInt('xp') ?? 0;
      _state.streakDays = prefs.getInt('streakDays') ?? 0;
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balanceEgp', _state.balanceEgp);
    await prefs.setInt('points', _state.points);
    await prefs.setInt('xp', _state.xp);
    await prefs.setInt('streakDays', _state.streakDays);
  }

  void _refresh() {
    _saveState();
    setState(() {});
  }

  void _openAdminGate() {
    final controller = TextEditingController();
    String? errorMsg;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('دخول لوحة الإدارة', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'كلمة المرور',
                  filled: true,
                  fillColor: const Color(0xFFEFECEF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (errorMsg != null) ...[
                const SizedBox(height: 8),
                Text(errorMsg!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF5B0E5B)),
              onPressed: () {
                if (controller.text.trim() == _state.adminPassword) {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminScreen(state: _state, onMutate: _refresh),
                    ),
                  );
                } else {
                  setModalState(() => errorMsg = 'كلمة المرور غير صحيحة');
                }
              },
              child: const Text('دخول'),
            ),
          ],
        ),
      ),
    );
  }

  static const _titles = ['الرئيسية', 'المهام', 'الألعاب', 'السحب'];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _titles[_tabIndex],
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Color(0xFF141115)),
            ),
            // زر مخفي بنقطة لفتح صفحة الأدمن
            GestureDetector(
              onTap: _openAdminGate,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Text('.', style: TextStyle(fontSize: 26, color: Color(0xFF9E98A3))),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFF3F2F4),
              child: IconButton(
                icon: const Icon(Icons.settings_outlined, color: Color(0xFF141115)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('الرصيد الحالي: ${_state.balanceEgp.toStringAsFixed(2)} ج.م.')),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: _tabIndex,
              onDestinationSelected: (i) => setState(() => _tabIndex = i),
              labelType: NavigationRailLabelType.all,
              indicatorColor: const Color(0xFFEFEAF0),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('الرئيسية')),
                NavigationRailDestination(icon: Icon(Icons.checklist_rounded), label: Text('المهام')),
                NavigationRailDestination(icon: Icon(Icons.sports_esports_outlined), label: Text('الألعاب')),
                NavigationRailDestination(icon: Icon(Icons.monetization_on_outlined), label: Text('السحب')),
              ],
            ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: IndexedStack(
                  index: _tabIndex,
                  children: [
                    HomeScreen(
                      state: _state,
                      onChanged: _refresh,
                      onNavigateTab: (idx) => setState(() => _tabIndex = idx),
                    ),
                    TasksScreen(state: _state, onChanged: _refresh),
                    GamesScreen(state: _state, onChanged: _refresh),
                    WithdrawScreen(state: _state, onChanged: _refresh),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _tabIndex,
              onDestinationSelected: (i) => setState(() => _tabIndex = i),
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFFEFEAF0),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
                NavigationDestination(icon: Icon(Icons.checklist_rounded), label: 'المهام'),
                NavigationDestination(icon: Icon(Icons.sports_esports_outlined), label: 'الألعاب'),
                NavigationDestination(icon: Icon(Icons.monetization_on_outlined), label: 'السحب'),
              ],
            ),
    );
  }
}
