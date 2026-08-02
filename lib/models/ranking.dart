import 'package:hive/hive.dart';

class Ranking {
  const Ranking({
    required this.shopId,
    required this.rankPosition,
    required this.score,
  });

  final String shopId;
  final int rankPosition;
  final double score;
}

class RankingAdapter extends TypeAdapter<Ranking> {
  @override
  final int typeId = 2;

  @override
  Ranking read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };

    return Ranking(
      shopId: fields[0] as String,
      rankPosition: fields[1] as int,
      score: (fields[2] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, Ranking obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.shopId)
      ..writeByte(1)
      ..write(obj.rankPosition)
      ..writeByte(2)
      ..write(obj.score);
  }
}
