import 'package:flutter/material.dart';
import '../models/app_models.dart';

class WithdrawScreen extends StatefulWidget {
  final AppStateController state;
  final VoidCallback onChanged;

  const WithdrawScreen({super.key, required this.state, required this.onChanged});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  String _method = 'فودافون كاش';
  final _accountCtrl = TextEditingController();
  final _amountCtrl = TextEditingController(text: '50');

  void _submit() {
    final amt = double.tryParse(_amountCtrl.text) ?? 0;
    if (amt < 50 || amt > widget.state.balanceEgp || _accountCtrl.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تأكد من الرصيد المتاح (الحد الأدنى 50 ج.م.) وبيانات الحساب')),
      );
      return;
    }
    widget.state.balanceEgp -= amt;
    widget.state.withdrawals.insert(
      0,
      WithdrawalRequest(
        id: 'wd-${DateTime.now().millisecondsSinceEpoch}',
        userName: 'المستخدم الحالي',
        method: _method,
        accountInfo: _accountCtrl.text.trim(),
        amountEgp: amt,
        createdAt: DateTime.now(),
      ),
    );
    _accountCtrl.clear();
    widget.onChanged();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال طلب السحب للمراجعة')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFFFAF5D8), borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('الرصيد المتاح للسحب'),
              Text('${widget.state.balanceEgp.toStringAsFixed(2)} ج.م.', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFFEFECEF), borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _method,
                decoration: const InputDecoration(filled: true, fillColor: Colors.white, labelText: 'وسيلة السحب'),
                items: const [
                  DropdownMenuItem(value: 'فودافون كاش', child: Text('فودافون كاش')),
                  DropdownMenuItem(value: 'إنستا باي', child: Text('إنستا باي (InstaPay)')),
                  DropdownMenuItem(value: 'PayPal', child: Text('PayPal')),
                ],
                onChanged: (v) => setState(() => _method = v ?? 'فودافون كاش'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _accountCtrl,
                decoration: const InputDecoration(filled: true, fillColor: Colors.white, labelText: 'رقم المحفظة / الحساب'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(filled: true, fillColor: Colors.white, labelText: 'المبلغ (ج.م.)'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF5B0E5B)),
                  onPressed: _submit,
                  child: const Text('تأكيد طلب السحب', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
