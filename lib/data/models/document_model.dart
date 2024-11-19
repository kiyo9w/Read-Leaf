import 'package:hive/hive.dart';
part 'document_model.g.dart';

@HiveType(typeId: 0)
class DocumentModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String path;

  @HiveField(3)
  final String type;

  DocumentModel({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
  });
}
