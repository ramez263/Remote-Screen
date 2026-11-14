import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'models/vpn_models.dart';
import 'screens/configs_sheet.dart';
import 'screens/logs_sheet.dart';
import 'screens/vps_settings_sheet.dart';
import 'services/ovpn_parser.dart';
import 'services/storage_service.dart';
import 'widgets/traffic_hero_banner.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HamoTunnelApp());
}

class HamoTunnelApp extends StatelessWidget {
  const HamoTunnelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hamo Tunnel Plus',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.cairoTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF120E3A)),
        useMaterial3: true,
      ),
      home: const TunnelHomeScreen(),
    );
  }
}

class TunnelHomeScreen extends StatefulWidget {
  const TunnelHomeScreen({super.key});

  @override
  State<TunnelHomeScreen> createState() => _TunnelHomeScreenState();
}

class _TunnelHomeScreenState extends State<TunnelHomeScreen> {
  late OpenVPN _openVpn;
  VPNStage _stage = VPNStage.disconnected;
  VpnStatus? _status;
  StreamSubscription<List<SharedMediaFile>>? _shareSub;

  List<VpsServerModel> _servers = OvpnParser.defaultServers();
  List<OvpnProfileModel> _configs = OvpnParser.defaultConfigs();
  String _selectedServerId = 'auto';
  String _selectedConfigId = '';

  final List<TrafficSample> _trafficSamples = [];
  final List<String> _logs = ['[Init] OpenVPN core initialized.'];

  @override
  void initState() {
    super.initState();
    _selectedConfigId = _configs.first.id;
    _loadPersistedData();
    _initOpenVpn();
    _listenTelegramSharedFiles();
  }

  Future<void> _loadPersistedData() async {
    final loadedServers = await StorageService.loadServers();
    final loadedConfigs = await StorageService.loadConfigs();
    final savedSrvId = await StorageService.loadSelectedServerId();
    final savedCfgId = await StorageService.loadSelectedConfigId();

    if (!mounted) return;
    setState(() {
      _servers = loadedServers;
      _configs = loadedConfigs;
      if (savedSrvId != null && _servers.any((s) => s.id == savedSrvId)) {
        _selectedServerId = savedSrvId;
      } else {
        _selectedServerId = _servers.first.id;
      }
      if (savedCfgId != null && _configs.any((c) => c.id == savedCfgId)) {
        _selectedConfigId = savedCfgId;
      } else {
        _selectedConfigId = _configs.first.id;
      }
    });
  }

  void _initOpenVpn() {
    _openVpn = OpenVPN(
      onVpnStatusChanged: (data) {
        if (!mounted) return;
        setState(() {
          _status = data;
          if (_stage == VPNStage.connected && data != null) {
            final dl = _parseKbps(data.byteIn);
            final ul = _parseKbps(data.byteOut);
            _trafficSamples.add(TrafficSample(dl, ul));
            if (_trafficSamples.length > 24) {
              _trafficSamples.removeAt(0);
            }
          }
        });
      },
      onVpnStageChanged: (stage, raw) {
        if (!mounted) return;
        setState(() {
          _stage = stage;
          _logs.add('[${DateTime.now().toIso8601String().substring(11, 19)}] $stage: $raw');
          if (stage == VPNStage.disconnected) {
            _trafficSamples.clear();
          }
        });
      },
    );

    _openVpn.initialize(
      groupIdentifier: 'group.com.hamotunnel.plus',
      providerBundleIdentifier: 'com.hamotunnel.plus.VPNExtension',
      localizedDescription: 'Hamo Tunnel Plus OpenVPN',
    );
  }

  double _parseKbps(String? value) {
    if (value == null || value.isEmpty) return 0;
    final numMatch = RegExp(r'([0-9.]+)').firstMatch(value);
    return double.tryParse(numMatch?.group(1) ?? '0') ?? 0;
  }

