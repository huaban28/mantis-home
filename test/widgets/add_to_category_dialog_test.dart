import 'package:flauncher/database.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/widgets/add_to_category_dialog.dart';
import 'package:flauncher/widgets/application_info_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import '../mocks.dart';
import '../mocks.mocks.dart';

void main() {
  testWidgets(
      'hidden apps can be moved to an existing category with the remote',
      (tester) async {
    final service = MockAppsService();
    final app = fakeApp(packageName: 'tool.app', hidden: true);
    final tools = fakeCategory(name: 'Tools');
    when(service.categoriesWithApps).thenReturn([CategoryWithApps(tools, [])]);
    await tester.pumpWidget(ChangeNotifierProvider<AppsService>.value(
        value: service,
        child: MaterialApp(home: AddToCategoryDialog(app, move: true))));
    await tester.pumpAndSettle();
    expect(find.text('Move to...'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    verify(service.moveToCategory(app, tools)).called(1);
    verifyNever(service.hideApplication(any));
  });
  testWidgets('app menu adds a Non-TV app to TV category using the remote',
      (tester) async {
    final service = MockAppsService();
    final app = fakeApp(
        packageName: 'example.app',
        name: 'Example',
        icon: kTransparentImage,
        sideloaded: true);
    final tv = fakeCategory(name: 'TV Applications');
    final nonTv = fakeCategory(name: 'Non-TV Applications');
    when(service.categoriesWithApps).thenReturn([
      CategoryWithApps(tv, []),
      CategoryWithApps(nonTv, [app])
    ]);
    await tester.pumpWidget(ChangeNotifierProvider<AppsService>.value(
        value: service,
        child: MaterialApp(
            home: ApplicationInfoPanel(category: nonTv, application: app))));
    await tester.ensureVisible(find.text('Add to category'));
    await tester.tap(find.text('Add to category'));
    await tester.pumpAndSettle();
    expect(find.byType(AddToCategoryDialog), findsOneWidget);
    expect(find.text('TV Applications'), findsOneWidget);
    expect(find.text('Non-TV Applications'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    verify(service.addToCategory(app, tv)).called(1);
    expect(find.byType(AddToCategoryDialog), findsNothing);
  });

  testWidgets(
      'adding an app already in all categories explains instead of showing an empty picker',
      (tester) async {
    final service = MockAppsService();
    final app = fakeApp();
    when(service.categoriesWithApps).thenReturn([
      CategoryWithApps(fakeCategory(), [app])
    ]);
    await tester.pumpWidget(ChangeNotifierProvider<AppsService>.value(
        value: service, child: MaterialApp(home: AddToCategoryDialog(app))));
    await tester.pumpAndSettle();
    expect(find.text('This app is already in every category.'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
  });
}
