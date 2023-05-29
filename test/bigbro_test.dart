import 'dart:math';

import 'package:bigbro/database.dart';
import 'package:bigbro/tinkoff/api.dart';
import 'package:logger/logger.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

void main() {
  group("test db", () {
    setUp(() async {
      // await DB.init();
    });

    test("создать платеж и проверка токена(ТИНЬКОФФ)", () async {
      //  var api = await ApiManager().createPurchase(500);
      var res = await TinkoffApi().initPayment(
        100,
        Uuid().v4(),
        description: "Покупка бота",
        data: {"покупка": "бота"},
      );
      Logger().d(res);
    });

    test("проверить платеж(ТИНЬКОФФ)", () async {
      String paymentId = '2785461691';
      var state = await TinkoffApi().checkPayment(
        paymentId,
      );
      Logger().d(state);
    });
    test("Add users", () async {
      var db = DB.getInstatce();
      var user = User(
          id: Uuid().v4(),
          vk: "vk.com/test",
          phone: (Random.secure().nextInt(1000) + 1000).toString(),
          email: "1ingegos1@gmail.com",
          otherTypes: ["sdfsdf", "asdfsdfsdf", "sdfsdfsdf"]);
      await db.addUser(user);
    });
    test("return all users", () {
      var l = DB.getInstatce().getAllUsers();
      Logger().d(l);
    });
    test("find user by phone", () {
      var l = DB.getInstatce().findByPhone("1312");
      Logger().d(l?.toJson());
    });
    test("find user by vk", () {
      var l = DB.getInstatce().findVk("vk.com/test");
      Logger().d(l?.toJson());
    });
  });
}
