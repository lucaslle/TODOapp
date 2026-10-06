import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/theme/cadence_motion.dart';
import '../../domain/entities/habit_board.dart';
import '../../domain/entities/routine.dart';
import '../../domain/entities/routine_slot.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_list.dart';
import '../../domain/gateways/reminder_gateway.dart';
import '../../domain/use_cases/complete_task_use_case.dart';
import '../../domain/use_cases/create_routine_use_case.dart';
import '../../domain/use_cases/create_task_use_case.dart';
import '../../domain/use_cases/delete_routine_use_case.dart';
import '../../domain/use_cases/delete_task_use_case.dart';
import '../../domain/use_cases/load_board_use_case.dart';
import '../../domain/use_cases/load_month_calendar_use_case.dart';
import '../../domain/use_cases/load_stats_use_case.dart';
import '../../domain/use_cases/roll_over_day_use_case.dart';
import '../../domain/use_cases/save_preferences_use_case.dart';
import '../../domain/use_cases/seed_starter_routines_use_case.dart';
import '../../domain/use_cases/set_routine_enabled_use_case.dart';
import '../../domain/use_cases/undo_task_completion_use_case.dart';
import 'habit_state.dart';

class HabitCubit extends Cubit<HabitState> {
  HabitCubit({
    required RollOverDayUseCase rollOverDay,
    required SeedStarterRoutinesUseCase seedStarterRoutines,
    required LoadBoardUseCase loadBoard,
    required LoadStatsUseCase loadStats,
    required LoadMonthCalendarUseCase loadMonthCalendar,
    required CompleteTaskUseCase completeTask,
    required UndoTaskCompletionUseCase undoTaskCompletion,
    required CreateTaskUseCase createTask,
    required DeleteTaskUseCase deleteTask,
    required CreateRoutineUseCase createRoutine,
    required SetRoutineEnabledUseCase setRoutineEnabled,
    required DeleteRoutineUseCase deleteRoutine,
    required SavePreferencesUseCase savePreferences,
    required ReminderGateway reminderGateway,
  }) : _rollOverDay = rollOverDay,
       _seedStarterRoutines = seedStarterRoutines,
       _loadBoard = loadBoard,
       _loadStats = loadStats,
       _loadMonthCalendar = loadMonthCalendar,
       _completeTask = completeTask,
       _undoTaskCompletion = undoTaskCompletion,
       _createTask = createTask,
       _deleteTask = deleteTask,
       _createRoutine = createRoutine,
       _setRoutineEnabled = setRoutineEnabled,
       _deleteRoutine = deleteRoutine,
       _savePreferences = savePreferences,
       _reminderGateway = reminderGateway,
       super(const HabitState());

  final RollOverDayUseCase _rollOverDay;
  final SeedStarterRoutinesUseCase _seedStarterRoutines;
  final LoadBoardUseCase _loadBoard;
  final LoadStatsUseCase _loadStats;
  final LoadMonthCalendarUseCase _loadMonthCalendar;
  final CompleteTaskUseCase _completeTask;
  final UndoTaskCompletionUseCase _undoTaskCompletion;
  final CreateTaskUseCase _createTask;
  final DeleteTaskUseCase _deleteTask;
  final CreateRoutineUseCase _createRoutine;
  final SetRoutineEnabledUseCase _setRoutineEnabled;
  final DeleteRoutineUseCase _deleteRoutine;
  final SavePreferencesUseCase _savePreferences;
  final ReminderGateway _reminderGateway;

  Timer? _cheerTimer;

  Future<void> start() async {
    emit(state.copyWith(status: HabitStatus.loading));
    await _seedStarterRoutines();
    await _rollOverDay();
    await _reload();

    final HabitBoard? board = state.board;
    emit(
      state.copyWith(
        isOnboardingVisible:
            board != null && !board.preferences.hasCompletedOnboarding,
      ),
    );
  }

  /// Called when the app comes back to the foreground: a day may have turned
  /// over while it was away.
  Future<void> refresh() async {
    await _rollOverDay();
    await _reload();
  }

