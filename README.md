# MaxKiller

## Требования

- Dart/Flutter SDK установлен и доступен в PATH
- CMake 3.20+
- Компилятор C/C++ (Xcode CLT, clang, MSVC, gcc)

## Разработка

- Подтянуть сабмодули, зависимости Dart, сгенерировать типы и собрать нативные библиотеки

```bash
make setup 
```

- Запустить тесты

```bash
make test
```

- Авторегенерация типов

```bash
make watch
```

## Сборка нативных библиотек

- Артефакты попадают в `build/native/<platform>-<arch>/`.
    - macOS: `macos-arm64`, `macos-x86_64`, опционально `macos-universal`
    - Linux: `linux-x86_64`, `linux-aarch64`, ...
    - Windows: `windows-x64`, `windows-arm64`

### Тип сборки

По умолчанию используется `Release`.

```bash
make native BUILD_TYPE=Debug
```

### Универсальная сборка macOS

Выключена по умолчанию. Включение:

```bash
make native-universal
```

## Запуск тестов

```bash
make test
```

Команда автоматически соберёт нативные библиотеки перед запуском тестов.