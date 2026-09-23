class PrintJobDto {
  final String id;
  final String fileName;
  final int pageCount;
  final double unitPrice;
  final double totalPrice;
  final String status;
  final String source;
  final String pixPayload;
  final String pixTxid;
  final DateTime? createdAt;
  final DateTime? printedAt;

  PrintJobDto({
    required this.id,
    required this.fileName,
    required this.pageCount,
    required this.unitPrice,
    required this.totalPrice,
    required this.status,
    required this.source,
    required this.pixPayload,
    required this.pixTxid,
    this.createdAt,
    this.printedAt,
  });

  factory PrintJobDto.fromJson(Map<String, dynamic> json) {
    return PrintJobDto(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      pageCount: json['pageCount'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] as String,
      source: json['source'] as String? ?? 'desktop_usb',
      pixPayload: json['pixPayload'] as String? ?? '',
      pixTxid: json['pixTxid'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      printedAt: json['printedAt'] != null
          ? DateTime.tryParse(json['printedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fileName': fileName,
    'pageCount': pageCount,
    'unitPrice': unitPrice,
    'totalPrice': totalPrice,
    'status': status,
    'source': source,
    'pixPayload': pixPayload,
    'pixTxid': pixTxid,
  };
}
