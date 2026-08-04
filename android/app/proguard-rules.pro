# R8 rules for release builds.
#
# Flutter's engine and most plugins ship their own consumer rules. What is listed
# here is the code that R8 cannot see is reachable: billing classes resolved
# reflectively, and plugin entry points invoked from Dart over platform channels.

# RevenueCat and Google Play Billing. Both are reached reflectively through the
# billing client, so stripping them breaks purchases only in release builds —
# exactly the configuration that is hardest to notice before shipping.
-keep class com.revenuecat.purchases.** { *; }
-keep class com.android.billingclient.** { *; }
-dontwarn com.revenuecat.purchases.**

# audio_waveforms: recorder/player entry points called from platform channels.
-keep class com.simform.audio_waveforms.** { *; }

# Kotlin metadata, used by several plugins for reflection.
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.**
