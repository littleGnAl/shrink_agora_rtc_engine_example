import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:shrink_agora_rtc_engine/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Shrink all *Extension.frameworks not crash',
      (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Trigger a frame.
    await tester.pumpAndSettle(const Duration(seconds: 10));

    expect(find.byType(AgoraVideoView), findsWidgets);

    await tester.pumpAndSettle(const Duration(seconds: 60));
  });
}
