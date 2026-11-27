import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:geofield/screens/camera/camera_screen.dart';

void main() {
  testWidgets('tela de fotos mostra o conteúdo simulado do print 5',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CameraScreen()));

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Fotografar'), findsOneWidget);
    expect(find.text('Aponte para o local desejado'), findsOneWidget);
    expect(find.text('Visualização da câmera'), findsOneWidget);
    expect(find.text('Capturar'), findsOneWidget);
    expect(find.text('Fotos deste levantamento'), findsOneWidget);
    expect(find.text('3 fotos • última adicionada agora'), findsOneWidget);
    expect(find.text('Ver todas as fotos'), findsOneWidget);
  });

  testWidgets('Capturar apenas avisa que é um recurso futuro', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CameraScreen()));

    await tester.ensureVisible(find.text('Capturar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Capturar'));
    await tester.pump();

    expect(find.text('Em breve'), findsOneWidget);
  });

  testWidgets('Ver todas as fotos apenas avisa que é um recurso futuro',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CameraScreen()));

    await tester.ensureVisible(find.text('Ver todas as fotos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver todas as fotos'));
    await tester.pump();

    expect(find.text('Em breve'), findsOneWidget);
  });
}
