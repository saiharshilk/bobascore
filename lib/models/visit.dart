import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class Visit {
  Visit({
    required this.shopId,
    required this.date,
    required this.drinkOrdered,
    this.price,
    this.notes,
    this.photoPath,
    String? id,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String shopId;
  final DateTime date;
  final String drinkOrdered;
  final double? price;
  final String? notes;
  final String? photoPath;
}

class VisitAdapter extends TypeAdapter<Visit> {
  @override
  final int typeId = 1;

  @override
  Visit read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };

    return Visit(
      id: fields[0] as String,
      shopId: fields[1] as String,
      date: fields[2] as DateTime,
      drinkOrdered: fields[3] as String,
      price: (fields[4] as num?)?.toDouble(),
      notes: fields[5] as String?,
      photoPath: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Visit obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.shopId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.drinkOrdered)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.photoPath);
  }
}
