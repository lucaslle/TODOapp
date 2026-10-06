import 'package:cadence/layers/functional/habit_tracker/domain/entities/daily_quest.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/day_key.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/habit_board.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/habit_stats.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/level.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/month_calendar.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/routine.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/routine_slot.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/streak_summary.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/task.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/task_list.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/user_preferences.dart';
import 'package:cadence/layers/functional/habit_tracker/presentation/cubit/habit_state.dart';
import 'package:cadence/layers/functional/habit_tracker/presentation/views/onboarding_view.dart';
import 'package:cadence/layers/functional/habit_tracker/presentation/views/profile_view.dart';
import 'package:cadence/layers/functional/habit_tracker/presentation/views/stats_view.dart';
import 'package:cadence/layers/functional/habit_tracker/presentation/views/streak_view.dart';
import 'package:cadence/layers/functional/habit_tracker/presentation/views/today_view.dart';
import 'package:cadence/layers/functional/habit_tracker/presentation/widgets/cadence_nav_bar.dart';
import 'package:cadence/layers/functional/habit_tracker/presentation/widgets/cheer_overlay.dart';
import 'package:cadence/layers/functional/habit_tracker/presentation/widgets/level_up_overlay.dart';
import 'package:cadence/layers/functional/habit_tracker/presentation/widgets/task_composer_sheet.dart';
import 'package:cadence/layers/functional/habit_tracker/presentation/widgets/task_detail_sheet.dart';
import 'package:cadence/layers/technical/theme/cadence_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A phone-sized surface, so an overflow in any screen fails the test instead
/// of only showing up on a device.
const Size _phoneSize = Size(412, 892);

Task task({
  required int id,
  required String title,
  bool isDone = false,
  String? routineId = 'r1',
  TaskList list = TaskList.routine,
}) => Task(
  id: id,
  day: DayKey.today(),
  title: title,
  list: list,
  xpReward: list.xpReward,
  whenLabel: 'Matin',
  repeatLabel: 'Tous les jours',
  note: 'Dix minutes, téléphone retourné.',
  sortIndex: id,
  routineId: routineId,
  isDone: isDone,
  completedAt: isDone ? DateTime(2026, 9, 15, 7, 30) : null,
);

HabitBoard board({
  List<Task> openTasks = const <Task>[],
  List<Task> completedTasks = const <Task>[],
  List<Routine> routines = const <Routine>[],
  String displayName = 'Léa',
  int totalXp = 1245,
}) => HabitBoard(
  day: DayKey.today(),
  preferences: const UserPreferences.initial().copyWith(
    displayName: displayName,
    totalXp: totalXp,
    hasCompletedOnboarding: true,
  ),
  level: LevelLadder.at(totalXp),
  streak: const StreakSummary(
    currentDays: 24,
    recordDays: 31,
    freezesLeft: 2,
    isTodayCounted: true,
  ),
  quest: const DailyQuest(completedSteps: 2, isRewarded: false),
  openTasks: openTasks,
  completedTasks: completedTasks,
  routines: routines,
  chainDaysByTitle: const <String, int>{'Étirements du matin': 12},
);

Routine routine() => Routine(
  id: 'r1',
  name: 'Réveil lent',
  weekdays: const <int>{0, 1, 2, 3, 4},
  slot: RoutineSlot.morning,
  steps: const <String>['Étirements du matin', 'Faire le lit'],
  isEnabled: true,
  createdAt: DateTime(2026),
);

MonthCalendar calendar() => MonthCalendar(
  year: 2026,
  month: 9,
  leadingBlanks: 1,
  cells: List<DayCell>.generate(
    30,
    (int index) => DayCell(
      dayNumber: index + 1,
      status: index < 14
          ? DayCellStatus.full
          : index == 14
          ? DayCellStatus.partial
          : DayCellStatus.upcoming,
      isToday: index == 14,
    ),
  ),
);

