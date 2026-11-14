import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vpn_models.dart';
import 'ovpn_parser.dart';

class StorageService {
  static const _serversKey = 'hamo_vps_servers_v1';
  static const _configsKey = 'hamo_ovpn_configs_v1';
  static const _selectedServerKey = 'hamo_selected_server_id';
  static const _selectedConfigKey = 'hamo_selected_config_id';

  static Future<List<VpsServerModel>> loadServers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_serversKey);
    if (raw == null || raw.isEmpty) {
      return OvpnParser.defaultServers();
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => VpsServerModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return OvpnParser.defaultServers();
    }
  }

  static Future<void> saveServers(List<VpsServerModel> servers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _serversKey,
      jsonEncode(servers.map((e) => e.toJson()).toList()),
    );
  }

  static Future<List<OvpnProfileModel>> loadConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_configsKey);
    if (raw == null || raw.isEmpty) {
      return OvpnParser.defaultConfigs();
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => OvpnProfileModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return OvpnParser.defaultConfigs();
    }
  }

  static Future<void> saveConfigs(List<OvpnProfileModel> configs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _configsKey,
      jsonEncode(configs.map((e) => e.toJson()).toList()),
    );
  }

  static Future<String?> loadSelectedServerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedServerKey);
  }

  static Future<void> saveSelectedServerId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedServerKey, id);
  }

  static Future<String?> loadSelectedConfigId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedConfigKey);
  }

  static Future<void> saveSelectedConfigId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedConfigKey, id);
  }
}
