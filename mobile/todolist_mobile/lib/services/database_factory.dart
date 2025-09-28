import 'dart:io';
import 'package:flutter/foundation.dart';

// 条件导入，避免在移动平台上导入不存在的包
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    if (dart.library.io) 'package:sqflite_common_ffi/sqflite_ffi.dart'
    if (dart.library.html) 'database_factory_stub.dart';

/// 初始化数据库工厂，支持桌面平台
void initializeDatabaseFactory() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    try {
      sqfliteFfiInit();
      // 使用sqflite_common_ffi包中的databaseFactory设置方法
      databaseFactory = databaseFactoryFfi;
    } catch (e) {
      debugPrint('Failed to initialize FFI database factory: $e');
      // 在桌面平台上，如果FFI初始化失败，保持默认工厂
    }
  }
}
