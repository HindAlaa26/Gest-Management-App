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
  });

  final String reference;
  final VendorType vendorType;
  final List<RequestLine> lines;
  final RequestUrgency urgency;
  final String note;
  final DateTime createdAt;
  final RequestStatus status;
}

double requestTotal(List<RequestLine> lines) {
  return lines.fold<double>(0, (sum, line) => sum + line.lineTotal);
}
