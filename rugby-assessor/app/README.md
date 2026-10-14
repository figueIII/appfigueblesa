# ref_assess · app Flutter de RefAssess

La app del MVP 1.0. La visión general, la estructura y la documentación están en el [README del proyecto](../README.md).

```bash
flutter pub get
flutter analyze && flutter test
./scripts/build_apk.sh            # APK debug → build/app/outputs/flutter-apk/app-debug.apk
./scripts/build_apk.sh release --install
```

Generación de código de Drift tras cambiar `lib/data/db/schema.drift`: `dart run build_runner build`.
