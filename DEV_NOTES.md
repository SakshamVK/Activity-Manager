# DEV Notes

## Folder Structure
- `lib/models`: Hive-backed entities and derived statistic models.
- `lib/database`: app-level Hive bootstrap and box access.
- `lib/repositories`: data access over Hive boxes and statistics aggregation.
- `lib/providers`: Riverpod state, dependency wiring, and computed app state.
- `lib/services`: service layer; currently lightweight and mostly a placeholder.
- `lib/screens`: UI tabs and feature screens.
- `lib/widgets`: shared UI building blocks.
- `lib/constants`: default data, categories, and quotes.
- `lib/theme`: shared styling helpers.

## Provider Hierarchy
- `categoriesProvider` exposes the static category list.
- `activityRepositoryProvider` and `dailyRecordRepositoryProvider` expose the Hive-backed repositories.
- `statisticsRepositoryProvider` depends on the two repositories above plus `categoriesProvider`.
- `activityProvider` owns the mutable list of activities and writes through `ActivityRepository`.
- `dailyRecordProvider` owns today’s `DailyRecord` and writes through `DailyRecordRepository`.
- `overallProgressProvider` derives completion progress from `activityProvider` + `dailyRecordProvider`.
- `weeklyStatisticsProvider` and `monthlyStatisticsProvider` derive read-only statistics from the repositories.

## Repository Responsibilities
- `ActivityRepository`: CRUD for activities in Hive.
- `DailyRecordRepository`: loads, creates, saves, and queries daily records by date.
- `StatisticsRepository`: computes week/month summaries from activity and daily-record data.

## Statistics Flow
- UI watches `weeklyStatisticsProvider` or `monthlyStatisticsProvider`.
- Those providers force recomputation when activity or daily record state changes.
- `StatisticsRepository` reads all activities, daily records, and categories.
- Weekly stats cover Monday to Sunday; monthly stats cover the current month and its week summaries.

## Hot Reload vs Hot Restart
- Use Hot Reload for UI-only tweaks, widget layout changes, text/style edits, and most Riverpod logic changes that do not alter initialization.
- Use Hot Restart after Hive adapter changes, box initialization changes, provider registration changes, or any code that affects app startup/state reconstruction.
- If state looks stale after a reload, restart before debugging the logic further.

## Hive Boxes And Models
- Box: `activities` -> model: `Activity`.
- Box: `daily_records` -> model: `DailyRecord`.
- `HiveService` registers `ActivityAdapter` and `DailyRecordAdapter` during startup.
- Default activities are seeded into `activities` on first launch.