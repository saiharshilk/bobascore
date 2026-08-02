import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

enum ShopStatus { wantToTry, ranked }

class Shop {
  Shop({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    List<String> tags = const [],
    DateTime? dateAdded,
    this.status = ShopStatus.wantToTry,
    String? id,
  }) : id = id ?? const Uuid().v4(),
       tags = List.unmodifiable(tags),
       dateAdded = dateAdded ?? DateTime.now();

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> tags;
  final DateTime dateAdded;
  final ShopStatus status;
}

class ShopAdapter extends TypeAdapter<Shop> {
  @override
  final int typeId = 0;

  @override
  Shop read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };

    return Shop(
      id: fields[0] as String,
      name: fields[1] as String,
      address: fields[2] as String,
      latitude: (fields[3] as num).toDouble(),
      longitude: (fields[4] as num).toDouble(),
      tags: (fields[5] as List).cast<String>(),
      dateAdded: fields[6] as DateTime,
      status: ShopStatus.values[fields[7] as int],
    );
  }

  @override
  void write(BinaryWriter writer, Shop obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.dateAdded)
      ..writeByte(7)
      ..write(obj.status.index);
  }
}
