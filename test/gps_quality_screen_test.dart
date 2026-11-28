import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:geofield/screens/measure/gps_quality_screen.dart';
import 'package:geofield/screens/measure/measure_screen.dart';

void main() {
  testWidgets('tela de qualidade do GPS mostra os dados simulados do print 7',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GpsQualityScreen()));

    expect(find.text('Qualidade do GPS'), findsOneWidget);
    expect(find.text('LEVANTAMENTO • TERRENO PIEDADE'), findsOneWidget);
    expect(find.text('Verifique seu ponto'), findsOneWidget);
    expect(
      find.text('Confira a precisão estimada antes de salvar a coordenada.'),
      findsOneWidget,
    );
    expect(find.text('Precisão moderada'), findsOneWidget);
    expect(find.text('± 4 m'), findsOneWidget);
    expect(find.text('Precisão estimada pelo celular'), findsOneWidget);
    expect(find.text('O que isso significa?'), findsOneWidget);
    expect(
      find.text('A localização pode variar. Para um registro mais confiável, '
          'aguarde alguns instantes em um local aberto e tente novamente.'),
      findsOneWidget,
    );
    expect(
      find.text('Coordenadas de GPS de smartphone não são topograficamente '
          'precisas; a precisão depende do dispositivo, do ambiente e do sinal '
          'GNSS.'),
      findsOneWidget,
    );
    expect(find.text('Tentar melhorar a localização'), findsOneWidget);
    expect(
      find.text('O GPS pode levar alguns segundos para estabilizar.'),
      findsOneWidget,
    );
    expect(find.text('COORDENADAS CAPTURADAS'), findsOneWidget);
    expect(find.text('Latitude'), findsOneWidget);
    expect(find.text('-8.1874°'), findsOneWidget);
    expect(find.text('Longitude'), findsOneWidget);
    expect(find.text('-34.9221°'), findsOneWidget);
    expect(find.text('Exemplo ilustrativo • valores simulados'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
    expect(find.text('Salvar ponto mesmo assim'), findsOneWidget);
  });

  Future<void> expectSoon(WidgetTester tester, String label) async {
    await tester.pumpWidget(const MaterialApp(home: GpsQualityScreen()));
    await tester.ensureVisible(find.text(label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pump();
    expect(find.text('Em breve'), findsOneWidget);
  }

  testWidgets('Tentar novamente apenas avisa que é um recurso futuro',
      (tester) async {
    await expectSoon(tester, 'Tentar novamente');
  });

  testWidgets('Salvar ponto mesmo assim apenas avisa que é um recurso futuro',
      (tester) async {
    await expectSoon(tester, 'Salvar ponto mesmo assim');
  });

  testWidgets('Finalizar em Medir terreno abre a checagem de GPS',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MeasureScreen()));
    final Finder finalizar = find.text('Finalizar').last;
    await tester.ensureVisible(finalizar);
    await tester.pumpAndSettle();
    await tester.tap(finalizar);
    await tester.pumpAndSettle();

    expect(find.text('Qualidade do GPS'), findsOneWidget);
  });
}
