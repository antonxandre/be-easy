/// DTO para transferir configurações do terminal entre Servidor e App
class AdminConfigDto {
  final String pixKey;
  final String merchantName;
  final String merchantCity;
  final double unitPrice;
  final String wifiSsid;
  final String wifiPassword;
  final String customIp;
  final int serverPort;
  final String selectedPrinter;
  final bool useMockPrinter;
  final bool hasAdminPassword;

  AdminConfigDto({
    required this.pixKey,
    required this.merchantName,
    required this.merchantCity,
    required this.unitPrice,
    required this.wifiSsid,
    required this.wifiPassword,
    required this.customIp,
    required this.serverPort,
    required this.selectedPrinter,
    required this.useMockPrinter,
    this.hasAdminPassword = true,
  });

  factory AdminConfigDto.fromJson(Map<String, dynamic> json) => AdminConfigDto(
        pixKey: json['pixKey'] as String? ?? '65717703000180',
        merchantName: json['merchantName'] as String? ?? 'BE EASY PRINT',
        merchantCity: json['merchantCity'] as String? ?? 'SAO PAULO',
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 2.0,
        wifiSsid: json['wifiSsid'] as String? ?? 'BE EASY - TEFNet_5g',
        wifiPassword: json['wifiPassword'] as String? ?? 'clientebeeasy7789@',
        customIp: json['customIp'] as String? ?? '',
        serverPort: json['serverPort'] as int? ?? 8080,
        selectedPrinter: json['selectedPrinter'] as String? ?? '',
        useMockPrinter: json['useMockPrinter'] as bool? ?? true,
        hasAdminPassword: json['hasAdminPassword'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'pixKey': pixKey,
        'merchantName': merchantName,
        'merchantCity': merchantCity,
        'unitPrice': unitPrice,
        'wifiSsid': wifiSsid,
        'wifiPassword': wifiPassword,
        'customIp': customIp,
        'serverPort': serverPort,
        'selectedPrinter': selectedPrinter,
        'useMockPrinter': useMockPrinter,
      };

  AdminConfigDto copyWith({
    String? pixKey,
    String? merchantName,
    String? merchantCity,
    double? unitPrice,
    String? wifiSsid,
    String? wifiPassword,
    String? customIp,
    int? serverPort,
    String? selectedPrinter,
    bool? useMockPrinter,
    bool? hasAdminPassword,
  }) {
    return AdminConfigDto(
      pixKey: pixKey ?? this.pixKey,
      merchantName: merchantName ?? this.merchantName,
      merchantCity: merchantCity ?? this.merchantCity,
      unitPrice: unitPrice ?? this.unitPrice,
      wifiSsid: wifiSsid ?? this.wifiSsid,
      wifiPassword: wifiPassword ?? this.wifiPassword,
      customIp: customIp ?? this.customIp,
      serverPort: serverPort ?? this.serverPort,
      selectedPrinter: selectedPrinter ?? this.selectedPrinter,
      useMockPrinter: useMockPrinter ?? this.useMockPrinter,
      hasAdminPassword: hasAdminPassword ?? this.hasAdminPassword,
    );
  }
}

/// DTO para informações de impressoras detectadas no terminal
class PrinterInfoDto {
  final String name;
  final bool isDefault;
  final bool isMock;
  final String status;

  PrinterInfoDto({
    required this.name,
    this.isDefault = false,
    this.isMock = false,
    this.status = 'Pronta',
  });

  factory PrinterInfoDto.fromJson(Map<String, dynamic> json) => PrinterInfoDto(
        name: json['name'] as String? ?? 'Desconhecida',
        isDefault: json['isDefault'] as bool? ?? false,
        isMock: json['isMock'] as bool? ?? false,
        status: json['status'] as String? ?? 'Pronta',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'isDefault': isDefault,
        'isMock': isMock,
        'status': status,
      };
}
