import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../models/user_profile.dart';
import '../providers/app_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Step 1 - API Key
  final _apiKeyCtrl = TextEditingController();
  bool _apiKeyObscured = true;

  // Step 2 - Name
  final _nameCtrl = TextEditingController();

  // Step 3 - Food prefs
  int _foodTab = 0;
  final _foodCtrl = TextEditingController();
  final List<String> _likes = [];
  final List<String> _dislikes = [];
  final List<String> _neutral = [];

  // Step 4 - Activities
  final List<FixedActivity> _activities = [];

  // Step 5 - Settings
  int _gymSessions = 3;
  bool _sameBreakfast = true;
  double _maxPrepTime = 20;
  String _shoppingDay = 'Friday';

  final _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final _sports = ['Climbing', 'Football', 'Basketball', 'Swimming', 'Cycling', 'Running', 'Tennis', 'Other'];

  void _next() {
    if (_currentPage < 5) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentPage++);
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentPage--);
    }
  }

  void _addFood(List<String> list) {
    final val = _foodCtrl.text.trim();
    if (val.isEmpty) return;
    setState(() {
      list.add(val);
      _foodCtrl.clear();
    });
  }

  void _removeFood(List<String> list, int i) => setState(() => list.removeAt(i));

  Future<void> _addActivity() async {
    String name = _sports[0];
    String day = _days[0];
    String time = '18:00';
    final timeCtrl = TextEditingController(text: time);

    await showModalBottomSheet(
      context: context,
      backgroundColor: BelayColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Activity', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 20),
              Text('Sport', style: Theme.of(ctx).textTheme.bodyMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: name,
                decoration: const InputDecoration(),
                dropdownColor: BelayColors.card,
                items: _sports.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setSheet(() => name = v!),
              ),
              const SizedBox(height: 16),
              Text('Day', style: Theme.of(ctx).textTheme.bodyMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: day,
                decoration: const InputDecoration(),
                dropdownColor: BelayColors.card,
                items: _days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => setSheet(() => day = v!),
              ),
              const SizedBox(height: 16),
              Text('Time (e.g. 18:00)', style: Theme.of(ctx).textTheme.bodyMedium),
              const SizedBox(height: 8),
              TextField(
                controller: timeCtrl,
                decoration: const InputDecoration(hintText: '18:00'),
                onChanged: (v) => time = v,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() => _activities.add(FixedActivity(name: name, day: day, time: timeCtrl.text)));
                  Navigator.pop(ctx);
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final profile = UserProfile(
      name: _nameCtrl.text.trim().isEmpty ? 'Athlete' : _nameCtrl.text.trim(),
      apiKey: _apiKeyCtrl.text.trim(),
      foodLikes: List.from(_likes),
      foodDislikes: List.from(_dislikes),
      foodNeutral: List.from(_neutral),
      fixedActivities: List.from(_activities),
      gymSessionsPerWeek: _gymSessions,
      sameBreakfastEveryDay: _sameBreakfast,
      maxWeekdayMealTime: _maxPrepTime.round(),
      shoppingDay: _shoppingDay,
    );
    context.read<AppProvider>().generatePlan(profile);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _apiKeyCtrl.dispose();
    _nameCtrl.dispose();
    _foodCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            if (_currentPage > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      onPressed: _back,
                      color: BelayColors.textSecondary,
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _currentPage / 5,
                          backgroundColor: BelayColors.border,
                          valueColor: const AlwaysStoppedAnimation(BelayColors.accent),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcome(),
                  _buildApiKey(),
                  _buildName(),
                  _buildFoodPrefs(),
                  _buildActivities(),
                  _buildSettings(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: BelayColors.accent,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.fitness_center, size: 52, color: Colors.white),
          ),
          const SizedBox(height: 32),
          Text('Belay', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 12),
          Text(
            'Your personal coach for training, nutrition, and zero-waste meal planning.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: BelayColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: _next,
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKey() {
    return _StepScaffold(
      title: 'Gemini API Key',
      subtitle: 'Belay uses Google Gemini AI to build your personalized plan. Enter your Gemini API key below.',
      onNext: () {
        if (_apiKeyCtrl.text.trim().isEmpty) return;
        _next();
      },
      child: Column(
        children: [
          TextField(
            controller: _apiKeyCtrl,
            obscureText: _apiKeyObscured,
            decoration: InputDecoration(
              labelText: 'API Key',
              hintText: 'AIza...',
              suffixIcon: IconButton(
                icon: Icon(_apiKeyObscured ? Icons.visibility_off : Icons.visibility, color: BelayColors.textSecondary),
                onPressed: () => setState(() => _apiKeyObscured = !_apiKeyObscured),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Get your key at aistudio.google.com',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildName() {
    return _StepScaffold(
      title: "What's your name?",
      subtitle: 'So Belay can greet you properly.',
      onNext: _next,
      child: TextField(
        controller: _nameCtrl,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(labelText: 'Your name', hintText: 'Alex'),
      ),
    );
  }

  Widget _buildFoodPrefs() {
    final tabs = ['Like', 'Dislike', 'Neutral'];
    final lists = [_likes, _dislikes, _neutral];
    final colors = [BelayColors.success, BelayColors.error, BelayColors.textSecondary];
    final current = lists[_foodTab];

    return _StepScaffold(
      title: 'Food Preferences',
      subtitle: 'Tell Belay what you enjoy eating.',
      onNext: _next,
      child: Column(
        children: [
          // Tab selector
          Container(
            decoration: BoxDecoration(
              color: BelayColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: List.generate(3, (i) => Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _foodTab = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _foodTab == i ? colors[i].withOpacity(0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tabs[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _foodTab == i ? colors[i] : BelayColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              )),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _foodCtrl,
                  decoration: const InputDecoration(hintText: 'Type a food...'),
                  onSubmitted: (_) => _addFood(current),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _addFood(current),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(56, 56),
                  padding: EdgeInsets.zero,
                ),
                child: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              current.length,
              (i) => Chip(
                label: Text(current[i]),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => _removeFood(current, i),
                backgroundColor: colors[_foodTab].withOpacity(0.15),
                side: BorderSide(color: colors[_foodTab].withOpacity(0.4)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivities() {
    return _StepScaffold(
      title: 'Your Activities',
      subtitle: 'Add your fixed weekly sports so Belay can plan around them.',
      onNext: _next,
      child: Column(
        children: [
          ..._activities.asMap().entries.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: BelayColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: BelayColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sports, color: BelayColors.teal, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.value.name, style: const TextStyle(fontWeight: FontWeight.w600, color: BelayColors.textPrimary)),
                          Text('${e.value.day} at ${e.value.time}', style: const TextStyle(color: BelayColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: BelayColors.error, size: 20),
                      onPressed: () => setState(() => _activities.removeAt(e.key)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addActivity,
            icon: const Icon(Icons.add),
            label: const Text('Add Activity'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return _StepScaffold(
      title: 'Final Settings',
      subtitle: 'Almost there! Fine-tune your plan.',
      onNext: _submit,
      nextLabel: 'Generate My Plan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gym sessions
          Text('Gym sessions per week: $_gymSessions',
              style: const TextStyle(color: BelayColors.textPrimary, fontWeight: FontWeight.w500)),
          Slider(
            value: _gymSessions.toDouble(),
            min: 1,
            max: 6,
            divisions: 5,
            label: '$_gymSessions',
            onChanged: (v) => setState(() => _gymSessions = v.round()),
          ),
          const SizedBox(height: 16),
          // Max prep time
          Text('Max weekday meal prep: ${_maxPrepTime.round()} min',
              style: const TextStyle(color: BelayColors.textPrimary, fontWeight: FontWeight.w500)),
          Slider(
            value: _maxPrepTime,
            min: 10,
            max: 60,
            divisions: 10,
            label: '${_maxPrepTime.round()} min',
            onChanged: (v) => setState(() => _maxPrepTime = v),
          ),
          const SizedBox(height: 16),
          // Breakfast
          Row(
            children: [
              Expanded(
                child: Text('Same breakfast every day',
                    style: const TextStyle(color: BelayColors.textPrimary, fontWeight: FontWeight.w500)),
              ),
              Switch(
                value: _sameBreakfast,
                onChanged: (v) => setState(() => _sameBreakfast = v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Shopping day
          Text('Shopping Day', style: const TextStyle(color: BelayColors.textPrimary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _shoppingDay,
            decoration: const InputDecoration(),
            dropdownColor: BelayColors.card,
            items: _days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (v) => setState(() => _shoppingDay = v!),
          ),
        ],
      ),
    );
  }
}

class _StepScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback onNext;
  final String nextLabel;

  const _StepScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onNext,
    this.nextLabel = 'Continue',
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          child,
          const SizedBox(height: 32),
          ElevatedButton(onPressed: onNext, child: Text(nextLabel)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
