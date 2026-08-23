# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep application classes (adjust package if changed)
-keep class com.example.busnap.** { *; }
-keep class com.busnap.app.** { *; }

# Keep Google Play Services and suppress warnings
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep Kotlin metadata
-keepclassmembers class kotlin.Metadata { *; }

# Keep enums used by reflection
-keepclassmembers enum * { **[] $VALUES; ** valueOf(java.lang.String); }

# Keep Parcelable CREATORs
-keepclassmembers class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator CREATOR;
}

# Keep classes/members annotated with @Keep
-keep @androidx.annotation.Keep class * { *; }
-keepclasseswithmembers class * { @androidx.annotation.Keep *; }

# General rules to avoid stripping reflective use
-keepattributes *Annotation*, InnerClasses, EnclosingMethod, Signature
-dontwarn javax.annotation.**
-dontnote javax.annotation.**
