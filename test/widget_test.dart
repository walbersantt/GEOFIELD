import 'package:flutter_test/flutter_test.dart';

import 'package:geofield/app.dart';

void main() {
  testWidgets('GeoField abre na tela de login quando não há sessão',
      (tester) async {
    await tester.pumpWidget(const GeoFieldApp());
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(find.text('Entrar com Google'), findsOneWidget);
    expect(find.text('Início'), findsNothing);
  });
}
