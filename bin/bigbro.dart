import 'package:bigbro/bot.dart';

void main(List<String> arguments) async {
  await Bot.init();
  var bot = Bot.getInstance();
  bot.initCommands();
}
