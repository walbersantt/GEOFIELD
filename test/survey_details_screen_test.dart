import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:geofield/screens/surveys/survey_details_screen.dart';

void main() {
  testWidgets('tela de detalhes mostra o mock do print 7', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SurveyDetailsScreen()));

    expect(find.text('Detalhes do levantamento'), findsOneWidget);
    expect(find.text('Levantamento finalizado'), findsOneWidget);
    expect(find.text('Sítio Boa Vista'), findsOneWidget);
    expect(find.text('Vitória de Santo Antão • PE'), findsOneWidget);
    expect(find.text('24 set'), findsOneWidget);
    expect(find.text('Área calculada'), findsOneWidget);
    expect(find.text('1.240 m²'), findsOneWidget);
    expect(find.text('Perímetro calculado'), findsOneWidget);
    expect(find.text('148 m'), findsOneWidget);
    expect(find.text('6 pontos coletados'), findsOneWidget);

    for (final String code in ['P01', 'P02', 'P03', 'P04', 'P05', 'P06']) {
      expect(find.text(code), findsOneWidget);
    }
    expect(find.text('Lat -8.118420 • Lon -35.295180'), findsOneWidget);
    expect(find.text('Lat -8.118610 • Lon -35.294860'), findsOneWidget);
    expect(find.text('Lat -8.118940 • Lon -35.294920'), findsOneWidget);
    expect(find.text('Lat -8.119120 • Lon -35.295240'), findsOneWidget);
    expect(find.text('Lat -8.118910 • Lon -35.295570'), findsOneWidget);
    expect(find.text('Lat -8.118590 • Lon -35.295480'), findsOneWidget);
  });

  Future<void> expectSoon(WidgetTester tester, String label) async {
    await tester.pumpWidget(const MaterialApp(home: SurveyDetailsScreen()));
    await tester.ensureVisible(find.text(label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pump();
    expect(find.text('Em breve'), findsOneWidget);
  }

  testWidgets('Ver pontos no mapa apenas avisa que é um recurso futuro',
      (tester) async {
    await expectSoon(tester, 'Ver pontos no mapa');
  });

  testWidgets('Ver imagens registradas apenas avisa que é um recurso futuro',
      (tester) async {
    await expectSoon(tester, 'Ver imagens registradas');
  });

  testWidgets('Consultar anotações apenas avisa que é um recurso futuro',
      (tester) async {
    await expectSoon(tester, 'Consultar anotações');
  });

  testWidgets('Exportar CSV apenas avisa que é um recurso futuro',
      (tester) async {
    await expectSoon(tester, 'Exportar CSV');
  });
}
