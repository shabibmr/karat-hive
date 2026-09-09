import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

Widget _host(Widget child) => MaterialApp(
      theme: khTheme(),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('SH-ID-05 renders labelled multiline field', (tester) async {
    await tester.pumpWidget(
      _host(
        const ReviewCommentField(
          label: 'Comment',
          helperText: 'Optional, up to 1000 characters',
        ),
      ),
    );

    expect(find.byKey(const Key('review-comment-field')), findsOneWidget);
    expect(find.byKey(const Key('review-comment-field-input')), findsOneWidget);
    expect(find.text('Comment'), findsOneWidget);
    expect(find.text('Optional, up to 1000 characters'), findsOneWidget);
    expect(find.text('0/${ReviewCommentField.maxLength}'), findsOneWidget);

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.maxLength, ReviewCommentField.maxLength);
    expect(field.maxLengthEnforcement, MaxLengthEnforcement.enforced);
    expect(field.minLines, 3);
    expect(field.maxLines, 6);
  });

  testWidgets('SH-ID-05 onChanged fires while typing', (tester) async {
    String? value;
    await tester.pumpWidget(
      _host(
        ReviewCommentField(
          label: 'Comment',
          onChanged: (v) => value = v,
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('review-comment-field-input')),
      'Great service',
    );
    await tester.pump();
    expect(value, 'Great service');
    expect(find.text('13/${ReviewCommentField.maxLength}'), findsOneWidget);
  });

  testWidgets('SH-ID-05 enforces 1000-char ceiling', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _host(
        ReviewCommentField(
          label: 'Comment',
          controller: controller,
        ),
      ),
    );

    final over = 'a' * (ReviewCommentField.maxLength + 50);
    await tester.enterText(
      find.byKey(const Key('review-comment-field-input')),
      over,
    );
    await tester.pump();

    expect(controller.text.length, ReviewCommentField.maxLength);
    expect(
      find.text('${ReviewCommentField.maxLength}/${ReviewCommentField.maxLength}'),
      findsOneWidget,
    );
  });

  testWidgets('SH-ID-05 disabled ignores edits', (tester) async {
    final controller = TextEditingController(text: 'Kept');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _host(
        ReviewCommentField(
          label: 'Comment',
          controller: controller,
          enabled: false,
          onChanged: (_) => fail('onChanged must not fire when disabled'),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('review-comment-field-input')),
      'Changed',
    );
    await tester.pump();
    expect(controller.text, 'Kept');
  });

  testWidgets('SH-ID-05 shows error and hides helper', (tester) async {
    await tester.pumpWidget(
      _host(
        const ReviewCommentField(
          label: 'Comment',
          helperText: 'Optional',
          errorText: 'Comment is too long',
        ),
      ),
    );

    expect(find.text('Comment is too long'), findsOneWidget);
    expect(find.text('Optional'), findsNothing);
  });
}
