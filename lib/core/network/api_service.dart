import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

import 'package:gest_managment_app/core/network/api_client.dart';
import 'package:gest_managment_app/core/network/api_config.dart';
import 'package:gest_managment_app/core/models/app_notification.dart';
import 'package:gest_managment_app/core/models/survey.dart';
import 'package:gest_managment_app/core/models/case_status.dart';
import 'package:gest_managment_app/core/models/chat_message.dart';
import 'package:gest_managment_app/core/models/data_request.dart';
import 'package:gest_managment_app/core/models/event_item.dart';
import 'package:gest_managment_app/core/models/feedback_item.dart';
import 'package:gest_managment_app/core/models/feedback_record.dart';
import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/network/session_store.dart';
import 'package:gest_managment_app/core/utils/request_lookups.dart';
import 'package:gest_managment_app/core/models/guest_stay.dart';
import 'package:gest_managment_app/core/models/loyalty.dart';
import 'package:gest_managment_app/core/models/offer.dart';
import 'package:gest_managment_app/core/models/restaurant.dart';

class Session {
  static GuestStay? currentStay;
  static String? token;
  static String? propertyId;
  static String? guestProfileId;
  static String? propertyName;

  static void applyToken(String jwt) {
    token = jwt;
    final claims = _decodeClaims(jwt);
    propertyId = claims['property_id'] as String?;
    guestProfileId = claims['guest_profile_id'] as String?;
  }

  static bool isExpiredJwt(String jwt, {DateTime? now}) {
    final exp = _decodeClaims(jwt)['exp'];
    if (exp is! num) return true;
    final expiry = DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000, isUtc: true);
    return !(now ?? DateTime.now().toUtc()).isBefore(expiry);
  }

  static Future<bool> restore() async {
    final saved = await SessionStore.load();
    if (saved == null) return false;
    if (isExpiredJwt(saved.token)) {
      await SessionStore.clear();
      return false;
    }
    applyToken(saved.token);
    propertyName = saved.propertyName;
    currentStay = saved.stay;
    unawaited(ApiService.prefetch());
    return true;
  }

  static Map<String, dynamic> _decodeClaims(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return const {};
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final decoded = jsonDecode(payload);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } catch (_) {
      return const {};
    }
  }

  static void signOut() {
    ApiService.unregisterPushToken();
    SessionStore.clear();
    currentStay = null;
    token = null;
    propertyId = null;
    guestProfileId = null;
    propertyName = null;
    ApiService.clearCache();
  }
}

class _Cached<T> {
  _Cached(this.value) : at = DateTime.now();

  final T value;
  final DateTime at;

  bool fresh(Duration life) => DateTime.now().difference(at) < life;
}

class ApiService {
  static const String baseUrl = ApiConfig.baseUrl;

  static const Duration _publicCacheLife = Duration(minutes: 5);
  static const Duration _loyaltyCacheLife = Duration(seconds: 30);
  static _Cached<List<EventItem>>? _eventsCache;
  static _Cached<List<Restaurant>>? _restaurantsCache;
  static _Cached<LoyaltyAccount>? _loyaltyCache;

  static void clearCache() {
    _exportIds.clear();
    myNotificationsByRoom.clear();
    _eventsCache = null;
    _restaurantsCache = null;
    _loyaltyCache = null;
    _catalogueCache.clear();
  }


  static Future<void> prefetch() async {
    final api = ApiService();
    Future<void> safe(Future<void> Function() job) async {
      try {
        await job();
      } catch (_) {}
    }

    await Future.wait([
      safe(() => api.getEvents(refresh: true)),
      safe(() => api.getRestaurants(refresh: true)),
      safe(() => api.getLoyalty(refresh: true)),
      safe(() => api._ensureCatalogue()),
    ]);
  }

  static final Map<String, List<AppNotification>> myNotificationsByRoom =
      <String, List<AppNotification>>{};

  static String? lastPushToken;

  static final List<String> _exportIds = <String>[];

  Future<List<Survey>> getSurveys() async {
    final json = await ApiClient.get('/api/guest-app/surveys');
    final pending = (json['data'] as List?) ?? const [];

    final loaded = await Future.wait(
      pending.map((item) => _loadSurvey(item as Map<String, dynamic>)),
    );
    final surveys = [for (final survey in loaded) ?survey];
    surveys.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    return surveys;
  }

  Future<int> getWaitingSurveyCount() async {
    final json = await ApiClient.get('/api/guest-app/surveys');
    return ((json['data'] as List?) ?? const []).length;
  }

