import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid/screens/kegiatan/kegiatan_masjid_page.dart';
import 'package:masjid/services/auth_session.dart';
import 'package:masjid/services/kegiatan_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

// PNG 1x1 piksel untuk data uji.
final Uint8List _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthSession.logout();
  });

  group('KegiatanStore', () {
    test('berisi dua poster bawaan saat pertama kali dipakai', () async {
      final store = KegiatanStore();
      await store.load();

      expect(store.items.map((e) => e.id), ['seed-isra', 'seed-lomba']);
    });

    test('add menaruh poster baru di urutan teratas dan menyimpannya', () async {
      final store = KegiatanStore();
      final saved = await store.add('  Kajian Subuh  ', _png);

      expect(saved, isTrue);
      expect(store.items.length, 3);
      expect(store.items.first.judul, 'Kajian Subuh');
      expect(store.items.first.imageBytes, _png);

      // Dimuat ulang dari penyimpanan oleh instance lain.
      final reloaded = KegiatanStore();
      await reloaded.load();
      expect(reloaded.items.length, 3);
      expect(reloaded.items.first.judul, 'Kajian Subuh');
      expect(reloaded.items.first.imageBytes, _png);
    });

    test('remove menghapus poster dan tidak muncul lagi setelah dimuat ulang',
        () async {
      final store = KegiatanStore();
      await store.load();
      await store.remove('seed-isra');

      expect(store.items.map((e) => e.id), ['seed-lomba']);

      final reloaded = KegiatanStore();
      await reloaded.load();
      expect(reloaded.items.map((e) => e.id), ['seed-lomba']);
    });

    test('remove mengubah daftar seketika (tanpa menunggu)', () async {
      final store = KegiatanStore();
      await store.load();

      // Dismissible mensyaratkan item sudah hilang saat onDismissed selesai.
      final future = store.remove('seed-lomba');
      expect(store.items.map((e) => e.id), ['seed-isra']);
      await future;
    });

    test('data tersimpan yang rusak diganti poster bawaan', () async {
      SharedPreferences.setMockInitialValues({'kegiatan_v1': 'bukan json'});
      final store = KegiatanStore();
      await store.load();

      expect(store.items.map((e) => e.id), ['seed-isra', 'seed-lomba']);
    });

    test('unggahan dibatasi sampai maxUploads', () async {
      final store = KegiatanStore();
      for (var i = 0; i < KegiatanStore.maxUploads; i++) {
        expect(store.canUploadMore, isTrue);
        await store.add('Poster $i', _png);
      }

      expect(store.uploadCount, KegiatanStore.maxUploads);
      expect(store.canUploadMore, isFalse);
    });
  });

  group('KegiatanUploadDialog', () {
    testWidgets('tombol Unggah aktif hanya jika judul terisi', (tester) async {
      String? hasil;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    hasil = await showDialog<String>(
                      context: context,
                      builder: (_) => KegiatanUploadDialog(imageBytes: _png),
                    );
                  },
                  child: const Text('buka'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('buka'));
      await tester.pumpAndSettle();

      final unggah = find.widgetWithText(FilledButton, 'Unggah');
      expect(tester.widget<FilledButton>(unggah).onPressed, isNull);

      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();
      expect(tester.widget<FilledButton>(unggah).onPressed, isNull);

      await tester.enterText(find.byType(TextField), '  Kajian Akhwat  ');
      await tester.pump();
      expect(tester.widget<FilledButton>(unggah).onPressed, isNotNull);

      await tester.tap(unggah);
      await tester.pumpAndSettle();
      expect(hasil, 'Kajian Akhwat');
    });
  });

  group('KegiatanMasjidPage', () {
    testWidgets('jamaah melihat daftar tanpa Unggah dan tanpa hapus',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: KegiatanMasjidPage(store: KegiatanStore())),
      );
      await tester.pumpAndSettle();

      expect(find.text("Isra Mi'raj Masjid As-Syifa"), findsOneWidget);
      expect(find.text('Unggah'), findsNothing);
      expect(find.byType(Dismissible), findsNothing);
    });

    testWidgets('admin melihat tombol Unggah', (tester) async {
      AuthSession.login('admin', 'admin123');
      await tester.pumpWidget(
        MaterialApp(home: KegiatanMasjidPage(store: KegiatanStore())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unggah'), findsOneWidget);
      expect(find.byType(Dismissible), findsWidgets);
    });

    testWidgets('admin menghapus poster dengan geser ke kanan lalu konfirmasi',
        (tester) async {
      AuthSession.login('admin', 'admin123');
      final store = KegiatanStore();
      await tester.pumpWidget(MaterialApp(home: KegiatanMasjidPage(store: store)));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(Dismissible).first, const Offset(600, 0));
      await tester.pumpAndSettle();
      expect(find.text('Hapus kegiatan?'), findsOneWidget);

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(store.items.map((e) => e.id), ['seed-lomba']);
      expect(find.text("Isra Mi'raj Masjid As-Syifa"), findsNothing);
    });

    testWidgets('membatalkan penghapusan menyisakan poster', (tester) async {
      AuthSession.login('admin', 'admin123');
      final store = KegiatanStore();
      await tester.pumpWidget(MaterialApp(home: KegiatanMasjidPage(store: store)));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(Dismissible).first, const Offset(600, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(store.items.length, 2);
      expect(find.text("Isra Mi'raj Masjid As-Syifa"), findsOneWidget);
    });
  });
}
