import 'dart:math' as math;

/// Port dari STROKES HTML ref — data titik panduan penulisan angka 0–9.
/// Setiap stroke adalah daftar titik [x, y] dalam koordinat 0–100.
///
/// Dipakai oleh GuidedTracingCanvas untuk merender:
/// - Garis putus-putus panduan
/// - Titik mulai (hijau) + nomor urutan
/// - Animasi "pensil demo"
abstract final class NumberStrokes {
  NumberStrokes._();

  /// Menghasilkan titik-titik sepanjang busur elips.
  static List<List<double>> _arc(
    double cx, double cy, double rx, double ry,
    double a0, double a1, {int n = 16}
  ) {
    final pts = <List<double>>[];
    for (int i = 0; i <= n; i++) {
      final a = (a0 + (a1 - a0) * i / n) * math.pi / 180;
      pts.add([cx + rx * math.cos(a), cy + ry * math.sin(a)]);
    }
    return pts;
  }

  static List<List<double>> _ln(
    double x0, double y0, double x1, double y1,
  ) => [[x0, y0], [x1, y1]];

  static List<List<double>> _ct(List<List<List<double>>> parts) =>
      parts.expand((p) => p).toList();

  /// Map angka (sebagai String '0'–'9') → list of strokes.
  /// Setiap stroke adalah `List<Offset>` dalam koordinat 0–100.
  static Map<String, List<List<List<double>>>> get all => _strokes;

  static final Map<String, List<List<List<double>>>> _strokes = {
    '0': [_arc(50, 50, 26, 38, -90, -450, n: 26)],
    '1': [_ct([_ln(36, 26, 50, 12), _ln(50, 12, 50, 88)])],
    '2': [_ct([_arc(50, 32, 24, 20, 180, 360, n: 14), [[26, 82], [74, 82]]])],
    '3': [_ct([
      _arc(48, 30, 24, 20, 180, 360, n: 12),
      [[70, 42]],
      _arc(48, 62, 26, 24, -40, 160, n: 14),
    ])],
    '4': [
      [[62, 12], [24, 62], [78, 62]],
      [[62, 12], [62, 88]],
    ],
    '5': [_ct([
      [[72, 14], [38, 14], [36, 44]],
      _arc(50, 64, 26, 24, -140, 160, n: 16),
    ])],
    '6': [_ct([
      [[68, 14], [56, 28], [44, 42], [34, 54], [28, 66]],
      _arc(50, 68, 24, 22, 180, 540, n: 18),
    ])],
    '7': [[[26, 14], [74, 14], [42, 88]]],
    '8': [
      _arc(50, 30, 22, 18, -90, -450, n: 18),
      _arc(50, 68, 26, 20, -90, -450, n: 20),
    ],
    '9': [
      [
        [68, 26],
        [60, 15],
        [48, 13],
        [36, 17],
        [28, 26],
        [26, 36],
        [32, 47],
        [44, 53],
        [58, 53],
        [68, 45],
        [70, 32],
        [68, 26],
        [70, 48],
        [69, 64],
        [66, 76],
        [58, 85],
        [48, 88],
        [38, 86],
      ],
    ],
    '10': [
      _ct([_ln(22, 28, 34, 14), _ln(34, 14, 34, 86)]),
      _arc(68, 50, 18, 36, -90, -450, n: 24),
    ],
  };

  /// Strokes huruf kapital A–Z (untuk TracingCanvas yang sudah ada pun bisa pakai ini).
  static final Map<String, List<List<List<double>>>> letters = {
    'A': [_ln(50,12,20,88), _ln(50,12,80,88), _ln(32,62,68,62)],
    'B': [_ln(30,12,30,88), _ct([_arc(30,31,26,19,-90,90,n:12)]), _ct([_arc(30,69,28,19,-90,90,n:12)])],
    'C': [_arc(50,50,28,38,-50,-310,n:22)],
    'D': [_ln(32,12,32,88), _ct([_arc(32,50,40,38,-90,90,n:18)])],
    'E': [_ln(30,12,30,88), _ln(30,12,72,12), _ln(30,50,62,50), _ln(30,88,72,88)],
    'F': [_ln(30,12,30,88), _ln(30,12,72,12), _ln(30,50,62,50)],
    'G': [_arc(50,50,28,38,-50,-310,n:22), _ln(54,58,72,58), _ln(72,58,72,80)],
    'H': [_ln(28,12,28,88), _ln(72,12,72,88), _ln(28,50,72,50)],
    'I': [_ln(50,12,50,88), _ln(32,12,68,12), _ln(32,88,68,88)],
    'J': [_ln(68,12,68,66), _ct([_arc(46,66,22,22,0,180,n:12)])],
    'K': [_ln(30,12,30,88), _ln(70,12,30,52), _ln(40,44,72,88)],
    'L': [_ln(30,12,30,88), _ln(30,88,72,88)],
    'M': [[[26,88],[26,12],[50,60],[74,12],[74,88]]],
    'N': [[[26,88],[26,12],[74,88],[74,12]]],
    'O': [_arc(50,50,28,38,-90,-450,n:26)],
    'P': [_ln(30,12,30,88), _ct([_arc(30,33,30,21,-90,90,n:14)])],
    'Q': [_arc(50,50,28,38,-90,-450,n:26), _ln(62,72,82,92)],
    'R': [_ln(30,12,30,88), _ct([_arc(30,33,30,21,-90,90,n:14)]), _ln(30,54,72,88)],
    'S': [_ct([_arc(50,30,22,18,-35,-270,n:14), _arc(50,68,22,18,-90,160,n:14)])],
    'T': [_ln(50,12,50,88), _ln(24,12,76,12)],
    'U': [_ct([_ln(28,12,28,66), _arc(50,66,22,22,180,0,n:12), _ln(72,66,72,12)])],
    'V': [[[26,12],[50,88],[74,12]]],
    'W': [[[22,12],[36,88],[50,40],[64,88],[78,12]]],
    'X': [_ln(28,12,72,88), _ln(72,12,28,88)],
    'Y': [_ct([_ln(26,12,50,50), _ln(50,50,50,88)]), _ln(74,12,50,50)],
    'Z': [[[26,12],[74,12],[26,88],[74,88]]],
  };

  /// Ambil stroke untuk karakter (angka atau huruf). Null jika tidak ada.
  static List<List<List<double>>>? forChar(String ch) {
    if (ch.isEmpty) return null;
    final upper = ch.toUpperCase();
    return all[upper] ?? letters[upper];
  }
}
