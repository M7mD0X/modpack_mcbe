# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class com.google.firebase.** { *; }

# Keep model classes (JSON serialization)
-keep class com.mcbe.modpackmanager.** { *; }
-keepclassmembers class com.mcbe.modpackmanager.** { *; }

# Provider
-keep class * extends androidx.lifecycle.ViewModel { *; }
-keep class * extends ChangeNotifier { *; }

# Kotlin coroutines
-dontwarn kotlinx.coroutines.**

# HTTP
-dontwarn okhttp3.**
-dontwarn okio.**

# Google Fonts
-keep class com.google.android.gms.fonts.** { *; }

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
