// Stub implementation for non-web platforms
class Storage {
  String? operator [](String key) => null;
  void operator []=(String key, String value) {}
  void remove(String key) {}
}

class Window {
  Storage get localStorage => Storage();
}

final window = Window();
