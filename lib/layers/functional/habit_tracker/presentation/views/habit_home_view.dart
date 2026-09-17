import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/theme/cadence_colors.dart';
import '../../domain/entities/habit_board.dart';
import '../../domain/entities/routine.dart';
import '../../domain/entities/task.dart';
import '../cubit/habit_cubit.dart';
import '../cubit/habit_state.dart';
import '../widgets/cadence_nav_bar.dart';
import '../widgets/cadence_sheet.dart';
import '../widgets/cheer_overlay.dart';
import '../widgets/confirm_sheet.dart';
import '../widgets/level_up_overlay.dart';
import '../widgets/task_composer_sheet.dart';
import '../widgets/task_detail_sheet.dart';
import 'onboarding_view.dart';
import 'profile_view.dart';
import 'stats_view.dart';
import 'streak_view.dart';
import 'today_view.dart';

/// The shell: one tab at a time, the floating nav, and the two overlays that
/// take the screen when something is worth celebrating.
class HabitHomeView extends StatefulWidget {
  const HabitHomeView({super.key});

  @override
  State<HabitHomeView> createState() => _HabitHomeViewState();
}

class _HabitHomeViewState extends State<HabitHomeView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<HabitCubit>().start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A day may have turned over while the app was in the background.
    if (state == AppLifecycleState.resumed) {
      context.read<HabitCubit>().refresh();
    }
  }

  Future<void> _openComposer({required int tabIndex}) async {
    final HabitCubit cubit = context.read<HabitCubit>();
    final ComposerResult? result = await CadenceSheet.show<ComposerResult>(
      context: context,
      builder: (BuildContext context) =>
          TaskComposerSheet(initialTabIndex: tabIndex),
    );

    switch (result) {
      case NewTaskResult(:final String title, :final list):
        await cubit.addTask(title: title, list: list);
      case NewRoutineResult(
        :final String name,
        :final Set<int> weekdays,
        :final slot,
        :final List<String> steps,
      ):
        await cubit.addRoutine(
          name: name,
          weekdays: weekdays,
          slot: slot,
          steps: steps,
        );
      case null:
        return;
    }
  }

  Future<void> _openTaskDetail(Task task, HabitBoard board) async {
    final HabitCubit cubit = context.read<HabitCubit>();
    final TaskDetailAction? action = await CadenceSheet.show<TaskDetailAction>(
      context: context,
      builder: (BuildContext context) => TaskDetailSheet(
        task: task,
        chainDays: board.chainDaysFor(task),
        isQuestStep: task.isRoutineStep,
      ),
    );

    switch (action) {
      case TaskDetailAction.complete:
        await cubit.completeTask(task);
      case TaskDetailAction.delete:
        await cubit.deleteTask(task);
      case null:
        return;
    }
  }

  Future<void> _confirmRoutineDeletion(Routine routine) async {
    final HabitCubit cubit = context.read<HabitCubit>();
    final bool? isConfirmed = await CadenceSheet.show<bool>(
      context: context,
      builder: (BuildContext context) => ConfirmSheet(
        title: 'Supprimer « ${routine.name} » ?',
        body: 'Les étapes encore ouvertes aujourd’hui disparaissent. '
            'L’historique déjà fait reste intact.',
        confirmLabel: 'Supprimer',
      ),
    );
    if (isConfirmed ?? false) await cubit.removeRoutine(routine);
  }

  Future<void> _editDisplayName(HabitBoard board) async {
    final HabitCubit cubit = context.read<HabitCubit>();
    final String? name = await CadenceSheet.show<String>(
      context: context,
      builder: (BuildContext context) => TextPromptSheet(
        title: 'Ton prénom',
        hintText: 'Comment on t’appelle ?',
        confirmLabel: 'Enregistrer',
        initialValue: board.preferences.displayName,
      ),
    );
    if (name != null) await cubit.setDisplayName(name);
  }

  Widget _buildTab(HabitState state, HabitBoard board) => switch (state.tab) {
    AppTab.today => TodayView(
      board: board,
      isAnimated: state.areEffectsEnabled,
      onCompleteTask: (Task task) =>
          context.read<HabitCubit>().completeTask(task),
      onOpenTask: (Task task) => _openTaskDetail(task, board),
      onUndoTask: (Task task) => context.read<HabitCubit>().undoTask(task),
      onOpenStreak: () => context.read<HabitCubit>().selectTab(AppTab.streak),
    ),
    AppTab.streak => StreakView(
      streak: board.streak,
      calendar: state.calendar,
      isAnimated: state.areEffectsEnabled,
    ),
    AppTab.stats => StatsView(
      stats: state.stats,
      isAnimated: state.areEffectsEnabled,
    ),
    AppTab.profile => ProfileView(
      board: board,
      isAnimated: state.areEffectsEnabled,
      onEditName: () => _editDisplayName(board),
      onCreateRoutine: () => _openComposer(tabIndex: 1),
      onToggleRoutine: (Routine routine, bool isEnabled) => context
          .read<HabitCubit>()
          .toggleRoutine(routine: routine, isEnabled: isEnabled),
      onDeleteRoutine: _confirmRoutineDeletion,
      onToggleReminder: (bool isEnabled) =>
          context.read<HabitCubit>().setReminderEnabled(isEnabled: isEnabled),
      onToggleEffects: (bool isEnabled) =>
          context.read<HabitCubit>().setEffectsEnabled(isEnabled: isEnabled),
      onReplayOnboarding: () => context.read<HabitCubit>().replayOnboarding(),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CadenceColors.background,
      resizeToAvoidBottomInset: false,
      body: BlocBuilder<HabitCubit, HabitState>(
        builder: (BuildContext context, HabitState state) {
          final HabitBoard? board = state.board;
          if (!state.isReady || board == null) {
            return const ColoredBox(color: CadenceColors.background);
          }

          if (state.isOnboardingVisible) {
            return OnboardingView(
              step: state.onboardingStep,
              isAnimated: state.areEffectsEnabled,
              onNext: () => context.read<HabitCubit>().goToNextOnboardingStep(),
              onFinish: (String name) =>
                  context.read<HabitCubit>().finishOnboarding(displayName: name),
            );
          }

          return Stack(
            children: <Widget>[
              Positioned.fill(
                child: SafeArea(bottom: false, child: _buildTab(state, board)),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 16,
                child: SafeArea(
                  top: false,
                  child: CadenceNavBar(
                    currentTab: state.tab,
                    isAnimated: state.areEffectsEnabled,
                    onTabSelected: (AppTab tab) =>
                        context.read<HabitCubit>().selectTab(tab),
                    onAddPressed: () => _openComposer(tabIndex: 0),
                  ),
                ),
              ),
              if (state.cheer != null)
                Positioned.fill(child: CheerOverlay(cheer: state.cheer!)),
              if (state.pendingLevelUp != null)
                Positioned.fill(
                  child: LevelUpOverlay(
                    level: state.pendingLevelUp!,
                    isAnimated: state.areEffectsEnabled,
                    onDismiss: () => context.read<HabitCubit>().dismissLevelUp(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
