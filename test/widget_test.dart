import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:sirkelbus/app/modules/auth/views/auth_view.dart';

void main() {
  testWidgets('Auth splash view shows the app name', (WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: AuthView()));

    expect(find.text('SirkelBus'), findsOneWidget);
  });
}
