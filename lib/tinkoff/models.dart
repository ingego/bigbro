import 'package:bigbro/tinkoff/api.dart';
import 'package:crypto/crypto.dart';

class PaymentRequest {
  final String terminalKey = terminal;
  //в копейках
  final int amount; // в копейках
  final String orderId;
  final String? ip;
  final String? description;
  final String? token;
  final String? language;
  final String? recurrent;
  final String? customerKey;
  final String? redirectDueDate;
  final String? notificationUrl;
  final String? successUrl;
  final String? failUrl;
  final String? payType;
  final Map<String, dynamic>? data;

  String subToken() {
    final params = {
      'TerminalKey': terminal,
      'Amount': amount.toString(),
      'OrderId': orderId,
    };

    if (description != null) params['Description'] = description!;
    if (token != null) params['Token'] = token!;
    if (language != null) params['Language'] = language!;
    if (recurrent != null) params['Recurrent'] = recurrent!;
    if (customerKey != null) params['CustomerKey'] = customerKey!;
    if (redirectDueDate != null) {
      params['RedirectDueDate'] =
          '${DateTime.tryParse(redirectDueDate!)!.toIso8601String().substring(0, 19)}+00:00';
    }
    if (notificationUrl != null) params['NotificationURL'] = notificationUrl!;
    if (successUrl != null) params['SuccessURL'] = successUrl!;
    if (failUrl != null) params['FailURL'] = failUrl!;

    params['Password'] = pass;

    final sortedParams = Map.fromEntries(
        params.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));

    final concatenatedValues = sortedParams.values.join();
    final hash = sha256.convert(concatenatedValues.codeUnits);