  Future<Survey?> _loadSurvey(Map<String, dynamic> pending) async {
    try {
      final json = await ApiClient.get(
        '/api/guest-app/surveys/${pending['dispatchId']}',
      );
      final survey = surveyFromJson(
        json['data'] as Map<String, dynamic>,
        receivedAt: _parseUtc(pending['dispatchedAtUtc'] as String),
      );
      // A survey without questions cannot be answered, so it is not shown.
      return survey.questions.isEmpty ? null : survey;
    } on ApiException catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
    }
  }

  static Survey surveyFromJson(
    Map<String, dynamic> j, {
    required DateTime receivedAt,
  }) {
    String pick(String en, String ar) {
      final english = '${j[en] ?? ''}'.trim();
      return english.isNotEmpty ? english : '${j[ar] ?? ''}'.trim();
    }

    final rawQuestions = [
      for (final q in (j['questions'] as List?) ?? const [])
        q as Map<String, dynamic>,
    ]..sort((a, b) => ((a['sortOrder'] as num?) ?? 0)
        .compareTo((b['sortOrder'] as num?) ?? 0));

    return Survey(
      id: '${j['dispatchId']}',
      title: pick('titleEn', 'titleAr'),
      contextLabel: pick('descriptionEn', 'descriptionAr'),
      questions: [
        for (final q in rawQuestions)
          SurveyQuestion(
            id: '${q['id']}',
            type: _surveyQuestionTypeFrom(q['questionType']),
            text: '${q['textEn'] ?? ''}'.trim().isNotEmpty
                ? '${q['textEn']}'.trim()
                : '${q['textAr'] ?? ''}'.trim(),
            isRequired: q['isRequired'] != false,
          ),
      ],
      receivedAt: receivedAt,
      status: j['isAlreadyAnswered'] == true
          ? SurveyStatus.answered
          : SurveyStatus.waiting,
    );
  }

  static SurveyQuestionType _surveyQuestionTypeFrom(Object? value) {
    switch ('$value'.toLowerCase()) {
      case 'csat':
        return SurveyQuestionType.csat;
      case 'nps':
        return SurveyQuestionType.nps;
      default:
        return SurveyQuestionType.comment;
    }
  }

  Future<void> submitSurvey(String id, List<SurveyAnswer> answers) async {
    final body = {
      'answers': [
        for (final answer in answers)
          if (answer.rating != null ||
              (answer.comment?.trim().isNotEmpty ?? false))
            {
              'questionId': answer.questionId,
              'numericValue': answer.rating,
              'textValue': answer.comment?.trim(),
            },
      ],
    };

    try {
      await ApiClient.post('/api/guest-app/surveys/$id/submit', body);
    } on ApiException catch (error) {
      if (error.statusCode == 409) throw SurveyAlreadyAnsweredException();
      if (error.statusCode == 404) throw SurveyNotFoundException();
      rethrow;
    }
  }

  Future<List<Offer>> getOffers() async {
    final json = await ApiClient.get('/api/guest-app/offers');
    final list = (json['data'] as List?) ?? const [];
    final offers = [
      for (final item in list) offerFromJson(item as Map<String, dynamic>),
    ];
    offers.sort((a, b) => a.validUntil.compareTo(b.validUntil));
    return offers;
  }

  Future<void> markOfferOpened(String id) async {
    await ApiClient.post('/api/guest-app/offers/$id/open', null);
  }

  static Offer offerFromJson(Map<String, dynamic> j) {
    final titleEn = '${j['offerTitleEn'] ?? ''}'.trim();
    final titleAr = '${j['offerTitleAr'] ?? ''}'.trim();
    final descEn = '${j['descriptionEn'] ?? ''}'.trim();
    final descAr = '${j['descriptionAr'] ?? ''}'.trim();
    final status = _offerStatusName(j['status']);
    final openedAt = j['openedAtUtc'] as String?;
    final redeemedAt = j['redeemedAtUtc'] as String?;

    return Offer(
      id: '${j['id']}',
      title: titleEn.isNotEmpty ? titleEn : titleAr,
      type: _offerTypeFrom(j['offerType']),
      validUntil: _parseUtc(j['expiredAtUtc'] as String),
      code: '${j['redemptionCode'] ?? ''}',
      description: descEn.isNotEmpty ? descEn : descAr,
      opened: status == 'opened' || openedAt != null,
      redeemedAt: redeemedAt != null
          ? _parseUtc(redeemedAt)
          : (status == 'redeemed' ? DateTime.now() : null),
      expiredByServer: status == 'expired',
    );
  }

  static String _offerStatusName(Object? value) {
    switch ('$value'.toLowerCase()) {
      case '1':
        return 'sent';
      case '2':
        return 'opened';
      case '3':
        return 'redeemed';
      case '4':
        return 'expired';
      default:
        return '$value'.toLowerCase();
    }
  }

  static OfferType _offerTypeFrom(Object? value) {
    switch ('$value'.toLowerCase()) {
      case 'discount':
      case '1':
        return OfferType.discount;
      case 'roomupgrade':
      case '2':
        return OfferType.roomUpgrade;
      case 'bonuspoints':
      case '3':
        return OfferType.bonusPoints;
      default:
        return OfferType.freeItem;
    }
  }

  Future<List<DataRequest>> getDataRequests() async {
    final results = await Future.wait([_loadExports(), _loadRemovals()]);
    final list = <DataRequest>[...results[0], ...results[1]];
    list.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    return list;
  }

  Future<List<DataRequest>> _loadExports() async {
    final loaded = <DataRequest>[];
    for (final id in List<String>.from(_exportIds)) {
      try {
        final json = await ApiClient.get('/api/guest-app/exports/$id');
        loaded.add(
          dataRequestFromExportJson(json['data'] as Map<String, dynamic>),
        );
      } on ApiException catch (error) {
        if (error.statusCode == 404) {
          _exportIds.remove(id);
        } else {
          rethrow;
        }
      }
    }
    return loaded;
  }

  Future<List<DataRequest>> _loadRemovals() async {
    final Map<String, dynamic> json;
    try {
      json = await ApiClient.get('/api/guest-app/anonymization');
    } on ApiException catch (error) {
      // Not deployed yet on the server: show the page with no deletion requests.
      if (error.statusCode == 404) return const <DataRequest>[];
      rethrow;
    }
    final rows = (json['data'] as List?) ?? const [];
    return [
      for (final row in rows)
        dataRequestFromRemovalJson(row as Map<String, dynamic>),
    ];
  }

  Future<DataRequest> requestDataExport() async {
    final json = await ApiClient.post(
      '/api/guest-app/exports',
      <String, dynamic>{},
    );
    final request = dataRequestFromExportJson(
      json['data'] as Map<String, dynamic>,
    );
    if (!_exportIds.contains(request.id)) _exportIds.add(request.id);
    return request;
  }

  Future<DataRequest> requestDataDeletion() async {
    final json = await ApiClient.post(
      '/api/guest-app/anonymization',
      <String, dynamic>{},
    );
    return dataRequestFromRemovalJson(json['data'] as Map<String, dynamic>);
  }

  static DataRequestStatus _exportStatusFrom(Object? value) {
    switch ('$value'.toLowerCase()) {
      case 'processing':
      case 'retrypending':
        return DataRequestStatus.inProgress;
      case 'ready':
      case 'expired':
        return DataRequestStatus.done;
      case 'failed':
      case 'revoked':
        return DataRequestStatus.failed;
      default:
        return DataRequestStatus.pending;
    }
  }

  static DataRequestStatus _removalStatusFrom(Object? value) {
    switch ('$value'.toLowerCase()) {
      case 'processing':
      case 'retrypending':
        return DataRequestStatus.inProgress;
      case 'completed':
        return DataRequestStatus.done;
      case 'failed':
      case 'cancelled':
        return DataRequestStatus.failed;
      default:
        return DataRequestStatus.pending;
    }
  }

  static DataRequest dataRequestFromExportJson(Map<String, dynamic> j) {
    final isExpired = '${j['status']}'.toLowerCase() == 'expired';
    final readyRaw = j['readyAtUtc'] as String?;
    final expiresRaw = j['expiresAtUtc'] as String?;
    var expires = expiresRaw == null ? null : _parseUtc(expiresRaw);
    if (isExpired && (expires == null || expires.isAfter(DateTime.now()))) {
      expires = DateTime.now().subtract(const Duration(seconds: 1));
    }
    return DataRequest(
      id: '${j['exportId']}',
      type: DataRequestType.export,
      status: _exportStatusFrom(j['status']),
      requestedAt: _parseUtc(j['requestedAtUtc'] as String),
      completedAt: readyRaw == null ? null : _parseUtc(readyRaw),
      downloadExpiresAt: expires,
    );
  }

  static DataRequest dataRequestFromRemovalJson(Map<String, dynamic> j) {
    final completedRaw = j['completedAtUtc'] as String?;
    return DataRequest(
      id: '${j['requestId']}',
      type: DataRequestType.delete,
      status: _removalStatusFrom(j['status']),
      requestedAt: _parseUtc(j['requestedAtUtc'] as String),
      completedAt: completedRaw == null ? null : _parseUtc(completedRaw),
    );
  }

  Future<LoyaltyAccount> getLoyalty({bool refresh = false}) async {
    final cached = _loyaltyCache;
    if (!refresh && cached != null && cached.fresh(_loyaltyCacheLife)) {
      return cached.value;
    }
    final value = await _fetchLoyalty();
    _loyaltyCache = _Cached(value);
    return value;
  }

  Future<LoyaltyAccount> _fetchLoyalty() async {
    final json = await ApiClient.get('/api/guest-app/loyalty');
    final data = json['data'] as Map<String, dynamic>;

    final recent = (data['recent'] as List?) ?? const [];
    final entries = <LoyaltyEntry>[];
    for (var i = 0; i < recent.length; i++) {
      entries.add(_loyaltyEntryFromJson(recent[i] as Map<String, dynamic>, i));
    }
    entries.sort((a, b) => b.date.compareTo(a.date));

    return LoyaltyAccount(
      entries: entries,
      balance: (data['availablePoints'] as num?)?.toInt() ?? 0,
      tierPoints: (data['rollingEarnedPoints'] as num?)?.toInt() ?? 0,
      serverTierName: data['tier'] as String?,
      nextTierName: data['nextTierName'] as String?,
      nextTierThreshold: (data['nextTierThreshold'] as num?)?.toInt(),
      expiryMonths: (data['expiryMonths'] as num?)?.toInt(),
      fromServer: true,
    );
  }

   Future<({List<LoyaltyEntry> entries, int total})> getLoyaltyLedgerPage({
    required int page,
    required int pageSize,
  }) async {
    final json = await ApiClient.get(
      '/api/guest-app/loyalty/ledger',
      query: {'page': '$page', 'pageSize': '$pageSize'},
    );
    final list = (json['data'] as List?) ?? const [];
    final offset = (page - 1) * pageSize;
    final entries = <LoyaltyEntry>[
      for (var i = 0; i < list.length; i++)
        _loyaltyEntryFromJson(list[i] as Map<String, dynamic>, offset + i),
    ];
    final total =
        ((json['pagenation'] as Map?)?['total'] as num?)?.toInt() ??
        offset + entries.length;
    return (entries: entries, total: total);
  }

  static LoyaltyEntry _loyaltyEntryFromJson(Map<String, dynamic> j, int index) {
    final kind = '${j['type']}'.toLowerCase();
    // An unknown type from the backend gets a neutral icon and label.
    LoyaltyEntryType type = LoyaltyEntryType.other;
    String label = 'Activity';
    if (kind == 'earn') {
      type = LoyaltyEntryType.earn;
      label = 'Earned';
    } else if (kind == 'redeem') {
      type = LoyaltyEntryType.redeem;
      label = 'Redeemed';
    } else if (kind == 'expire') {
      type = LoyaltyEntryType.expire;
      label = 'Expired';
    } else if (kind == 'adjust') {
      type = LoyaltyEntryType.adjust;
      label = 'Adjustment';
    }

    final when = _parseUtc(j['occurredAtUtc'] as String);
    return LoyaltyEntry(
      id: '${j['occurredAtUtc']}-$index',
      type: type,
      points: (j['points'] as num?)?.toInt() ?? 0,
      reason: (j['reason'] as String?) ?? '',
      source: label,
      date: when,
    );
  }

  Future<List<AppNotification>> getNotifications() async {
    final room = Session.currentStay?.roomNumber ?? 'unknown';
    final list = List<AppNotification>.from(
      myNotificationsByRoom[room] ?? const <AppNotification>[],
    );
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  
  Future<void> markNotificationRead(String id) async {
    final room = Session.currentStay?.roomNumber ?? 'unknown';
    final list = myNotificationsByRoom[room];
    if (list == null) return;
    final index = list.indexWhere((n) => n.id == id);
    if (index != -1) list[index] = list[index].copyWith(read: true);
  }

  Future<void> markAllNotificationsRead() async {
    final room = Session.currentStay?.roomNumber ?? 'unknown';
    final list = myNotificationsByRoom[room];
    if (list == null) return;
    for (var i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(read: true);
    }
  }

  Future<void> deleteNotification(String id) async {
    final room = Session.currentStay?.roomNumber ?? 'unknown';
    myNotificationsByRoom[room]?.removeWhere((n) => n.id == id);
  }

  void addNotification(AppNotification notification) {
    final room = Session.currentStay?.roomNumber ?? 'unknown';
    final list = myNotificationsByRoom.putIfAbsent(room, () => <AppNotification>[]);
    if (list.any((n) => n.id == notification.id)) return;
    list.insert(0, notification);
  }

  static String _pushPlatform() {
    if (kIsWeb) return 'Web';
    return defaultTargetPlatform == TargetPlatform.iOS ? 'iOS' : 'Android';
  }

  Future<void> registerPushToken(String token) async {
    lastPushToken = token;
    try {
      await ApiClient.post('/api/guest-app/push-tokens', {
        'token': token,
        'platform': _pushPlatform(),
      });
    } catch (_) {}
  }

  static void unregisterPushToken() {
    final token = lastPushToken;
    if (token == null || Session.token == null) return;
    lastPushToken = null;
    ApiClient.delete('/api/guest-app/push-tokens', {'token': token})
        .then((_) {}, onError: (_) {});
  }

  static const int _messagesPageSize = 100;

  static MessageDeliveryStatus _deliveryStatusFrom(Object? value) {
    switch ('$value'.toLowerCase()) {
      case 'queued':
        return MessageDeliveryStatus.sending;
      case 'read':
        return MessageDeliveryStatus.read;
      case 'failed':
        return MessageDeliveryStatus.failed;
      default:
        return MessageDeliveryStatus.sent;
    }
  }

  static ChatMessage _chatMessageFromJson(Map<String, dynamic> j) {
    return ChatMessage(
      id: j['id'].toString(),
      text: (j['body'] as String?) ?? '',
      fromGuest: '${j['direction']}'.toLowerCase() == 'inbound',
      sentAt: _parseUtc(j['recordedAtUtc'] as String),
      status: _deliveryStatusFrom(j['deliveryStatus']),
    );
  }

  Future<List<ChatMessage>> _fetchMessagesPage(int page) async {
    final json = await ApiClient.get(
      '/api/guest-app/conversation/messages',
      query: {'page': '$page', 'size': '$_messagesPageSize'},
    );
    final list = (json['data'] as List?) ?? const [];
    final total =
        ((json['pagenation'] as Map?)?['total'] as num?)?.toInt() ?? list.length;
    _messagesTotal = total;
    return list
        .map((e) => _chatMessageFromJson(e as Map<String, dynamic>))
        .toList();
  }

  static int _messagesTotal = 0;

 
  Future<List<ChatMessage>> getMessages() async {
    final first = await _fetchMessagesPage(1);
    final lastPage = (_messagesTotal / _messagesPageSize).ceil();
    if (lastPage <= 1) return first;

    final last = await _fetchMessagesPage(lastPage);
    final result = <ChatMessage>[];
    if (last.length < _messagesPageSize) {
      result.addAll(await _fetchMessagesPage(lastPage - 1));
    }
    result.addAll(last);
    return result;
  }

  Future<ChatMessage> sendMessage(String text) async {
    final json = await ApiClient.post(
      '/api/guest-app/conversation/messages',
      {'body': text.trim()},
    );
    final id = (json['data'] as Map?)?['id']?.toString() ??
        'msg-${DateTime.now().microsecondsSinceEpoch}';
    return ChatMessage(
      id: id,
      text: text.trim(),
      fromGuest: true,
      sentAt: DateTime.now(),
      status: MessageDeliveryStatus.sent,
    );
  }

  static final Map<String, List<FeedbackRecord>> _sentFeedback = {};

  Future<GuestStay> signIn(String roomNumber, String lastName) async {
    try {
      final json = await ApiClient.post('/api/guest-auth/login', {
        'roomNumber': roomNumber.trim(),
        'lastName': lastName.trim(),
      }, auth: false);
      final data = json['data'] as Map<String, dynamic>;
      Session.applyToken(data['accessToken'] as String);
      final hotel = (data['propertyName'] as String?)?.trim();
      Session.propertyName = (hotel == null || hotel.isEmpty) ? null : hotel;
      final stay = GuestStay(
        guestName: data['guestName'] as String,
        roomNumber: data['roomNumber'] as String,
        checkout: DateTime.parse(data['checkoutDate'] as String),
      );
      Session.currentStay = stay;
      unawaited(SessionStore.save(
        token: Session.token!,
        stay: stay,
        propertyName: Session.propertyName,
      ));
      unawaited(prefetch());
      return stay;
    } on UnauthorizedException {
      throw InvalidCredentialsException();
    }
  }
 
  Future<List<EventItem>> getEvents({bool refresh = false}) async {
    final cached = _eventsCache;
    if (!refresh && cached != null && cached.fresh(_publicCacheLife)) {
      return cached.value;
    }
    final value = await _fetchEvents();
    _eventsCache = _Cached(value);
    return value;
  }

  Future<List<EventItem>> _fetchEvents() async {
    final propertyId = Session.propertyId;
    if (propertyId == null) throw UnauthorizedException('Please sign in again.');

    final query = <String, String>{'from': _ymd(DateTime.now())};
    final checkout = Session.currentStay?.checkout;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    if (checkout != null && !DateTime(checkout.year, checkout.month, checkout.day).isBefore(todayOnly)) {
      query['to'] = _ymd(checkout);
    }

    final json = await ApiClient.get(
      '/api/public/properties/$propertyId/events',
      query: query,
      auth: false,
    );
    final list = (json['data'] as List?) ?? const [];
    return list
        .map((e) => _eventFromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Restaurant>> getRestaurants({bool refresh = false}) async {
    final cached = _restaurantsCache;
    if (!refresh && cached != null && cached.fresh(_publicCacheLife)) {
      return cached.value;
    }
    final value = await _fetchRestaurants();
    _restaurantsCache = _Cached(value);
    return value;
  }

  Future<List<Restaurant>> _fetchRestaurants() async {
    final propertyId = Session.propertyId;
    if (propertyId == null) throw UnauthorizedException('Please sign in again.');

    final json = await ApiClient.get(
      '/api/public/properties/$propertyId/restaurants',
      auth: false,
    );
    final list = (json['data'] as List?) ?? const [];
    return list
        .map((e) => _restaurantFromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String _text(Object? en, Object? ar) {
    final e = (en as String?)?.trim() ?? '';
    if (e.isNotEmpty) return e;
    return (ar as String?)?.trim() ?? '';
  }

  static String? _hhmm(Object? value) {
    final s = (value as String?)?.trim() ?? '';
    if (s.length < 5) return null;
    return s.substring(0, 5);
  }

  static EventItem _eventFromJson(Map<String, dynamic> j) {
    return EventItem(
      id: j['id'] as String,
      title: _text(j['titleEn'], j['titleAr']),
      date: DateTime.parse(j['eventDate'] as String),
      startTime: _hhmm(j['startTime']) ?? '00:00',
      endTime: _hhmm(j['endTime']) ?? '00:00',
      place: (j['location'] as String?) ?? '',
      type: '${j['eventType']}'.toLowerCase() == 'party'
          ? EventType.party
          : EventType.event,
      description: _text(j['descriptionEn'], j['descriptionAr']),
    );
  }

  static const Map<String, int> _weekdayByName = {
    'mon': 1,
    'tue': 2,
    'wed': 3,
    'thu': 4,
    'fri': 5,
    'sat': 6,
    'sun': 7,
  };

  static const List<String> _weekdayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static Restaurant _restaurantFromJson(Map<String, dynamic> j) {
    final raw = (j['openDays'] as String?) ?? '';
    final days = <int>{};
    for (final token in raw.split(RegExp(r'[,\s;]+'))) {
      if (token.length < 3) continue;
      final day = _weekdayByName[token.substring(0, 3).toLowerCase()];
      if (day != null) days.add(day);
    }

    final stated = days.isNotEmpty;
    final weekdays = stated ? (days.toList()..sort()) : [1, 2, 3, 4, 5, 6, 7];
    final label = !stated
        ? 'Opening days not listed'
        : weekdays.length == 7
            ? 'Open every day'
            : weekdays.map((d) => _weekdayNames[d - 1]).join(', ');

    return Restaurant(
      name: _text(j['nameEn'], j['nameAr']),
      openDays: label,
      openWeekdays: weekdays,
      breakfast: MealHours(
        open: _hhmm(j['breakfastStart']),
        close: _hhmm(j['breakfastEnd']),
      ),
      lunch: MealHours(
        open: _hhmm(j['lunchStart']),
        close: _hhmm(j['lunchEnd']),
      ),
      dinner: MealHours(
        open: _hhmm(j['dinnerStart']),
        close: _hhmm(j['dinnerEnd']),
      ),
    );
  }

  Future<List<FeedbackRecord>> getMyFeedback() async {
    final records =
        _sentFeedback[Session.guestProfileId ?? ''] ?? const <FeedbackRecord>[];
    return List<FeedbackRecord>.from(records)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<String> sendFeedback(FeedbackItem item) async {
    final message = item.message.trim();
    final json = await ApiClient.post('/api/guest-app/feedback', {
      'feedbackType': feedbackTypeName(item.type),
      'category': feedbackCategoryName(item.category),
      'message': message,
    });

    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final reference = '${data['referenceNumber'] ?? ''}';

    _sentFeedback
        .putIfAbsent(Session.guestProfileId ?? '', () => <FeedbackRecord>[])
        .add(
          FeedbackRecord(
            reference: reference,
            type: item.type,
            category: item.category,
            message: message,
            createdAt: DateTime.now(),
            status: CaseStatus.open,
          ),
        );

    return reference;
  }

  static String feedbackTypeName(FeedbackType type) {
    return type == FeedbackType.complaint ? 'Complaint' : 'Feedback';
  }

  static String feedbackCategoryName(FeedbackCategory category) {
    return category.name;
  }


  static final Map<String, CatalogueItem> _catalogueCache = {};

  Future<List<CatalogueItem>> _loadCatalogue() async {
    await RequestLookups.ensureLoaded();
    final json = await ApiClient.get('/api/guest-app/catalogue');
    final list = (json['data'] as List?) ?? const [];
    final items = list
        .map((e) => _catalogueItemFromJson(e as Map<String, dynamic>))
        .toList();
    _catalogueCache
      ..clear()
      ..addEntries(items.map((i) => MapEntry(i.id, i)));
    return items;
  }

  Future<void> _ensureCatalogue() async {
    if (_catalogueCache.isNotEmpty) return;
    try {
      await _loadCatalogue();
    } catch (_) {
    }
  }

  Future<List<CatalogueItem>> getCatalogue(VendorType type) async {
    final items = await _loadCatalogue();
    return items.where((item) => item.vendorType == type).toList();
  }


  static DateTime _parseUtc(String value) {
    final hasZone =
        value.endsWith('Z') || RegExp(r'[+-]\d\d:\d\d$').hasMatch(value);
    return DateTime.parse(hasZone ? value : '${value}Z').toLocal();
  }

  static VendorType _vendorTypeFrom(Object? value) {
    final text = value == null ? '' : '$value'.trim();
    return text.isEmpty ? VendorType.other : VendorType(text);
  }

  static RequestUrgency _urgencyFrom(Object? value) {
    final text = value is String ? value.trim() : '';
    return text.isEmpty ? RequestUrgency.normal : RequestUrgency(text);
  }

  static String _urgencyName(RequestUrgency urgency) => urgency.name;

  static RequestStatus _requestStatusFrom(Object? value) {
    switch ('$value'.toLowerCase()) {
      case 'assigned':
        return RequestStatus.assigned;
      case 'inprogress':
        return RequestStatus.inProgress;
      case 'done':
        return RequestStatus.done;
            case 'cancelled':
        return RequestStatus.cancelled;
      case 'failed':
        return RequestStatus.failed;

      default:
        return RequestStatus.newRequest;
    }
  }

  static CatalogueItem _catalogueItemFromJson(Map<String, dynamic> j) {
    return CatalogueItem(
      id: j['id'] as String,
      vendorType: _vendorTypeFrom(j['vendorType']),
      nameEn: _text(j['nameEn'], j['nameAr']),
      nameAr: (j['nameAr'] as String?) ?? '',
      price: (j['price'] as num?)?.toDouble() ?? 0,
      chargeable: (j['isChargeable'] as bool?) ?? false,
    );
  }

  static GuestRequest _requestFromJson(Map<String, dynamic> j) {
    final lines = <RequestLine>[];
    for (final raw in (j['items'] as List?) ?? const []) {
      final m = raw as Map<String, dynamic>;
      final id = m['catalogueItemId'] as String;
      final known = _catalogueCache[id];
      lines.add(
        RequestLine(
          item: CatalogueItem(
            id: id,
            vendorType: known?.vendorType ?? VendorType.other,
            nameEn: _text(m['nameEn'], m['nameAr']),
            nameAr: (m['nameAr'] as String?) ?? '',
            price: (m['unitPrice'] as num?)?.toDouble() ?? 0,
            chargeable: (m['isChargeable'] as bool?) ?? false,
          ),
          qty: (m['quantity'] as num?)?.toInt() ?? 1,
        ),
      );
    }

    final history = <RequestStatusEntry>[];
    for (final raw in (j['statusHistory'] as List?) ?? const []) {
      final m = raw as Map<String, dynamic>;
      history.add(
        RequestStatusEntry(
          status: _requestStatusFrom(m['status']),
          at: _parseUtc(m['changedAtUtc'] as String),
        ),
      );
    }

    RequestRating? rating;
    final ratingJson = j['rating'];
    if (ratingJson is Map<String, dynamic>) {
      rating = RequestRating(
        stars: (ratingJson['stars'] as num?)?.toInt() ?? 0,
        comment: (ratingJson['comment'] as String?) ?? '',
        ratedAt: _parseUtc(ratingJson['createdAtUtc'] as String),
      );
    }

    final allowed = j['allowedActions'];

    return GuestRequest(
      reference: j['id'] as String,
      vendorType:
          lines.isEmpty ? VendorType.other : lines.first.item.vendorType,
      lines: lines,
      urgency: _urgencyFrom(j['urgency']),
      note: (j['note'] as String?) ?? '',
      createdAt: _parseUtc(j['createdAtUtc'] as String),
      status: _requestStatusFrom(j['status']),
      history: history,
      rating: rating,
      version: j['version'] as String?,
      allowChange: allowed is Map && allowed['canChange'] == true,
      allowCancel: allowed is Map && allowed['canCancel'] == true,
    );
  }


  Future<GuestRequest> sendRequest({
    required VendorType vendorType,
    required RequestUrgency urgency,
    required List<RequestLine> lines,
    required String clientOperationId,
    String note = '',
  }) async {
    final body = <String, dynamic>{
      'clientOperationId': clientOperationId,
      'items': [
        for (final line in lines)
          {'catalogueItemId': line.item.id, 'quantity': line.qty},
      ],
      'urgency': _urgencyName(urgency),
    };
    if (note.trim().isNotEmpty) body['note'] = note.trim();

    final json = await ApiClient.post('/api/guest-app/requests', body);
    return _requestFromJson(json['data'] as Map<String, dynamic>);
  }

  Future<List<GuestRequest>> getMyRequests() async {
    await RequestLookups.ensureLoaded();
    await _ensureCatalogue();
    final json = await ApiClient.get(
      '/api/guest-app/requests',
      query: {'page': '1', 'size': '100'},
    );
    final list = (json['data'] as List?) ?? const [];
    return list
        .map((e) => _requestFromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<GuestRequest> getRequest(String reference) async {
    await _ensureCatalogue();
    final json = await ApiClient.get('/api/guest-app/requests/$reference');
    return _requestFromJson(json['data'] as Map<String, dynamic>);
  }

  Future<GuestRequest> changeRequest({
    required GuestRequest request,
    required List<RequestLine> lines,
    required RequestUrgency urgency,
  }) async {
    await _ensureCatalogue();
    final json = await ApiClient.put(
      '/api/guest-app/requests/${request.reference}',
      {
        'expectedVersion': request.version,
        'items': [
          for (final line in lines)
            {'catalogueItemId': line.item.id, 'quantity': line.qty},
        ],
        'urgency': _urgencyName(urgency),
      },
    );
    return _requestFromJson(json['data'] as Map<String, dynamic>);
  }

  Future<GuestRequest> cancelRequest({
    required GuestRequest request,
    required String reason,
  }) async {
    await _ensureCatalogue();
    final json = await ApiClient.post(
      '/api/guest-app/requests/${request.reference}/cancel',
      {'expectedVersion': request.version, 'reason': reason},
    );
    return _requestFromJson(json['data'] as Map<String, dynamic>);
  }

  Future<GuestRequest> rateRequest({
    required String reference,
    required int stars,
    String comment = '',
  }) async {
    final body = <String, dynamic>{'stars': stars};
    if (comment.trim().isNotEmpty) body['comment'] = comment.trim();

    await ApiClient.post('/api/guest-app/requests/$reference/rating', body);
    return getRequest(reference);
  }
}

class InvalidCredentialsException implements Exception {}


