# 08 - DevOps, Build e CI/CD

## 1. Estado Atual
- CI para build/release desktop (Windows/Linux)
- landing deploy em Vercel preview

## 2. Proposta Flutter CI
Workflows sugeridos:
1. `flutter-analyze-test.yml`
- `flutter pub get`
- `flutter analyze`
- `flutter test`

2. `android-release.yml`
- build AAB/APK
- assinatura
- artifact upload

3. `ios-release.yml`
- build IPA
- assinatura e export

## 3. Publicação
- Android: Play Console internal track inicialmente.
- iOS: TestFlight inicialmente.

## 4. Versionamento
- semver alinhado com domínio funcional.
- changelog automatizado por release.

## 5. Observabilidade
- logging estruturado
- crash reporting
- métricas de entrega de notificação/alarme
