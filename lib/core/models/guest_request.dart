enum VendorType { water, drinks, cleaning, maintenance, other }

enum RequestUrgency { normal, urgent }

enum RequestStatus { newRequest, assigned, inProgress, done, cancelled }

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

  bool get canChange =>
      status == RequestStatus.newRequest || status == RequestStatus.assigned;

  bool get canCancel =>
      status == RequestStatus.newRequest || status == RequestStatus.assigned;

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
