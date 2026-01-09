import '../local/db/app_db.dart';

Future<void> seedUser(AppDb db) async {
  final existing = await db.select(db.users).get();
  if (existing.isNotEmpty) return;

  await db
      .into(db.users)
      .insert(
        UsersCompanion.insert(
          email: 'test@gmail.com',
          password: '123456',
          fullName: 'Test User',
        ),
      );
}
