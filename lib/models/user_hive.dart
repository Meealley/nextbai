import 'package:hive/hive.dart';

part 'user_hive.g.dart';

@HiveType(typeId: 0)
class UserHive {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  UserHive({
    required this.id,
    required this.email,
  });
}
