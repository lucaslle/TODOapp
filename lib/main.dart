import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'layers/functional/habit_tracker/data/data_sources/habit_local_data_source.dart';
import 'layers/functional/habit_tracker/data/data_sources/preferences_local_data_source.dart';
import 'layers/functional/habit_tracker/data/gateways/day_log_gateway_impl.dart';
import 'layers/functional/habit_tracker/data/gateways/reminder_gateway_impl.dart';
import 'layers/functional/habit_tracker/data/gateways/routine_gateway_impl.dart';
import 'layers/functional/habit_tracker/data/gateways/task_gateway_impl.dart';
import 'layers/functional/habit_tracker/data/gateways/user_preferences_gateway_impl.dart';
import 'layers/functional/habit_tracker/domain/gateways/day_log_gateway.dart';
import 'layers/functional/habit_tracker/domain/gateways/reminder_gateway.dart';
import 'layers/functional/habit_tracker/domain/gateways/routine_gateway.dart';
import 'layers/functional/habit_tracker/domain/gateways/task_gateway.dart';
import 'layers/functional/habit_tracker/domain/gateways/user_preferences_gateway.dart';
import 'layers/functional/habit_tracker/domain/use_cases/complete_task_use_case.dart';
import 'layers/functional/habit_tracker/domain/use_cases/compute_task_chains_use_case.dart';
import 'layers/functional/habit_tracker/domain/use_cases/create_routine_use_case.dart';
import 'layers/functional/habit_tracker/domain/use_cases/create_task_use_case.dart';
import 'layers/functional/habit_tracker/domain/use_cases/delete_routine_use_case.dart';
import 'layers/functional/habit_tracker/domain/use_cases/delete_task_use_case.dart';
import 'layers/functional/habit_tracker/domain/use_cases/generate_routine_tasks_use_case.dart';
import 'layers/functional/habit_tracker/domain/use_cases/load_board_use_case.dart';
import 'layers/functional/habit_tracker/domain/use_cases/load_month_calendar_use_case.dart';
import 'layers/functional/habit_tracker/domain/use_cases/load_stats_use_case.dart';
import 'layers/functional/habit_tracker/domain/use_cases/load_streak_use_case.dart';
import 'layers/functional/habit_tracker/domain/use_cases/roll_over_day_use_case.dart';
import 'layers/functional/habit_tracker/domain/use_cases/save_preferences_use_case.dart';
import 'layers/functional/habit_tracker/domain/use_cases/seed_starter_routines_use_case.dart';
import 'layers/functional/habit_tracker/domain/use_cases/set_routine_enabled_use_case.dart';
import 'layers/functional/habit_tracker/domain/use_cases/undo_task_completion_use_case.dart';
import 'layers/functional/habit_tracker/presentation/cubit/habit_cubit.dart';
import 'layers/functional/habit_tracker/presentation/views/habit_home_view.dart';
import 'layers/technical/notifications/local_notification_service.dart';
import 'layers/technical/persistence/cadence_database.dart';
import 'layers/technical/theme/cadence_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0x00000000),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0x00000000),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(CadenceApp(preferences: await SharedPreferences.getInstance()));
}

/// Composition root: the one place that knows which implementation backs each
/// gateway.
class CadenceApp extends StatelessWidget {
  const CadenceApp({required this.preferences, super.key});

  final SharedPreferences preferences;

  HabitCubit _buildCubit() {
    final HabitLocalDataSource habitDataSource = HabitLocalDataSource(
      database: CadenceDatabase.instance,
    );
    final PreferencesLocalDataSource preferencesDataSource =
        PreferencesLocalDataSource(preferences: preferences);

    final TaskGateway taskGateway = TaskGatewayImpl(
      localDataSource: habitDataSource,
    );
    final RoutineGateway routineGateway = RoutineGatewayImpl(
      localDataSource: habitDataSource,
    );
    final DayLogGateway dayLogGateway = DayLogGatewayImpl(
      localDataSource: habitDataSource,
    );
    final UserPreferencesGateway preferencesGateway =
        UserPreferencesGatewayImpl(localDataSource: preferencesDataSource);
    final ReminderGateway reminderGateway = ReminderGatewayImpl(
      notificationService: LocalNotificationService(),
    );

    final GenerateRoutineTasksUseCase generateRoutineTasks =
        GenerateRoutineTasksUseCase(taskGateway: taskGateway);
    final ComputeTaskChainsUseCase computeTaskChains = ComputeTaskChainsUseCase(
      taskGateway: taskGateway,
    );
    final LoadStreakUseCase loadStreak = LoadStreakUseCase(
      dayLogGateway: dayLogGateway,
      taskGateway: taskGateway,
    );

    return HabitCubit(
      rollOverDay: RollOverDayUseCase(
        taskGateway: taskGateway,
        routineGateway: routineGateway,
        dayLogGateway: dayLogGateway,
        preferencesGateway: preferencesGateway,
        generateRoutineTasks: generateRoutineTasks,
      ),
      seedStarterRoutines: SeedStarterRoutinesUseCase(
        routineGateway: routineGateway,
        preferencesGateway: preferencesGateway,
      ),
      loadBoard: LoadBoardUseCase(
        taskGateway: taskGateway,
        routineGateway: routineGateway,
        preferencesGateway: preferencesGateway,
        loadStreak: loadStreak,
        computeTaskChains: computeTaskChains,
      ),
      loadStats: LoadStatsUseCase(taskGateway: taskGateway),
      loadMonthCalendar: LoadMonthCalendarUseCase(
        dayLogGateway: dayLogGateway,
        taskGateway: taskGateway,
      ),
      completeTask: CompleteTaskUseCase(
        taskGateway: taskGateway,
        preferencesGateway: preferencesGateway,
        computeTaskChains: computeTaskChains,
      ),
      undoTaskCompletion: UndoTaskCompletionUseCase(
        taskGateway: taskGateway,
        preferencesGateway: preferencesGateway,
      ),
      createTask: CreateTaskUseCase(taskGateway: taskGateway),
      deleteTask: DeleteTaskUseCase(
        taskGateway: taskGateway,
        preferencesGateway: preferencesGateway,
      ),
      createRoutine: CreateRoutineUseCase(
        routineGateway: routineGateway,
        generateRoutineTasks: generateRoutineTasks,
      ),
      setRoutineEnabled: SetRoutineEnabledUseCase(
        routineGateway: routineGateway,
        taskGateway: taskGateway,
        generateRoutineTasks: generateRoutineTasks,
      ),
      deleteRoutine: DeleteRoutineUseCase(
        routineGateway: routineGateway,
        taskGateway: taskGateway,
      ),
      savePreferences: SavePreferencesUseCase(
        preferencesGateway: preferencesGateway,
      ),
      reminderGateway: reminderGateway,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momentum',
      debugShowCheckedModeBanner: false,
      theme: CadenceTheme.build(),
      home: BlocProvider<HabitCubit>(
        create: (BuildContext context) => _buildCubit(),
        child: const HabitHomeView(),
      ),
    );
  }
}
