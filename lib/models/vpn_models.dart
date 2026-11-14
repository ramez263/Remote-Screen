class OvpnProfileModel {
  final String id;
  final String name;
  final String subtitle;
  final String fileName;
  final String source;
  final String rawContent;
  final String remoteHost;
  final int remotePort;
  final String protocol;
  final String cipher;
  final String sniHost;
  final bool hasCaCert;
  final bool requiresAuth;

  const OvpnProfileModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.fileName,
    required this.source,
    required this.rawContent,
    required this.remoteHost,
    required this.remotePort,
    required this.protocol,
    required this.cipher,
    this.sniHost = '',
    this.hasCaCert = false,
    this.requiresAuth = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subtitle': subtitle,
        'fileName': fileName,
        'source': source,
        'rawContent': rawContent,
        'remoteHost': remoteHost,
        'remotePort': remotePort,
        'protocol': protocol,
        'cipher': cipher,
        'sniHost': sniHost,
        'hasCaCert': hasCaCert,
        'requiresAuth': requiresAuth,
      };

  factory OvpnProfileModel.fromJson(Map<String, dynamic> json) {
    return OvpnProfileModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'OpenVPN Config',
      subtitle: json['subtitle'] as String? ?? '',
      fileName: json['fileName'] as String? ?? 'config.ovpn',
      source: json['source'] as String? ?? 'ovpn',
      rawContent: json['rawContent'] as String? ?? '',
      remoteHost: json['remoteHost'] as String? ?? '127.0.0.1',
      remotePort: (json['remotePort'] as num?)?.toInt() ?? 1194,
      protocol: json['protocol'] as String? ?? 'udp',
      cipher: json['cipher'] as String? ?? 'AES-256-GCM',
      sniHost: json['sniHost'] as String? ?? '',
      hasCaCert: json['hasCaCert'] as bool? ?? false,
      requiresAuth: json['requiresAuth'] as bool? ?? false,
    );
  }
}

class VpsServerModel {
  final String id;
  final String name;
  final String subtitle;
  final String host;
  final int port;
  final String protocol;
  final String username;
  final String password;
  final String sniHost;
  final String dnsPrimary;
  final int mtu;
  final int keepAliveSec;
  final bool autoReconnect;
  final bool isAuto;

  const VpsServerModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.host,
    required this.port,
    required this.protocol,
    this.username = '',
    this.password = '',
    this.sniHost = '',
    this.dnsPrimary = '1.1.1.1',
    this.mtu = 1500,
    this.keepAliveSec = 10,
    this.autoReconnect = true,
    this.isAuto = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subtitle': subtitle,
        'host': host,
        'port': port,
        'protocol': protocol,
        'username': username,
        'password': password,
        'sniHost': sniHost,
        'dnsPrimary': dnsPrimary,
        'mtu': mtu,
        'keepAliveSec': keepAliveSec,
        'autoReconnect': autoReconnect,
        'isAuto': isAuto,
      };

  factory VpsServerModel.fromJson(Map<String, dynamic> json) {
    return VpsServerModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Custom VPS',
      subtitle: json['subtitle'] as String? ?? '',
      host: json['host'] as String? ?? '',
      port: (json['port'] as num?)?.toInt() ?? 1194,
      protocol: json['protocol'] as String? ?? 'UDP',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      sniHost: json['sniHost'] as String? ?? '',
      dnsPrimary: json['dnsPrimary'] as String? ?? '1.1.1.1',
      mtu: (json['mtu'] as num?)?.toInt() ?? 1500,
      keepAliveSec: (json['keepAliveSec'] as num?)?.toInt() ?? 10,
      autoReconnect: json['autoReconnect'] as bool? ?? true,
      isAuto: json['isAuto'] as bool? ?? false,
    );
  }
}

class TrafficSample {
  final double downloadKbps;
  final double uploadKbps;

  const TrafficSample(this.downloadKbps, this.uploadKbps);
}
