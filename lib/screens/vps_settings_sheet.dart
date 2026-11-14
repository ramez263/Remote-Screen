import 'package:flutter/material.dart';
import '../models/vpn_models.dart';

class VpsSettingsSheet extends StatefulWidget {
  final List<VpsServerModel> servers;
  final String selectedServerId;
  final ValueChanged<String> onSelectServer;
  final ValueChanged<VpsServerModel> onAddOrUpdateVps;
  final ValueChanged<VpsServerModel> onGenerateOvpnFromVps;

  const VpsSettingsSheet({
    super.key,
    required this.servers,
    required this.selectedServerId,
    required this.onSelectServer,
    required this.onAddOrUpdateVps,
    required this.onGenerateOvpnFromVps,
  });

  @override
  State<VpsSettingsSheet> createState() => _VpsSettingsSheetState();
}

class _VpsSettingsSheetState extends State<VpsSettingsSheet> {
  bool _showCustomForm = false;
  final _nameCtrl = TextEditingController(text: 'سيرفر VPS الخاص بي');
  final _hostCtrl = TextEditingController();
  final _portCtrl = TextEditingController(text: '1194');
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _sniCtrl = TextEditingController(text: 'we-school.te.eg');
  final _dnsCtrl = TextEditingController(text: '1.1.1.1');
  String _protocol = 'UDP';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _hostCtrl.dispose();
    _portCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    _sniCtrl.dispose();
    _dnsCtrl.dispose();
    super.dispose();
  }

  VpsServerModel _buildServerFromForm() {
    final host = _hostCtrl.text.trim();
    final port = int.tryParse(_portCtrl.text.trim()) ?? 1194;
    return VpsServerModel(
      id: 'vps_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim().isEmpty ? 'VPS $host' : _nameCtrl.text.trim(),
      subtitle: '$host:$port · OpenVPN $_protocol',
      host: host,
      port: port,
      protocol: _protocol,
      username: _userCtrl.text.trim(),
      password: _passCtrl.text,
      sniHost: _sniCtrl.text.trim(),
      dnsPrimary: _dnsCtrl.text.trim().isEmpty ? '1.1.1.1' : _dnsCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'إعدادات ربط السيرفر VPS',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF120E3A),
                    ),
                    onPressed: () => setState(() => _showCustomForm = !_showCustomForm),
                    icon: Icon(_showCustomForm ? Icons.close : Icons.add, size: 18),
                    label: Text(_showCustomForm ? 'إغلاق' : 'ربط VPS جديد'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_showCustomForm) ...[
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'اسم السيرفر',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _hostCtrl,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'VPS IP / Hostname',
                    hintText: '45.132.xx.xx',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _portCtrl,
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.ltr,
                        decoration: const InputDecoration(
                          labelText: 'Port',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _protocol,
                        items: const [
                          DropdownMenuItem(value: 'UDP', child: Text('OpenVPN UDP')),
                          DropdownMenuItem(value: 'TCP', child: Text('OpenVPN TCP')),
                          DropdownMenuItem(value: 'SSL', child: Text('OpenVPN SSL')),
                        ],
                        onChanged: (v) => setState(() => _protocol = v ?? 'UDP'),
                        decoration: const InputDecoration(
                          labelText: 'البروتوكول',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _userCtrl,
                        textDirection: TextDirection.ltr,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _passCtrl,
                        obscureText: true,
                        textDirection: TextDirection.ltr,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _sniCtrl,
                        textDirection: TextDirection.ltr,
                        decoration: const InputDecoration(
                          labelText: 'SNI / Bug Host',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _dnsCtrl,
                        textDirection: TextDirection.ltr,
                        decoration: const InputDecoration(
                          labelText: 'DNS',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF120E3A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          if (_hostCtrl.text.trim().isEmpty) return;
                          final server = _buildServerFromForm();
                          widget.onAddOrUpdateVps(server);
                          Navigator.pop(context);
                        },
                        child: const Text('حفظ وربط السيرفر'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE6B800),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          if (_hostCtrl.text.trim().isEmpty) return;
                          final server = _buildServerFromForm();
                          widget.onGenerateOvpnFromVps(server);
                          Navigator.pop(context);
                        },
                        child: const Text('توليد ملف .ovpn'),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
              ],
              for (final server in widget.servers)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: server.id == widget.selectedServerId
                      ? const Color(0xFFFEF9C3)
                      : Colors.white,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/tunnel_emblem_badge.jpg'),
                    ),
                    title: Text(server.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(server.subtitle, textDirection: TextDirection.ltr),
                    trailing: Icon(
                      server.id == widget.selectedServerId
                          ? Icons.check_circle
                          : Icons.chevron_right,
                      color: server.id == widget.selectedServerId
                          ? const Color(0xFF120E3A)
                          : Colors.grey,
                    ),
                    onTap: () {
                      widget.onSelectServer(server.id);
                      Navigator.pop(context);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
