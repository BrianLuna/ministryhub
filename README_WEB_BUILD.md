# Solución para Problemas de Build en Web

## Problema
Cuando ejecutas la aplicación en Chrome, los archivos de localización generados (`app_localizations.dart`) se borran y necesitas regenerarlos manualmente.

## Solución Rápida

Antes de ejecutar en Chrome, ejecuta:

```powershell
flutter gen-l10n
flutter pub get
```

O ejecuta el script de pre-build:

```powershell
.\scripts\pre_build.ps1
```

## Solución Automática

Para que los archivos se generen automáticamente antes de cada build, puedes:

1. **Configurar tu IDE** para ejecutar `flutter gen-l10n` antes de ejecutar la app
2. **Usar el script pre_build.ps1** manualmente antes de ejecutar

## Nota Importante

El problema ocurre porque Flutter limpia los archivos generados durante el build de web. Con `generate: true` en `pubspec.yaml`, los archivos deberían regenerarse automáticamente, pero a veces esto no funciona correctamente en web.

Si el problema persiste, asegúrate de:
1. Tener el Modo Desarrollador habilitado en Windows (para symlinks)
2. Ejecutar `flutter pub cache repair` si hay problemas con el caché
3. Verificar que `l10n.yaml` esté configurado correctamente

