# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# App Package & Models / Beans / DAOs
-keep class com.ankk.cnmci.** { *; }

# Firebase & Google Play Services
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }
-keepattributes *Annotation*,Signature,EnclosingMethod,InnerClasses

# Google Play Core (Deferred Components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
