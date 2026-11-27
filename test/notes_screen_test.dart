import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:geofield/screens/notes/notes_screen.dart';

void main() {
  testWidgets('tela de anotações mostra o conteúdo simulado do print 4',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NotesScreen()));

    expect(find.text('Registrar anotações'), findsOneWidget);
    expect(find.text('Levantamento • Terreno — Piedade'), findsOneWidget);
    expect(find.text('Anotações do campo'), findsOneWidget);
    expect(
      find.text('Registre observações vinculadas ao levantamento.'),
      findsOneWidget,
    );
    expect(
      find.text('Descreva uma ocorrência, medida ou observação importante '
          'do local...'),
      findsOneWidget,
    );
    expect(find.text('Adicionar foto'), findsOneWidget);
    expect(find.text('14:32'), findsOneWidget);
    expect(find.text('14:18'), findsOneWidget);
    expect(find.text('P04 — acesso lateral'), findsOneWidget);
    expect(
      find.text('Terreno com acesso estreito. Verificar medida antes de '
          'finalizar o levantamento.'),
      findsOneWidget,
    );
    expect(find.text('P03 — marco encontrado'), findsOneWidget);
    expect(
      find.text('Marco físico identificado próximo ao limite do terreno.'),
      findsOneWidget,
    );
    expect(find.text('2 anotações salvas'), findsOneWidget);
  });

  testWidgets('botão Nova anotação apenas avisa que é um recurso futuro',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NotesScreen()));

    await tester.ensureVisible(find.byType(FilledButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('Em breve'), findsOneWidget);
  });
}
