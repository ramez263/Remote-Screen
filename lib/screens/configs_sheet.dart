import 'package:flutter/material.dart';
import '../models/vpn_models.dart';
import '../services/ovpn_parser.dart';

class ConfigsSheet extends StatefulWidget {
  final List<OvpnProfileModel> configs;
  final String selectedConfigId;
  final bool openCreatorInitially;
  final VoidCallback onPickFileFromDevice;
  final ValueChanged<String> onSelectConfig;
  final ValueChanged<OvpnProfileModel> onAddConfig;

  const ConfigsSheet({
    super.key,
    required this.configs,
    required this.selectedConfigId,
    required this.openCreatorInitially,
    required this.onPickFileFromDevice,
    required this.onSelectConfig,
    required this.onAddConfig,
  });

  @override
  State<ConfigsSheet> createState() => _ConfigsSheetState();
}

class _ConfigsSheetState extends State<ConfigsSheet> {
  late bool _showCreator;
  final _nameCtrl = TextEditingController();
  final _rawCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _showCreator = widget.openCreatorInitially;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rawCtrl.dispose();
    super.dispose();
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
                    'ملفات الكونفج (.ovpn / تلجرام)',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE6B800),
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onPickFileFromDevice();
                        },
                        icon: const Icon(Icons.folder_open, size: 18),
                        label: const Text('فتح ملف'),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF120E3A),
                        ),
                        onPressed: () => setState(() => _showCreator = !_showCreator),
                        icon: Icon(_showCreator ? Icons.close : Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_showCreator) ...[
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'اسم الكونفج',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _rawCtrl,
                  maxLines: 6,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'الصق كود .ovpn أو نص كونفج تلجرام',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF120E3A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    final raw = _rawCtrl.text.trim();
                    if (raw.isEmpty) return;
                    final parsed = OvpnParser.parse(
                      raw: raw,
                      name: _nameCtrl.text.trim().isEmpty
                          ? 'كونفج تلجرام مستورد'
                          : _nameCtrl.text.trim(),
                      fileName: 'pasted_config.ovpn',
                    );
                    widget.onAddConfig(parsed);
                    Navigator.pop(context);
                  },
                  child: const Text('حفظ وتفعيل الكونفج'),
                ),
                const Divider(height: 24),
              ],
              for (final cfg in widget.configs)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: cfg.id == widget.selectedConfigId
                      ? const Color(0xFFFEF9C3)
                      : Colors.white,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/tunnel_emblem_badge.jpg'),
                    ),
                    title: Text(cfg.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      '${cfg.subtitle} · ${cfg.protocol.toUpperCase()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(
                      cfg.id == widget.selectedConfigId
                          ? Icons.check_circle
                          : Icons.chevron_right,
                      color: cfg.id == widget.selectedConfigId
                          ? const Color(0xFF120E3A)
                          : Colors.grey,
                    ),
                    onTap: () {
                      widget.onSelectConfig(cfg.id);
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
