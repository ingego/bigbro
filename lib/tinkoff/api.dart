import 'package:bigbro/tinkoff/models.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

const bool isprod = false;
const terminal = isprod ? "1681914072211" : "1684176959223DEMO";
const pass = isprod ? "kd5bvf0c5vwd7kf8" : "h5eojzwmg7xveexw";

class TinkoffApi {
  final Dio dio = Dio();

  Future<PaymentResponse> initPayment(int rubs, String orderID,
      {String? description,
      Map<String, dynamic>? data,
      String? redirectUrl}) async {
    final url = "https://securepay.tinkoff.ru/v2/Init";
    var payment = PaymentRequest(
        amount: rubs * 100,
        orderId: orderID,
        description: description,
        successUrl: redirectUrl,
        data: data);
    var token = payment.subToken();
    Logger().d(token);

    var res = await dio.post<Map<String, dynamic>>(url, data: payment.toJson());
    return PaymentResponse.fromJson(res.data ?? {}).copyWith(token: token);
  }

  Future<int> checkPayment(String paymentId) async {
    var res = await dio.post<Map<String, dynamic>>(
        "https://securepay.tinkoff.ru/v2/GetState",
        data: {
          "TerminalKey": terminal,
          "PaymentId": paymentId,
          "Token": subTokenForGetState(terminal, paymentId),
        });
    Logger().d(res.data);
    int i = 0;
    i = res.data?["Status"] == "CONFIRMED"
        ? 1
        : (res.data?["Status"] == "REJECTED" ? -1 : 0);

    return i;
  }
}
