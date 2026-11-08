# Flutter Web frontend

Open this folder in Android Studio. See ../README.md for API, private fixture setup and web run commands. Public API URL is supplied with --dart-define=API_URL=http://127.0.0.1:8000/api. No service credentials belong in this client. Run flutter analyze, flutter test, and flutter build web --no-wasm-dry-run. Widget tests include signed-in narrow/tablet/desktop states; actual browser evidence remains a separate requirement.