  void selectTab(AppTab tab) => emit(state.copyWith(tab: tab));

  Future<void> completeTask(Task task) async {
    final TaskCompletionOutcome? outcome = await _completeTask(task);
    await _reload();
    if (outcome == null) return;

    if (!state.areEffectsEnabled) {
      if (outcome.hasLeveledUp) {
        emit(state.copyWith(pendingLevelUp: outcome.level));
      }
      return;
    }

    emit(
      state.copyWith(
        cheer: CheerSignal(
          xpGained: outcome.xpGained,
          line: outcome.cheerLine,
        ),
      ),
    );

    _cheerTimer?.cancel();
    _cheerTimer = Timer(CadenceMotion.cheerHold, () {
      if (isClosed) return;
      emit(
        state.copyWith(
          clearCheer: true,
          pendingLevelUp: outcome.hasLeveledUp ? outcome.level : null,
        ),
      );
    });
  }

  Future<void> undoTask(Task task) async {
    await _undoTaskCompletion(task);
    await _reload();
  }

  Future<void> deleteTask(Task task) async {
    await _deleteTask(task);
    await _reload();
  }

  Future<void> addTask({required String title, required TaskList list}) async {
    await _createTask(title: title, list: list);
    await _reload();
  }

  Future<void> addRoutine({
    required String name,
    required Set<int> weekdays,
    required RoutineSlot slot,
    required List<String> steps,
  }) async {
    await _createRoutine(
      name: name,
      weekdays: weekdays,
      slot: slot,
      steps: steps,
    );
    await _reload();
  }

  Future<void> toggleRoutine({
    required Routine routine,
    required bool isEnabled,
  }) async {
    await _setRoutineEnabled(routine: routine, isEnabled: isEnabled);
    await _reload();
  }

  Future<void> removeRoutine(Routine routine) async {
    await _deleteRoutine(routine);
    await _reload();
  }

  Future<void> setReminderEnabled({required bool isEnabled}) async {
    if (isEnabled) await _reminderGateway.requestPermission();
    await _savePreferences(isReminderEnabled: isEnabled);
    await _reload();
  }

  Future<void> setEffectsEnabled({required bool isEnabled}) async {
    await _savePreferences(areEffectsEnabled: isEnabled);
    await _reload();
  }

  Future<void> setDisplayName(String name) async {
    await _savePreferences(displayName: name);
    await _reload();
  }

  Future<void> setAvatarPath(String? path) async {
    await _savePreferences(avatarPath: path, clearAvatarPath: path == null);
    await _reload();
  }

  void goToNextOnboardingStep() {
    if (state.isOnLastOnboardingStep) return;
    emit(state.copyWith(onboardingStep: state.onboardingStep + 1));
  }

  Future<void> finishOnboarding({String? displayName}) async {
    await _savePreferences(
      displayName: displayName,
      hasCompletedOnboarding: true,
    );
    await _reload();
    emit(
      state.copyWith(
        isOnboardingVisible: false,
        onboardingStep: 0,
        tab: AppTab.today,
      ),
    );
    await _reminderGateway.requestPermission();
  }

  void replayOnboarding() =>
      emit(state.copyWith(isOnboardingVisible: true, onboardingStep: 0));

  void dismissLevelUp() =>
      emit(state.copyWith(clearLevelUp: true, tab: AppTab.today));

  Future<void> _reload() async {
    final HabitBoard board = await _loadBoard();
    emit(
      state.copyWith(
        status: HabitStatus.ready,
        board: board,
        stats: await _loadStats(),
        calendar: await _loadMonthCalendar(
          todayTasks: <Task>[...board.openTasks, ...board.completedTasks],
        ),
      ),
    );

    await _reminderGateway.syncEveningReminder(
      isEnabled: board.preferences.isReminderEnabled,
      openTaskCount: board.openTasks.length,
    );
  }

  @override
  Future<void> close() {
    _cheerTimer?.cancel();
    return super.close();
  }
}
