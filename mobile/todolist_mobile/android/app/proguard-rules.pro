# Keep Flutter and Dart classes
-keep class io.flutter.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn io.flutter.embedding.**

# Keep plugin classes
-keep class * extends io.flutter.embedding.engine.plugins.FlutterPlugin { *; }
-keep class * extends io.flutter.plugin.common.MethodCallHandler { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom application classes
-keep class com.todolist.mobile.** { *; }

# Keep Gson classes (if using Gson for JSON)
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.** { *; }

# Keep Retrofit (if using Retrofit)
-keepattributes Signature, InnerClasses, EnclosingMethod
-keepattributes RuntimeVisibleAnnotations, RuntimeVisibleParameterAnnotations
-keepclassmembers,allowshrinking,allowobfuscation interface * {
    @retrofit2.http.* <methods>;
}

# Keep data model classes
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}
