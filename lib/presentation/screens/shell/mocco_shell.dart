import 'package:flutter/material.dart';
import '../../../core/utils/sound_player.dart';
import '../../widgets/dialogs/parent_gate_dialog.dart';
import '../../widgets/nav/mocco_bottom_nav.dart';
import '../counting/counting_screen.dart';
import '../home/home_screen.dart';
import '../letter/letter_onboarding_screen.dart';
import '../map/adventure_map_screen.dart';
import '../parent/parent_dashboard_screen.dart';
import '../rewards/rewards_screen.dart';

/// App shell with bottom nav (reff: Home / Explore / Rewards / Profile).
class MoccoShell extends StatefulWidget {
  const MoccoShell({super.key});

  @override
  State<MoccoShell> createState() => _MoccoShellState();
}

class _MoccoShellState extends State<MoccoShell> {
  int _index = 0;
  AdventureZone _exploreZone = AdventureZone.numbers;
  bool _parentUnlocked = false;

  void _goExplore(AdventureZone zone) {
    setState(() {
      _exploreZone = zone;
      _index = 1;
    });
  }

  void _openContinueLearning() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LetterOnboardingScreen(
          letterIndex: 0,
          onBack: () => Navigator.of(context).pop(),
          onCompleted: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _openQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CountingScreen(
          totalSteps: 5,
          onBack: () => Navigator.of(context).pop(),
          onCompleted: () {
            Navigator.of(context).pop();
            SoundPlayer.instance.playSuccess();
          },
        ),
      ),
    );
  }

  Future<void> _handleTab(int i) async {
    if (i == 3 && !_parentUnlocked) {
      final ok = await ParentGateDialog.show(context);
      if (ok == true) {
        setState(() {
          _parentUnlocked = true;
          _index = i;
        });
      }
      return;
    }
    setState(() => _index = i);
    SoundPlayer.instance.playPop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            onExploreZone: _goExplore,
            onContinueLearning: _openContinueLearning,
            onOpenQuiz: _openQuiz,
          ),
          AdventureMapScreen(
            key: ValueKey('map-${_exploreZone.name}'),
            initialZone: _exploreZone,
          ),
          const RewardsScreen(),
          const ParentDashboardScreen(),
        ],
      ),
      bottomNavigationBar: MoccoBottomNav(
        currentIndex: _index,
        onTap: _handleTab,
      ),
    );
  }
}