    return hash.toString();
  }

  PaymentRequest(
      {required this.amount, //в копейках
      required this.orderId,
      this.ip,
      this.description,
      this.token,
      this.language,
      this.recurrent,
      this.customerKey,
      this.redirectDueDate,
      this.notificationUrl,
      this.successUrl,
      this.failUrl,
      this.payType,
      this.data});

  factory PaymentRequest.fromJson(Map<String, dynamic> json) => PaymentRequest(
        amount: json['Amount'],
        orderId: json['OrderId'],
        ip: json['IP'],
        description: json['Description'],
        token: json['Token'],
        language: json['Language'],
        recurrent: json['Recurrent'],
        customerKey: json['CustomerKey'],
        redirectDueDate: json['RedirectDueDate'],
        notificationUrl: json['NotificationURL'],
        successUrl: json['SuccessURL'],
        failUrl: json['FailURL'],
        payType: json['PayType'],
      );

  Map<String, dynamic> toJson() => {
        'TerminalKey': terminal,
        'Amount': amount,
        'OrderId': orderId,
        //"DATA": {"Phone": "+71234567890", "Email": "a@test.com"},
        'Token': subToken(),
        'Description': description,
        "DATA": data,
        "SuccessURL": successUrl,
        // 'Language': language,
        // 'Recurrent': recurrent,
        // 'CustomerKey': customerKey,
        // 'RedirectDueDate': redirectDueDate,
        // 'NotificationURL': notificationUrl,
        // 'SuccessURL': successUrl,
        // 'FailURL': failUrl,
        // 'PayType': payType,
        //'Receipt': receipt?.toJson(),
      };

  PaymentRequest copyWith({
    String? terminalKey,
    int? amount,
    String? orderId,
    String? ip,
    String? description,
    String? token,
    String? language,
    String? recurrent,
    String? customerKey,
    String? redirectDueDate,
    String? notificationUrl,
    String? successUrl,
    String? failUrl,
    String? payType,
    Receipt? receipt,
  }) {
    return PaymentRequest(
      amount: amount ?? this.amount,
      orderId: orderId ?? this.orderId,
      ip: ip ?? this.ip,
      description: description ?? this.description,
      token: token ?? this.token,
      language: language ?? this.language,
      recurrent: recurrent ?? this.recurrent,
      customerKey: customerKey ?? this.customerKey,
      redirectDueDate: redirectDueDate ?? this.redirectDueDate,
      notificationUrl: notificationUrl ?? this.notificationUrl,
      successUrl: successUrl ?? this.successUrl,
      failUrl: failUrl ?? this.failUrl,
      payType: payType ?? this.payType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentRequest &&
          runtimeType == other.runtimeType &&
          terminalKey == other.terminalKey &&
          amount == other.amount &&
          orderId == other.orderId &&
          ip == other.ip &&
          description == other.description &&
          token == other.token &&
          language == other.language &&
          recurrent == other.recurrent &&
          redirectDueDate == other.redirectDueDate &&
          notificationUrl == other.notificationUrl &&
          successUrl == other.successUrl &&
          failUrl == other.failUrl &&
          payType == other.payType;
  @override
  int get hashCode =>
      terminalKey.hashCode ^
      amount.hashCode ^
      orderId.hashCode ^
      ip.hashCode ^
      description.hashCode ^
      token.hashCode ^
      language.hashCode ^
      recurrent.hashCode ^
      customerKey.hashCode ^
      redirectDueDate.hashCode ^
      notificationUrl.hashCode ^
      successUrl.hashCode ^
      failUrl.hashCode ^
      payType.hashCode;

  @override
  String toString() {
    return 'PaymentRequest{terminalKey: $terminalKey, amount: $amount, '
        'orderId: $orderId, ip: $ip, description: $description, '
        'token: $token, language: $language, recurrent: $recurrent, '
        'customerKey: $customerKey, redirectDueDate: $redirectDueDate, '
        'notificationUrl: $notificationUrl, successUrl: $successUrl, '
        'failUrl: $failUrl, payType: $payType, receipt: }';
  }
}

class Receipt {
  String? email;
  String? phone;
  String taxation;
  Items items;
  Payments? payments;
  String? additionalCheckProps;
  String? ffdVersion;

  Receipt({
    this.email,
    this.phone,
    required this.taxation,
    required this.items,
    this.payments,
    this.additionalCheckProps,
    this.ffdVersion,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
        email: json['Email'],
        phone: json['Phone'],
        taxation: json['Taxation'],
        items: Items.fromJson(json['Items']),
        payments: json.containsKey('Payments')
            ? Payments.fromJson(json['Payments'])
            : null,
        additionalCheckProps: json['AdditionalCheckProps'],
        ffdVersion: json['FfdVersion'],
      );

  Map<String, dynamic> toJson() => {
        'Email': email,
        'Phone': phone,
        'Taxation': taxation,
        'Items': items.toJson(),
        'Payments': payments?.toJson(),
        'AdditionalCheckProps': additionalCheckProps,
        'FfdVersion': ffdVersion,
      };
}

enum PaymentType { oneStage, twoStage }

class PaymentTypeHelper {
  static PaymentType fromString(String? paymentType) {
    switch (paymentType?.toUpperCase()) {
      case 'O':
        return PaymentType.oneStage;
      case 'T':
        return PaymentType.twoStage;
      default:
        return PaymentType.oneStage;
    }
  }

  static String? toStringValue(PaymentType paymentType) {
    switch (paymentType) {
      case PaymentType.oneStage:
        return 'O';
      case PaymentType.twoStage:
        return 'T';
      default:
        return null;
    }
  }
}

class PaymentResponse {
  final int amount;
  final String orderId;
  final bool success;
  final String? status;
  final String paymentId;
  final String errorCode;
  final String? paymentUrl;
  final String? message;
  final String? details;
  final String? token;

  PaymentResponse(
      {required this.amount,
      required this.orderId,
      required this.success,
      this.status,
      required this.paymentId,
      required this.errorCode,
      this.paymentUrl,
      this.message,
      this.details,
      this.token});

  factory PaymentResponse.fromJson(Map<String, dynamic> json) =>
      PaymentResponse(
        //  terminalKey: json['TerminalKey'],
        amount: json['Amount'],
        orderId: json['OrderId'],
        success: json['Success'],
        status: json['Status'],
        paymentId: json['PaymentId'],
        errorCode: json['ErrorCode'],
        paymentUrl: json['PaymentURL'],
        message: json['Message'],
        details: json['Details'],
      );

  Map<String, dynamic> toJson() => {
        'Amount': amount,
        'OrderId': orderId,
        'Success': success,
        'Status': status,
        'PaymentId': paymentId,
        'ErrorCode': errorCode,
        'PaymentURL': paymentUrl,
        'Message': message,
        'Details': details,
      };

  PaymentResponse copyWith({
    String? terminalKey,
    int? amount,
    String? orderId,
    bool? success,
    String? status,
    String? paymentId,
    String? errorCode,
    String? paymentUrl,
    String? message,
    String? details,
    String? token,
  }) {
    return PaymentResponse(
        amount: amount ?? this.amount,
        orderId: orderId ?? this.orderId,
        success: success ?? this.success,
        status: status ?? this.status,
        paymentId: paymentId ?? this.paymentId,
        errorCode: errorCode ?? this.errorCode,
        paymentUrl: paymentUrl ?? this.paymentUrl,
        message: message ?? this.message,
        details: details ?? this.details,
        token: token ?? this.token);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentResponse &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          orderId == other.orderId &&
          success == other.success &&
          status == other.status &&
          paymentId == other.paymentId &&
          errorCode == other.errorCode &&
          paymentUrl == other.paymentUrl &&
          message == other.message &&
          details == other.details;

  @override
  int get hashCode =>
      amount.hashCode ^
      orderId.hashCode ^
      success.hashCode ^
      status.hashCode ^
      paymentId.hashCode ^
      errorCode.hashCode ^
      paymentUrl.hashCode ^
      message.hashCode ^
      details.hashCode;

  @override
  String toString() {
    return 'PaymentResponse{terminalKey: , amount: $amount, '
        'orderId: $orderId, success: $success, status: $status, '
        'paymentId: $paymentId, errorCode: $errorCode, paymentUrl: $paymentUrl, '
        'message: $message, details: $details}';
  }
}

class Item {
  String name;
  int quantity;
  int amount;
  int price;
  String paymentMethod;
  String paymentObject;
  String tax;
  String? ean13;
  AgentData? agentData;
  SupplierInfo? supplierInfo;

  Item({
    required this.name,
    required this.quantity,
    required this.amount,
    required this.price,
    required this.paymentMethod,
    required this.paymentObject,
    required this.tax,
    this.ean13,
    this.agentData,
    required this.supplierInfo,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        name: json['Name'],
        quantity: json['Quantity'],
        amount: json['Amount'],
        price: json['Price'],
        paymentMethod: json['PaymentMethod'] ?? 'full_payment',
        paymentObject: json['PaymentObject'] ?? 'commodity',
        tax: json['Tax'],
        ean13: json['Ean13'],
        agentData: json.containsKey('AgentData')
            ? AgentData.fromJson(json['AgentData'])
            : null,
        supplierInfo: SupplierInfo.fromJson(json['SupplierInfo']),
      );

  Map<String, dynamic> toJson() => {
        'Name': name,
        'Quantity': quantity,
        'Amount': amount,
        'Price': price,
        'PaymentMethod': paymentMethod,
        'PaymentObject': paymentObject,
        'Tax': tax,
        'Ean13': ean13,
        'AgentData': agentData?.toJson(),
        'SupplierInfo': supplierInfo?.toJson(),
      };
}

class Payments {
  final int? cash;
  final int electronic;
  final int? advancePayment;
  final int? credit;
  final int? provision;

  Payments({
    this.cash,
    required this.electronic,
    this.advancePayment,
    this.credit,
    this.provision,
  });

  factory Payments.fromJson(Map<String, dynamic> json) => Payments(
        cash: json['Cash'],
        electronic: json['Electronic'],
        advancePayment: json['AdvancePayment'],
        credit: json['Credit'],
        provision: json['Provision'],
      );

  Map<String, dynamic> toJson() => {
        'Cash': cash,
        'Electronic': electronic,
        'AdvancePayment': advancePayment,
        'Credit': credit,
        'Provision': provision,
      };

  Payments copyWith({
    int? cash,
    int? electronic,
    int? advancePayment,
    int? credit,
    int? provision,
  }) {
    return Payments(
      cash: cash ?? this.cash,
      electronic: electronic ?? this.electronic,
      advancePayment: advancePayment ?? this.advancePayment,
      credit: credit ?? this.credit,
      provision: provision ?? this.provision,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Payments &&
          runtimeType == other.runtimeType &&
          cash == other.cash &&
          electronic == other.electronic &&
          advancePayment == other.advancePayment &&
          credit == other.credit &&
          provision == other.provision;

  @override
  int get hashCode =>
      cash.hashCode ^
      electronic.hashCode ^
      advancePayment.hashCode ^
      credit.hashCode ^
      provision.hashCode;
}

class AgentData {
  final String? agentSign;
  final String? operationName;
  final List<String>? phones;
  final List<String>? receiverPhones;
  final List<String>? transferPhones;
  final String? operatorName;
  final String? operatorAddress;
  final String? operatorInn;

  AgentData({
    this.agentSign,
    this.operationName,
    this.phones,
    this.receiverPhones,
    this.transferPhones,
    this.operatorName,
    this.operatorAddress,
    this.operatorInn,
  });

  Map<String, dynamic> toJson() {
    return {
      'agentSign': agentSign,
      'operationName': operationName,
      'phones': phones,
      'receiverPhones': receiverPhones,
      'transferPhones': transferPhones,
      'operatorName': operatorName,
      'operatorAddress': operatorAddress,
      'operatorInn': operatorInn,
    };
  }

  factory AgentData.fromJson(Map<String, dynamic> json) {
    return AgentData(
      agentSign: json['agentSign'],
      operationName: json['operationName'],
      phones: List<String>.from(json['phones'] ?? []),
      receiverPhones: List<String>.from(json['receiverPhones'] ?? []),
      transferPhones: List<String>.from(json['transferPhones'] ?? []),
      operatorName: json['operatorName'],
      operatorAddress: json['operatorAddress'],
      operatorInn: json['operatorInn'],
    );
  }

  AgentData copyWith({
    String? agentSign,
    String? operationName,
    List<String>? phones,
    List<String>? receiverPhones,
    List<String>? transferPhones,
    String? operatorName,
    String? operatorAddress,
    String? operatorInn,
  }) {
    return AgentData(
      agentSign: agentSign ?? this.agentSign,
      operationName: operationName ?? this.operationName,
      phones: phones ?? this.phones,
      receiverPhones: receiverPhones ?? this.receiverPhones,
      transferPhones: transferPhones ?? this.transferPhones,
      operatorName: operatorName ?? this.operatorName,
      operatorAddress: operatorAddress ?? this.operatorAddress,
      operatorInn: operatorInn ?? this.operatorInn,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentData &&
          runtimeType == other.runtimeType &&
          agentSign == other.agentSign &&
          operationName == other.operationName &&
          phones == other.phones &&
          receiverPhones == other.receiverPhones &&
          transferPhones == other.transferPhones &&
          operatorName == other.operatorName &&
          operatorAddress == other.operatorAddress &&
          operatorInn == other.operatorInn;

  @override
  int get hashCode =>
      agentSign.hashCode ^
      operationName.hashCode ^
      phones.hashCode ^
      receiverPhones.hashCode ^
      transferPhones.hashCode ^
      operatorName.hashCode ^
      operatorAddress.hashCode ^
      operatorInn.hashCode;
}

class SupplierInfo {
  List<String>? phones;
  String? name;
  String? inn;

  SupplierInfo({
    this.phones,
    this.name,
    this.inn,
  });

  factory SupplierInfo.fromJson(Map<String, dynamic> json) => SupplierInfo(
        phones: List<String>.from(json["Phones"].map((x) => x)),
        name: json["Name"],
        inn: json["Inn"],
      );

  Map<String, dynamic> toJson() => {
        "Phones": List<dynamic>.from(phones!.map((x) => x)),
        "Name": name,
        "Inn": inn,
      };
}

class Items {
  String name;
  double quantity;
  int amount;
  int price;
  String paymentMethod;
  String paymentObject;
  String tax;
  String? ean13;
  Map<String, dynamic>? agentData;
  Map<String, dynamic>? supplierInfo;

  Items({
    required this.name,
    required this.quantity,
    required this.amount,
    required this.price,
    required this.paymentMethod,
    required this.paymentObject,
    required this.tax,
    this.ean13,
    this.agentData,
    this.supplierInfo,
  });

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
      name: json['Name'],
      quantity: json['Quantity'],
      amount: json['Amount'],
      price: json['Price'],
      paymentMethod: json['PaymentMethod'],
      paymentObject: json['PaymentObject'],
      tax: json['Tax'],
      ean13: json['Ean13'],
      agentData: json['AgentData'],
      supplierInfo: json['SupplierInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Name'] = name;
    data['Quantity'] = quantity;
    data['Amount'] = amount;
    data['Price'] = price;
    data['PaymentMethod'] = paymentMethod;
    data['PaymentObject'] = paymentObject;
    data['Tax'] = tax;
    if (ean13 != null) data['Ean13'] = ean13;
    if (agentData != null) data['AgentData'] = agentData;
    if (supplierInfo != null) data['SupplierInfo'] = supplierInfo;
    return data;
  }
}

String subTokenForGetState(String termKey, String paymentId) {
  final params = {
    'TerminalKey': terminal,
    'PaymentId': paymentId,
  };

  params['Password'] = pass;

  final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));

  final concatenatedValues = sortedParams.values.join();
  final hash = sha256.convert(concatenatedValues.codeUnits);

  return hash.toString();
}

String subTokenForCheckOrder(String termKey, String orderId) {
  final params = {
    'TerminalKey': terminal,
    'OrderId': orderId,
  };

  params['Password'] = pass;

  final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));

  final concatenatedValues = sortedParams.values.join();
  final hash = sha256.convert(concatenatedValues.codeUnits);

  return hash.toString();
}