HabitStats stats() => const HabitStats(
  weekCompletedCount: 31,
  consistencyPercent: 82,
  consistencyDeltaPoints: 6,
  weekXp: 435,
  weekXpGoal: 600,
  dailyXp: <DailyXp>[
    DailyXp(weekdayIndex: 0, xp: 62),
    DailyXp(weekdayIndex: 1, xp: 88),
    DailyXp(weekdayIndex: 2, xp: 45),
    DailyXp(weekdayIndex: 3, xp: 30),
    DailyXp(weekdayIndex: 4, xp: 74),
    DailyXp(weekdayIndex: 5, xp: 96),
    DailyXp(weekdayIndex: 6, xp: 40),
  ],
  insights: <TrendInsight>[
    TimeOfDayInsight(percent: 64, isMorning: true),
    WeakWeekdayInsight(
      weekdayIndex: 3,
      suggestedWeekdayIndex: 2,
      completionPercent: 41,
    ),
    LongestHabitInsight(title: 'Étirements du matin', days: 12),
  ],
);

Future<void> pumpScreen(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(theme: CadenceTheme.build(), home: Scaffold(body: child)),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Today', () {
    testWidgets('renders the quest card, the counters and the task list', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        TodayView(
          board: board(
            openTasks: <Task>[
              task(id: 1, title: 'Remplir les bouteilles'),
              task(id: 2, title: 'Lire 20 minutes'),
            ],
            completedTasks: <Task>[
              task(id: 3, title: 'Étirements du matin', isDone: true),
            ],
          ),
          isAnimated: true,
          onCompleteTask: (_) {},
          onOpenTask: (_) {},
          onUndoTask: (_) {},
          onOpenStreak: () {},
        ),
      );

      expect(find.text('Bonjour Léa'), findsOneWidget);
      expect(find.text(DailyQuest.title), findsOneWidget);
      expect(find.text('Remplir les bouteilles'), findsOneWidget);
      expect(find.text('Étirements du matin'), findsOneWidget);
      expect(find.text('2 · 3'), findsOneWidget);
    });

    testWidgets('an empty day explains what to do instead of showing nothing', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        TodayView(
          board: board(),
          isAnimated: false,
          onCompleteTask: (_) {},
          onOpenTask: (_) {},
          onUndoTask: (_) {},
          onOpenStreak: () {},
        ),
      );

      expect(find.text('Rien pour aujourd’hui.'), findsOneWidget);
      expect(find.text('Tout est fait'), findsOneWidget);
    });

    testWidgets('a long task title does not overflow the row', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        TodayView(
          board: board(
            openTasks: <Task>[
              task(
                id: 1,
                title: 'Rappeler le garage pour le rendez-vous de la révision '
                    'des 60 000 kilomètres avant vendredi',
              ),
            ],
          ),
          isAnimated: false,
          onCompleteTask: (_) {},
          onOpenTask: (_) {},
          onUndoTask: (_) {},
          onOpenStreak: () {},
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('Streak renders the run, the calendar and the freezes', (
    WidgetTester tester,
  ) async {
    await pumpScreen(
      tester,
      StreakView(
        streak: const StreakSummary(
          currentDays: 24,
          recordDays: 31,
          freezesLeft: 2,
          isTodayCounted: true,
        ),
        calendar: calendar(),
        isAnimated: true,
      ),
    );

    expect(find.text('Série'), findsOneWidget);
    expect(find.textContaining('Record 31'), findsOneWidget);
    expect(find.text('2 GELS DISPONIBLES'), findsOneWidget);
  });

  testWidgets('Stats renders the chart and turns findings into sentences', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester, StatsView(stats: stats(), isAnimated: true));

    expect(find.text('82%'), findsOneWidget);
    expect(find.text('435 / 600'), findsOneWidget);
    expect(
      find.text('Les matins te portent — 64% des tâches closes avant 11h.'),
      findsOneWidget,
    );
    expect(find.textContaining('Le jeudi bloque'), findsOneWidget);
    expect(
      find.text('Étirements du matin : ta plus longue habitude, 12 jours.'),
      findsOneWidget,
    );
  });

  testWidgets('Stats without history offers no invented trend', (
    WidgetTester tester,
  ) async {
    await pumpScreen(
      tester,
      const StatsView(stats: HabitStats.empty(), isAnimated: false),
    );

    expect(find.text('Pas encore de tendance.'), findsOneWidget);
  });

  testWidgets('Profile renders identity, routines and settings', (
    WidgetTester tester,
  ) async {
    await pumpScreen(
      tester,
      ProfileView(
        board: board(routines: <Routine>[routine()]),
        isAnimated: true,
        onEditName: () {},
        onEditAvatar: () {},
        onCreateRoutine: () {},
        onToggleRoutine: (_, _) {},
        onDeleteRoutine: (_) {},
        onToggleReminder: (_) {},
        onToggleEffects: (_) {},
        onReplayOnboarding: () {},
      ),
    );

    expect(find.text('Léa'), findsOneWidget);
    expect(find.text('Réveil lent'), findsOneWidget);
    expect(find.text('EN SEMAINE · MATIN · 2 ÉTAPES'), findsOneWidget);
    expect(find.text('Rappel du soir'), findsOneWidget);
  });

  testWidgets('Onboarding walks to the name step', (WidgetTester tester) async {
    for (int step = 0; step < HabitState.onboardingStepCount; step++) {
      await pumpScreen(
        tester,
        OnboardingView(
          step: step,
          isAnimated: false,
          onNext: () {},
          onFinish: (_) {},
        ),
      );
      expect(tester.takeException(), isNull);
    }

    expect(find.text('On t’appelle comment ?'), findsOneWidget);
    expect(find.text('Commencer ma journée'), findsOneWidget);
  });

  testWidgets('the onboarding CTA stays reachable with the keyboard up', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = _phoneSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: CadenceTheme.build(),
        home: MediaQuery(
          data: const MediaQueryData(
            size: _phoneSize,
            viewInsets: EdgeInsets.only(bottom: 340),
          ),
          child: Scaffold(
            body: OnboardingView(
              step: HabitState.onboardingStepCount - 1,
              isAnimated: false,
              onNext: () {},
              onFinish: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final Offset cta = tester.getCenter(find.text('Commencer ma journée'));
    expect(
      cta.dy,
      lessThan(_phoneSize.height - 340),
      reason: 'le bouton doit rester au-dessus du clavier',
    );
  });

  testWidgets('the celebration overlay renders its figure and line', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = _phoneSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: CadenceTheme.build(),
        home: const Scaffold(
          body: CheerOverlay(
            cheer: CheerSignal(xpGained: 55, line: 'Chaîne de 12 jours'),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('+55'), findsOneWidget);
    expect(find.text('CHAÎNE DE 12 JOURS'), findsOneWidget);
  });

  testWidgets('the level up overlay inverts the screen', (
    WidgetTester tester,
  ) async {
    await pumpScreen(
      tester,
      LevelUpOverlay(
        level: LevelLadder.at(1400),
        isAnimated: false,
        onDismiss: () {},
      ),
    );

    expect(find.text('8'), findsOneWidget);
    expect(find.text('Fiable'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
  });

  testWidgets('the nav bar shows the four tabs', (WidgetTester tester) async {
    await pumpScreen(
      tester,
      CadenceNavBar(
        currentTab: AppTab.today,
        onTabSelected: (_) {},
        isAnimated: false,
      ),
    );

    expect(find.text('AUJOURD’HUI'), findsOneWidget);
    expect(find.text('SÉRIE'), findsOneWidget);
    expect(find.text('STATS'), findsOneWidget);
    expect(find.text('PROFIL'), findsOneWidget);
  });

  testWidgets('the detail sheet shows the chain and both actions', (
    WidgetTester tester,
  ) async {
    await pumpScreen(
      tester,
      TaskDetailSheet(
        task: task(id: 1, title: 'Étirements du matin'),
        chainDays: 12,
        isQuestStep: true,
      ),
    );

    expect(find.text('Étirements du matin'), findsOneWidget);
    expect(find.text('Chaîne de 12 jours'), findsOneWidget);
    expect(find.text('Valider'), findsOneWidget);
    expect(find.text('Supprimer la tâche'), findsOneWidget);
  });

  group('Composer', () {
    testWidgets('the task face announces the reward of the chosen list', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, const TaskComposerSheet());

      expect(find.text('Nouvelle tâche'), findsOneWidget);
      expect(find.text('+15 XP'), findsOneWidget);

      await tester.tap(find.text('Famille'));
      await tester.pumpAndSettle();

      expect(find.text('+25 XP'), findsOneWidget);
    });

    testWidgets('the routine face collects steps', (WidgetTester tester) async {
      await pumpScreen(tester, const TaskComposerSheet(initialTabIndex: 1));

      expect(find.text('Nouvelle routine'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Ajouter une étape'),
        'Grand verre d’eau',
      );
      await tester.pumpAndSettle();
      expect(find.text('1 étape · +15 XP'), findsOneWidget);
    });
  });
}
