import 'package:hive_ce/hive.dart';

part 'activity.g.dart';

@HiveType(typeId: 0)
class Activity {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final int categoryId;

  @HiveField(3)
  final int order;

  const Activity({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.order,
  });

  Activity copyWith({int? id, String? title, int? categoryId, int? order}) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      order: order ?? this.order,
    );
  }
}
