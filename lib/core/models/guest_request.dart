class VendorType {
  const VendorType(this.code);

  final String code;

  static const water = VendorType('Water');
  static const drinks = VendorType('Drinks');
  static const cleaning = VendorType('Cleaning');
  static const maintenance = VendorType('Maintenance');
  static const other = VendorType('Other');

  static const List<VendorType> defaults = [
    water,
    drinks,
    cleaning,
    maintenance,
    other,
  ];

  String get key => code.toLowerCase();

  @override
  bool operator ==(Object other) => other is VendorType && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

class RequestUrgency {
  const RequestUrgency(this.name);

  final String name;

  static const normal = RequestUrgency('Normal');
  static const urgent = RequestUrgency('Urgent');
  static const emergency = RequestUrgency('Emergency');

  static const List<RequestUrgency> defaults = [normal, urgent, emergency];

  String get key => name.toLowerCase();

  @override
  bool operator ==(Object other) =>
      other is RequestUrgency && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

enum RequestStatus { newRequest, assigned, inProgress, done, cancelled, failed }

class CatalogueItem {
  const CatalogueItem({
    required this.id,
    required this.vendorType,
    required this.nameEn,
    required this.nameAr,
    required this.price,
    required this.chargeable,
  });

  final String id;
  final VendorType vendorType;
  final String nameEn;
  final String nameAr;

  final double price;
  final bool chargeable;
}

class RequestLine {
  const RequestLine({required this.item, required this.qty});

  final CatalogueItem item;
  final int qty;

  double get lineTotal => item.chargeable ? item.price * qty : 0;
}

class GuestRequest {
  const GuestRequest({
    required this.reference,
    required this.vendorType,
    required this.lines,
    required this.urgency,
    required this.note,
    required this.createdAt,
    required this.status,
    this.history = const [],
    this.cancelReason,
    this.rating,
    this.version,
    this.allowChange = false,
    this.allowCancel = false,
  });

  final String reference;
  final VendorType vendorType;
  final List<RequestLine> lines;
  final RequestUrgency urgency;
  final String note;
  final DateTime createdAt;
  final RequestStatus status;

  final List<RequestStatusEntry> history;
  final String? cancelReason;
  final RequestRating? rating;

  final String? version;
  final bool allowChange;
  final bool allowCancel;


  String get shortReference => reference.length >= 32
      ? 'REQ-${reference.substring(0, 8).toUpperCase()}'
      : reference;


  bool get canChange => allowChange && version != null;

  bool get canCancel => allowCancel && version != null;

  bool get canRate {
    if (status != RequestStatus.done || rating != null) return false;
    final doneAt = reachedAt(RequestStatus.done);
    if (doneAt == null) return false;
    return DateTime.now().difference(doneAt) <= const Duration(hours: 24);
  }

  DateTime? reachedAt(RequestStatus target) {
    for (final entry in history) {
      if (entry.status == target) return entry.at;
    }
    return target == RequestStatus.newRequest ? createdAt : null;
  }

  GuestRequest copyWith({
    List<RequestLine>? lines,
    RequestUrgency? urgency,
    RequestStatus? status,
    List<RequestStatusEntry>? history,
    String? cancelReason,
    RequestRating? rating,
  }) {
    return GuestRequest(
      reference: reference,
      vendorType: vendorType,
      lines: lines ?? this.lines,
      urgency: urgency ?? this.urgency,
      note: note,
      createdAt: createdAt,
      status: status ?? this.status,
      history: history ?? this.history,
      cancelReason: cancelReason ?? this.cancelReason,
      rating: rating ?? this.rating,
      version: version,
      allowChange: allowChange,
      allowCancel: allowCancel,
    );
  }
}

class RequestStatusEntry {
  const RequestStatusEntry({required this.status, required this.at});

  final RequestStatus status;
  final DateTime at;
}

class RequestRating {
  const RequestRating({
    required this.stars,
    required this.ratedAt,
    this.comment = '',
  });

  final int stars;
  final String comment;
  final DateTime ratedAt;
}

double requestTotal(List<RequestLine> lines) {
  return lines.fold<double>(0, (sum, line) => sum + line.lineTotal);
}
