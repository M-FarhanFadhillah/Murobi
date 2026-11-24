import 'dart:typed_data';

// Titik kode Unicode yang punya glyph di berkas font TrueType/OpenType, dibaca
// dari tabel cmap (format 4 dan 12). Dipakai tes untuk memastikan font yang
// disertakan di aplikasi benar-benar memuat huruf yang akan ditampilkan.
Set<int> ttfCodePoints(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);

  int? cmapOffset;
  final tableCount = data.getUint16(4);
  for (var i = 0; i < tableCount; i++) {
    final record = 12 + 16 * i;
    final tag = String.fromCharCodes(bytes.sublist(record, record + 4));
    if (tag == 'cmap') cmapOffset = data.getUint32(record + 8);
  }
  if (cmapOffset == null) {
    throw const FormatException('Berkas font tidak punya tabel cmap');
  }

  // Pilih subtabel Unicode; format 12 (seluruh Unicode) didahulukan.
  int? subtable;
  var subtableFormat = 0;
  final subtableCount = data.getUint16(cmapOffset + 2);
  for (var i = 0; i < subtableCount; i++) {
    final record = cmapOffset + 4 + 8 * i;
    final platform = data.getUint16(record);
    final encoding = data.getUint16(record + 2);
    final offset = cmapOffset + data.getUint32(record + 4);
    final format = data.getUint16(offset);
    final isUnicode =
        platform == 0 || (platform == 3 && (encoding == 1 || encoding == 10));
    if (isUnicode && (format == 4 || format == 12) && format > subtableFormat) {
      subtable = offset;
      subtableFormat = format;
    }
  }
  if (subtable == null) {
    throw const FormatException('Berkas font tidak punya cmap Unicode');
  }

  final codePoints = <int>{};
  if (subtableFormat == 12) {
    final groupCount = data.getUint32(subtable + 12);
    for (var i = 0; i < groupCount; i++) {
      final group = subtable + 16 + 12 * i;
      final start = data.getUint32(group);
      final end = data.getUint32(group + 4);
      for (var code = start; code <= end; code++) {
        codePoints.add(code);
      }
    }
    return codePoints;
  }

  final segmentCount = data.getUint16(subtable + 6) ~/ 2;
  final endCodes = subtable + 14;
  final startCodes = endCodes + 2 * segmentCount + 2;
  final idDeltas = startCodes + 2 * segmentCount;
  final idRangeOffsets = idDeltas + 2 * segmentCount;
  for (var i = 0; i < segmentCount; i++) {
    final end = data.getUint16(endCodes + 2 * i);
    final start = data.getUint16(startCodes + 2 * i);
    final delta = data.getInt16(idDeltas + 2 * i);
    final rangeOffset = data.getUint16(idRangeOffsets + 2 * i);
    for (var code = start; code <= end && code != 0xFFFF; code++) {
      var glyph = 0;
      if (rangeOffset == 0) {
        glyph = (code + delta) & 0xFFFF;
      } else {
        final address =
            idRangeOffsets + 2 * i + rangeOffset + 2 * (code - start);
        glyph = data.getUint16(address);
        if (glyph != 0) glyph = (glyph + delta) & 0xFFFF;
      }
      if (glyph != 0) codePoints.add(code);
    }
  }
  return codePoints;
}
