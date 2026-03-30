class FixedActivity {
  final String name;
  final String day;
  final String time;

  const FixedActivity({required this.name, required this.day, required this.time});

  Map<String, dynamic> toJson() => {'name': name, 'day': day, 'time': time};

  factory FixedActivity.fromJson(Map<String, dynamic> j) =>
      FixedActivity(name: j['name'] as String, day: j['day'] as String, time: j['time'] as String);
}

class UserProfile {
  final String name;
  final String apiKey;
  final List<String> foodLikes;
  final List<String> foodDislikes;
  final List<String> foodNeutral;
  final List<FixedActivity> fixedActivities;
  final int gymSessionsPerWeek;
  final bool sameBreakfastEveryDay;
  final int maxWeekdayMealTime;
  final String shoppingDay;

  const UserProfile({
    required this.name,
    required this.apiKey,
    required this.foodLikes,
    required this.foodDislikes,
    required this.foodNeutral,
    required this.fixedActivities,
    required this.gymSessionsPerWeek,
    required this.sameBreakfastEveryDay,
    required this.maxWeekdayMealTime,
    required this.shoppingDay,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'apiKey': apiKey,
        'foodLikes': foodLikes,
        'foodDislikes': foodDislikes,
        'foodNeutral': foodNeutral,
        'fixedActivities': fixedActivities.map((a) => a.toJson()).toList(),
        'gymSessionsPerWeek': gymSessionsPerWeek,
        'sameBreakfastEveryDay': sameBreakfastEveryDay,
        'maxWeekdayMealTime': maxWeekdayMealTime,
        'shoppingDay': shoppingDay,
      };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        name: j['name'] as String,
        apiKey: j['apiKey'] as String,
        foodLikes: List<String>.from(j['foodLikes'] as List),
        foodDislikes: List<String>.from(j['foodDislikes'] as List),
        foodNeutral: List<String>.from(j['foodNeutral'] as List),
        fixedActivities: (j['fixedActivities'] as List)
            .map((a) => FixedActivity.fromJson(a as Map<String, dynamic>))
            .toList(),
        gymSessionsPerWeek: j['gymSessionsPerWeek'] as int,
        sameBreakfastEveryDay: j['sameBreakfastEveryDay'] as bool,
        maxWeekdayMealTime: j['maxWeekdayMealTime'] as int,
        shoppingDay: j['shoppingDay'] as String,
      );
}
