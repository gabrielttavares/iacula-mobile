import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/auth/domain/entities/auth_user.dart';
import 'package:iacula_app/features/home/presentation/home_greeting.dart';

void main() {
  test('no user and no local name yields Olá!', () {
    expect(
      homeLargeTitleGreeting(user: null, localDisplayName: null),
      'Olá!',
    );
  });

  test('local name only yields Olá, name!', () {
    expect(
      homeLargeTitleGreeting(user: null, localDisplayName: 'Ana'),
      'Olá, Ana!',
    );
  });

  test('authenticated name yields Olá, name!', () {
    expect(
      homeLargeTitleGreeting(
        user: const AuthUser(
          id: '1',
          email: 'a@b.com',
          displayName: 'Pedro',
        ),
        localDisplayName: null,
      ),
      'Olá, Pedro!',
    );
  });

  test('gender does not change copy; feminine name still Olá', () {
    expect(
      homeLargeTitleGreeting(
        user: const AuthUser(
          id: '1',
          email: 'a@b.com',
          displayName: 'Maria',
          gender: Gender.female,
        ),
        localDisplayName: null,
      ),
      'Olá, Maria!',
    );
  });

  test('empty auth displayName falls back to local', () {
    expect(
      homeLargeTitleGreeting(
        user: const AuthUser(
          id: '1',
          email: 'a@b.com',
          displayName: '',
        ),
        localDisplayName: 'Ana',
      ),
      'Olá, Ana!',
    );
  });

  test('whitespace-only auth displayName falls back to local', () {
    expect(
      homeLargeTitleGreeting(
        user: const AuthUser(
          id: '1',
          email: 'a@b.com',
          displayName: '   ',
        ),
        localDisplayName: 'Ana',
      ),
      'Olá, Ana!',
    );
  });

  test('null auth displayName uses local', () {
    expect(
      homeLargeTitleGreeting(
        user: const AuthUser(id: '1', email: 'a@b.com'),
        localDisplayName: 'Local',
      ),
      'Olá, Local!',
    );
  });

  test('trims local display name', () {
    expect(
      homeLargeTitleGreeting(
        user: null,
        localDisplayName: '  Ana  ',
      ),
      'Olá, Ana!',
    );
  });

  test('trims auth display name', () {
    expect(
      homeLargeTitleGreeting(
        user: const AuthUser(
          id: '1',
          email: 'a@b.com',
          displayName: '  João  ',
        ),
        localDisplayName: null,
      ),
      'Olá, João!',
    );
  });
}
