import 'package:hive/hive.dart';

class DB {
  static late Box<Map> _box;
  static Future init() async {
    Hive.init("./db/");
    var box = await Hive.openBox<Map>("users");
    _box = box;
  }

  DB._();
  static DB getInstatce() => DB._();

  User? findVk(String vk) {
    var allData = _box.values;
    Map? finder;
    for (var element in allData) {
      if (element["vk"] == vk) {
        finder = element;
        break;
      }
    }
    return finder == null ? null : User.fromJson(finder);
  }

  User? findByPhone(String phone) {
    var allData = _box.values;
    Map? finder;
    for (var element in allData) {
      if (element["phone"] == phone) {
        finder = element;
        break;
      }
    }
    return finder == null ? null : User.fromJson(finder);
  }

  Future addUser(User user) {
    return _box.put(user.id, user.toJson());
  }

  Iterable<Map> getAllUsers() {
    return _box.values;
  }
}

class User {
  final String id;
  final String? password;
  final String? email;
  final String? vk;
  final String? phone;
  final List<String>? otherTypes;

  User({
    required this.id,
    this.password,
    this.email,
    this.vk,
    this.phone,
    this.otherTypes,
  });

  factory User.fromJson(Map<dynamic, dynamic> json) {
    // if (json == null) {
    //  // throw FormatException('Failed to decode User from JSON');
    // }
    return User(
      id: json['id'] as String,
      password: json['password'] as String?,
      email: json['email'] as String?,
      vk: json['vk'] as String?,
      phone: json['phone'] as String?,
      otherTypes: (json['otherTypes'] as List<dynamic>?)
          ?.map((dynamic e) => e as String)
          .toList(),
    );
  }

  Map<dynamic, dynamic> toJson() {
    return <dynamic, dynamic>{
      'id': id,
      'password': password,
      'email': email,
      'vk': vk,
      'phone': phone,
      'otherTypes': otherTypes,
    };
  }
}
