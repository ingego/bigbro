import 'dart:io';

import 'package:bigbro/database.dart' as db;
import 'package:bigbro/tinkoff/api.dart';
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import 'package:tinkoff_acquiring/tinkoff_acquiring.dart';
import 'package:uuid/uuid.dart';

const _token = "6010323902:AAF4HFNNBUZ6ZjEiUvQiuPLB5gj4XLLLu68";

final tinkoff = TinkoffAcquiring(TinkoffAcquiringConfigCredential(
    terminalKey: "1684176959223DEMO",
    password: "h5eojzwmg7xveexw",
    isDebugMode: true));
Map users = {};

class Bot {
  static late TeleDart _tel;
  static Future init() async {
    var gram = Telegram(_token);
    var me = await gram.getMe();
    await db.DB.init();
    _tel = TeleDart(_token, Event(me.username!));
    _tel.start();
  }

  Bot._();
  static Bot getInstance() => Bot._();

  initCommands() {
    _tel.onCommand("kill_me_8899").listen(
      (event) async {
        await event.reply("ok");
        exit(0);
      },
    );
    _start();
    _callToSearch();
    _view();
    _callToSearchVK();
    _handleEvent();
  }

  String? paymentId;
  void _handleEvent() {
    _tel.onCallbackQuery().listen((event) async {
      if (event.data == "cost") {
        var api = await TinkoffApi().initPayment(100, Uuid().v4(), data: {
          event.teledartMessage!.chat.username!: DateTime.now().toString()
        });
        paymentId = api.paymentId;
        _tel.sendMessage(event.teledartMessage!.chat.id, "Платеж",
            replyMarkup: InlineKeyboardMarkup(inlineKeyboard: [
              [
                InlineKeyboardButton(
                  text: "Оплатить",
                  url: api.paymentUrl!,
                )
              ],
              [
                InlineKeyboardButton(
                    text: "Проверить платеж", callbackData: "check_payment")
              ]
            ]));
      }
      if (event.data == "check_payment") {
        if (paymentId == null) {
          _tel.sendMessage(
            event.teledartMessage!.chat.id,
            "Платеж не найден",
          );
          return;
        }
        var api = await TinkoffApi().checkPayment(paymentId!);
        if (api == 0) {
          _tel.sendMessage(
            event.teledartMessage!.chat.id,
            "Платеж в обработке",
          );
        }
        if (api == 1) {
          _tel.sendMessage(
            event.teledartMessage!.chat.id,
            "Платеж проведен!",
          );
        }
        event.answer(text: "", showAlert: false);
      }
    });
  }

  _handleCommand(String key, void Function(TeleDartMessage event) handleEvent) {
    return _tel.onCommand(key).listen((event) => handleEvent(event));
  }

  _start() {
    return _handleCommand("start", (event) {
      var user = event.from?.username ?? "init";

      if (!users.containsKey(user)) {
        users.addAll({
          user: {"ammount": 500, "value": "rub"}
        });
      }

      event.reply(
          "привет! это текстовый бот для работы с данными и поиском информации /search_vk");
    });
  }

  _callToSearch() {
    return _handleCommand("search", (event) {
      event
          .reply("отправьте номер, стоимость одного запроса - 30 ₽ /search_vk");
    });
  }

  _callToSearchVK() {
    return _handleCommand("search_vk", (event) async {
      var res = event.text!.split("search_vk").last.replaceAll(" ", "");

      var userName = event.from!.username!;
      if (!users.containsKey(userName)) {
        users.addAll({
          userName: {"ammount": 500, "value": "rub"}
        });
      }
      var current = users[userName];
      bool payed = false;
      if ((current["ammount"] - 100) > 0) {
        payed = true;
        var res = current["ammount"] - 100;
        users[userName]["ammount"] = res;
      }

      var box = db.DB.getInstatce();

      var user = box.findVk(res);

      String other = user?.otherTypes?.join() ?? " ";

      String generateString = '''
email: ${user?.email}
pass: ${user?.password}
vk: ${user?.vk}
other: $other
''';
      if (payed == false) {
        var email = (user?.email ?? "").toString();
        var pass = (user?.password ?? "").toString();
        var vk = (user?.vk ?? "").toString();
        var others = other.toString();
        email = email.replaceRange(
            email.length ~/ 3, email.length, "****************");
        pass = pass.replaceRange(
            pass.length ~/ 3, pass.length, "*****************");
        vk = vk.replaceRange(vk.length ~/ 3, vk.length, "*****************");
        others = others.replaceRange(
            others.length ~/ 3, others.length, "*****************");
        generateString = '''
email: $email
pass: $pass
vk: $vk
other: $others
''';
      }

      event.reply(generateString,
          replyMarkup: InlineKeyboardMarkup(inlineKeyboard: [
            [
              InlineKeyboardButton(
                  text: payed == false
                      ? "Оплатите счет"
                      : "${users[userName]["ammount"]}˙₽",
                  callbackData: "cost")
            ]
          ]));
    });
  }

  _view() {
    _tel.onMessage().listen((event) {
      if (event.text?.startsWith("+79") ?? false) {
        _searchUser(phone: event.text!);
      } else if (event.text?.contains("vk.com") ?? false) {
        _searchUser(vk: event.text!);
      } else {
        event.reply(
            "Неудалось обработать запрос, воспользуйтесь шаблоном +79111111111 или vk.com/username");
      }
    });
  }

  _searchUser({String? phone, String? vk}) {
    if (phone != null) {}

    if (vk != null) {}
  }

  _addUser(String s) {}
}
