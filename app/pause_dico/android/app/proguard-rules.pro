# R8 rules for the release build.

# WorkManager (pulled in by google_mobile_ads) creates its Room database by
# reflection (WorkDatabase_Impl, no-arg constructor). Room's own rule keeps the
# class but, in R8 full mode, not its constructor: the app crashed on launch
# with "Failed to create an instance of androidx.work.impl.WorkDatabase".
-keep class * extends androidx.room.RoomDatabase {
    <init>();
}