  void _listenTelegramSharedFiles() {
    _shareSub = ReceiveSharingIntent.instance.getMediaStream().listen((files) {
      if (files.isNotEmpty) {
        _importOvpnPath(files.first.path, source: 'telegram');
      }
    });

    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      if (files.isNotEmpty) {
        _importOvpnPath(files.first.path, source: 'telegram');
      }
    });
  }

  Future<void> _pickOvpnFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      await _importOvpnPath(result.files.single.path!, source: 'ovpn');
    }
  }

  Future<void> _importOvpnPath(String path, {required String source}) async {
    try {
      final file = File(path);
      final fileName = file.uri.pathSegments.last;
      final lower = fileName.toLowerCase();
      if (!lower.endsWith('.ovpn') &&
          !lower.endsWith('.conf') &&
          !lower.endsWith('.txt')) {
        _showMessage('يرجى اختيار ملف بامتداد .ovpn أو .conf أو .txt');
        return;
      }

      final content = await file.readAsString();
      final parsed = OvpnParser.parse(
        raw: content,
        name: fileName.replaceAll(RegExp(r'\.[^.]+$'), ''),
        fileName: fileName,
        source: source,
      );

      setState(() {
        _configs = [parsed, ..._configs];
        _selectedConfigId = parsed.id;
        _logs.add('[Import] Loaded $fileName (${parsed.remoteHost}:${parsed.remotePort})');
      });
      await StorageService.saveConfigs(_configs);
      await StorageService.saveSelectedConfigId(parsed.id);
      _showMessage('تم استيراد الكونفج: $fileName');
    } catch (e) {
      _showMessage('تعذر قراءة الملف: $e');
    }
  }

  VpsServerModel get _activeServer =>
      _servers.firstWhere((s) => s.id == _selectedServerId, orElse: () => _servers.first);

  OvpnProfileModel get _activeConfig =>
      _configs.firstWhere((c) => c.id == _selectedConfigId, orElse: () => _configs.first);

  Future<void> _toggleQuickConnect() async {
    if (_stage == VPNStage.connected || _stage == VPNStage.connecting) {
      _openVpn.disconnect();
      return;
    }

    final granted = await _openVpn.requestPermissionAndroid();
    if (!granted) {
      _showMessage('يجب السماح بصلاحية VPN للاتصال');
      return;
    }

    final profile = _activeConfig.rawContent.isNotEmpty
        ? _activeConfig.rawContent
        : OvpnParser.buildFromVps(_activeServer);

    _openVpn.connect(
      profile,
      _activeConfig.name,
      username: _activeServer.username,
      password: _activeServer.password,
      certIsRequired: false,
    );
  }

  void _openVpsSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => VpsSettingsSheet(
        servers: _servers,
        selectedServerId: _activeServer.id,
        onSelectServer: (id) async {
          setState(() => _selectedServerId = id);
          await StorageService.saveSelectedServerId(id);
        },
        onAddOrUpdateVps: (server) async {
          setState(() {
            _servers = [_servers.first, server, ..._servers.skip(1)];
            _selectedServerId = server.id;
          });
          await StorageService.saveServers(_servers);
          await StorageService.saveSelectedServerId(server.id);
        },
        onGenerateOvpnFromVps: (server) async {
          final raw = OvpnParser.buildFromVps(server);
          final generated = OvpnParser.parse(
            raw: raw,
            name: '${server.name} (.ovpn)',
            fileName: '${server.host}.ovpn',
            source: 'custom',
          );
          setState(() {
            _configs = [generated, ..._configs];
            _selectedConfigId = generated.id;
          });
          await StorageService.saveConfigs(_configs);
          await StorageService.saveSelectedConfigId(generated.id);
        },
      ),
    );
  }

  void _openConfigsSheet({bool openCreator = false}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ConfigsSheet(
        configs: _configs,
        selectedConfigId: _activeConfig.id,
        openCreatorInitially: openCreator,
        onPickFileFromDevice: _pickOvpnFile,
        onSelectConfig: (id) async {
          setState(() => _selectedConfigId = id);
          await StorageService.saveSelectedConfigId(id);
        },
        onAddConfig: (cfg) async {
          setState(() {
            _configs = [cfg, ..._configs];
            _selectedConfigId = cfg.id;
          });
          await StorageService.saveConfigs(_configs);
          await StorageService.saveSelectedConfigId(cfg.id);
        },
      ),
    );
  }

  void _openLogsSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => LogsSheet(
        logs: _logs,
        onClear: () {
          setState(() => _logs.clear());
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _shareSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _stage == VPNStage.connected;
    final isConnecting = _stage == VPNStage.connecting ||
        _stage == VPNStage.authenticating ||
        _stage == VPNStage.wait_connection;

    final statusColor = isConnected
        ? const Color(0xFF16A34A)
        : isConnecting
            ? const Color(0xFFD97706)
            : const Color(0xFFDC2626);

    final statusLabel = isConnected
        ? 'Connected'
        : isConnecting
            ? 'Connecting...'
            : 'Disconnected';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.grid_view_rounded, color: Color(0xFFE6B800), size: 28),
                    onPressed: _openVpsSheet,
                    tooltip: 'إعدادات VPS',
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      isConnected ? 'IP: 10.8.0.14-Tunnel' : 'IP: 10.111.3.252-Mobile',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.description_rounded, color: Color(0xFFE6B800), size: 28),
                    onPressed: () => _openConfigsSheet(),
                    tooltip: 'فتح ملف .ovpn',
                  ),
                ],
              ),
            ),

            // Hero Wings + Emblem + Graph
            TrafficHeroBanner(
              isConnected: isConnected,
              isConnecting: isConnecting,
              samples: _trafficSamples,
            ),

            // Speed & Status Strip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud_download, color: Color(0xFFE6B800), size: 18),
                      const SizedBox(width: 5),
                      Text(
                        _status?.byteIn ?? '0KB',
                        style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                  Text(
                    statusLabel,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                  Row(
                    children: [
                      Text(
                        _status?.byteOut ?? '0KB',
                        style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.cloud_upload, color: Color(0xFFE6B800), size: 18),
                    ],
                  ),
                ],
              ),
            ),

            // Server Card
            _TunnelCard(
              title: _activeServer.name,
              subtitle: _activeServer.subtitle,
              onTap: _openVpsSheet,
            ),

            // Active Config Card
            _TunnelCard(
              title: _activeConfig.name,
              subtitle: _activeConfig.subtitle,
              isRtlTitle: true,
              trailingActionLabel: 'CREATE',
              onTrailingActionTap: () => _openConfigsSheet(openCreator: true),
              onTap: () => _openConfigsSheet(),
            ),

            const SizedBox(height: 14),
            const Text('Connection time', style: TextStyle(color: Colors.black54, fontSize: 15)),
            Text(
              _status?.duration ?? '00:00:00',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 34,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE6B800),
              ),
            ),

            const Spacer(),

            // Power Quick Connect Button
            GestureDetector(
              onTap: _toggleQuickConnect,
              child: Container(
                width: 148,
                height: 148,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF120E3A),
                ),
                padding: const EdgeInsets.all(14),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isConnected ? const Color(0xFF34D399) : const Color(0xFFE6B800),
                      width: 2.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.power_settings_new_rounded,
                        color: isConnected ? const Color(0xFF34D399) : Colors.white,
                        size: 42,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isConnected ? 'Connected' : isConnecting ? 'Connecting' : 'Disconnected',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text('Config Version: 27.449', style: TextStyle(color: Colors.black45, fontSize: 13)),
            const SizedBox(height: 8),

            // Quick Bottom Utility Strip
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: _pickOvpnFile,
                    icon: const Icon(Icons.bolt, size: 17, color: Color(0xFFE6B800)),
                    label: const Text('فتح .ovpn', style: TextStyle(fontSize: 12)),
                  ),
                  TextButton.icon(
                    onPressed: _openVpsSheet,
                    icon: const Icon(Icons.dns_rounded, size: 17, color: Color(0xFF120E3A)),
                    label: const Text('ربط VPS', style: TextStyle(fontSize: 12)),
                  ),
                  TextButton.icon(
                    onPressed: _openLogsSheet,
                    icon: const Icon(Icons.terminal, size: 17, color: Colors.black54),
                    label: const Text('السجل', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TunnelCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isRtlTitle;
  final String? trailingActionLabel;
  final VoidCallback? onTrailingActionTap;
  final VoidCallback onTap;

  const _TunnelCard({
    required this.title,
    required this.subtitle,
    this.isRtlTitle = false,
    this.trailingActionLabel,
    this.onTrailingActionTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 17,
                backgroundImage: AssetImage('assets/images/tunnel_emblem_badge.jpg'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      isRtlTitle ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: isRtlTitle ? TextDirection.rtl : TextDirection.ltr,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: isRtlTitle ? TextDirection.rtl : TextDirection.ltr,
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (trailingActionLabel != null) ...[
                InkWell(
                  onTap: onTrailingActionTap,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.playlist_add, color: Color(0xFFE6B800), size: 20),
                      Text(
                        trailingActionLabel!,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const CircleAvatar(
                radius: 13,
                backgroundColor: Color(0xFF94A3B8),
                child: Icon(Icons.chevron_right_rounded, color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
