import 'package:drift/drift.dart';
import 'package:flauncher/database.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'mocks.mocks.dart';

void main() {
  test(
      'moving a hidden tool only changes its own memberships and restores it in Tools',
      () async {
    final database = FLauncherDatabase.inMemory();
    await database.persistApps([
      AppsCompanion.insert(
          packageName: 'tool.app',
          name: 'Tool',
          version: '1',
          hidden: const Value(true)),
      AppsCompanion.insert(
          packageName: 'video.app', name: 'Video', version: '1'),
    ]);
    final tvId = await database
        .into(database.categories)
        .insert(CategoriesCompanion.insert(name: 'TV Applications', order: 0));
    final toolsId = await database
        .into(database.categories)
        .insert(CategoriesCompanion.insert(name: 'Tools', order: 1));
    await database.insertAppsCategories([
      AppsCategoriesCompanion.insert(
          categoryId: tvId, appPackageName: 'tool.app', order: 0),
      AppsCategoriesCompanion.insert(
          categoryId: toolsId, appPackageName: 'tool.app', order: 7),
      AppsCategoriesCompanion.insert(
          categoryId: tvId, appPackageName: 'video.app', order: 1),
    ]);
    final channel = MockFLauncherChannel();
    when(channel.getApplications()).thenAnswer((_) async => [
          {
            'packageName': 'tool.app',
            'name': 'Tool',
            'version': '1',
            'sideloaded': false
          },
          {
            'packageName': 'video.app',
            'name': 'Video',
            'version': '1',
            'sideloaded': false
          },
        ]);
    final service = AppsService(channel, database);
    await untilCalled(channel.addAppsChangedListener(any));
    final tool = (await database.listApplications())
        .firstWhere((app) => app.packageName == 'tool.app');
    final tools = (await database.listCategoriesWithVisibleApps())
        .firstWhere((item) => item.category.id == toolsId)
        .category;
    await service.moveToCategory(tool, tools);
    final categories = await database.listCategoriesWithVisibleApps();
    expect(
        categories
            .firstWhere((item) => item.category.id == tvId)
            .applications
            .map((app) => app.packageName),
        ['video.app']);
    expect(
        categories
            .firstWhere((item) => item.category.id == toolsId)
            .applications
            .map((app) => app.packageName),
        ['tool.app']);
    expect(
        service.applications
            .firstWhere((app) => app.packageName == 'tool.app')
            .hidden,
        isFalse);
    // Repeating a move is safe and does not duplicate or reorder existing entries.
    await service.moveToCategory(tool, tools);
    final memberships = await database.select(database.appsCategories).get();
    expect(
        memberships
            .where((entry) => entry.appPackageName == 'tool.app')
            .single
            .order,
        7);
    service.dispose();
    await database.close();
  });
}
