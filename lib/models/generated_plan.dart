class GroceryList {
  final List<String> proteins;
  final List<String> carbs;
  final List<String> vegetables;
  final List<String> dairy;
  final List<String> pantryItems;
  final List<String> other;

  const GroceryList({
    required this.proteins,
    required this.carbs,
    required this.vegetables,
    required this.dairy,
    required this.pantryItems,
    required this.other,
  });

  factory GroceryList.fromJson(Map<String, dynamic> j) => GroceryList(
        proteins: List<String>.from(j['proteins'] as List? ?? []),
        carbs: List<String>.from(j['carbs'] as List? ?? []),
        vegetables: List<String>.from(j['vegetables'] as List? ?? []),
        dairy: List<String>.from(j['dairy'] as List? ?? []),
        pantryItems: List<String>.from(j['pantry_items'] as List? ?? []),
        other: List<String>.from(j['other'] as List? ?? []),
      );

  Map<String, dynamic> toJson() => {
        'proteins': proteins,
        'carbs': carbs,
        'vegetables': vegetables,
        'dairy': dairy,
        'pantry_items': pantryItems,
        'other': other,
      };
}

class Meal {
  final String name;
  final int prepTime;
  final List<String> ingredients;
  final String? usageAlert;
  final int? calories;

  const Meal({
    required this.name,
    required this.prepTime,
    required this.ingredients,
    this.usageAlert,
    this.calories,
  });

  factory Meal.fromJson(Map<String, dynamic> j) => Meal(
        name: j['name'] as String? ?? '',
        prepTime: (j['prep_time'] as num?)?.toInt() ?? 0,
        ingredients: List<String>.from(j['ingredients'] as List? ?? []),
        usageAlert: j['usage_alert'] as String?,
        calories: (j['calories'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'prep_time': prepTime,
        'ingredients': ingredients,
        'usage_alert': usageAlert,
        'calories': calories,
      };
}

class DayMealPlan {
  final String day;
  final Meal breakfast;
  final Meal lunch;
  final Meal dinner;

  const DayMealPlan({required this.day, required this.breakfast, required this.lunch, required this.dinner});

  factory DayMealPlan.fromJson(Map<String, dynamic> j) => DayMealPlan(
        day: j['day'] as String? ?? '',
        breakfast: Meal.fromJson(j['breakfast'] as Map<String, dynamic>? ?? {}),
        lunch: Meal.fromJson(j['lunch'] as Map<String, dynamic>? ?? {}),
        dinner: Meal.fromJson(j['dinner'] as Map<String, dynamic>? ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'day': day,
        'breakfast': breakfast.toJson(),
        'lunch': lunch.toJson(),
        'dinner': dinner.toJson(),
      };
}

class Exercise {
  final String name;
  final int sets;
  final String reps;
  final String rest;
  final String? notes;

  const Exercise({required this.name, required this.sets, required this.reps, required this.rest, this.notes});

  factory Exercise.fromJson(Map<String, dynamic> j) => Exercise(
        name: j['name'] as String? ?? '',
        sets: (j['sets'] as num?)?.toInt() ?? 0,
        reps: j['reps'] as String? ?? '',
        rest: j['rest'] as String? ?? '',
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {'name': name, 'sets': sets, 'reps': reps, 'rest': rest, 'notes': notes};
}

class TrainingDay {
  final String day;
  final String type; // 'fixed', 'gym', 'rest'
  final String? activity;
  final String? time;
  final String? focus;
  final List<Exercise>? exercises;
  final String? notes;

  const TrainingDay({
    required this.day,
    required this.type,
    this.activity,
    this.time,
    this.focus,
    this.exercises,
    this.notes,
  });

  factory TrainingDay.fromJson(Map<String, dynamic> j) => TrainingDay(
        day: j['day'] as String? ?? '',
        type: j['type'] as String? ?? 'rest',
        activity: j['activity'] as String?,
        time: j['time'] as String?,
        focus: j['focus'] as String?,
        exercises: (j['exercises'] as List?)
            ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
            .toList(),
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'day': day,
        'type': type,
        'activity': activity,
        'time': time,
        'focus': focus,
        'exercises': exercises?.map((e) => e.toJson()).toList(),
        'notes': notes,
      };
}

class WeekTrainingPlan {
  final int week;
  final String theme;
  final List<TrainingDay> days;

  const WeekTrainingPlan({required this.week, required this.theme, required this.days});

  factory WeekTrainingPlan.fromJson(Map<String, dynamic> j) => WeekTrainingPlan(
        week: (j['week'] as num?)?.toInt() ?? 0,
        theme: j['theme'] as String? ?? '',
        days: (j['days'] as List? ?? [])
            .map((d) => TrainingDay.fromJson(d as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'week': week,
        'theme': theme,
        'days': days.map((d) => d.toJson()).toList(),
      };
}

class PantryUpdate {
  final List<String> leftover;
  final List<String> depleted;

  const PantryUpdate({required this.leftover, required this.depleted});

  factory PantryUpdate.fromJson(Map<String, dynamic> j) => PantryUpdate(
        leftover: List<String>.from(j['leftover'] as List? ?? []),
        depleted: List<String>.from(j['depleted'] as List? ?? []),
      );

  Map<String, dynamic> toJson() => {'leftover': leftover, 'depleted': depleted};
}

class GeneratedPlan {
  final GroceryList groceryList;
  final List<DayMealPlan> mealPlan;
  final List<WeekTrainingPlan> trainingPlan;
  final PantryUpdate pantryUpdate;
  final String weeklyNote;
  final DateTime generatedAt;

  const GeneratedPlan({
    required this.groceryList,
    required this.mealPlan,
    required this.trainingPlan,
    required this.pantryUpdate,
    required this.weeklyNote,
    required this.generatedAt,
  });

  factory GeneratedPlan.fromJson(Map<String, dynamic> j) => GeneratedPlan(
        groceryList: GroceryList.fromJson(j['grocery_list'] as Map<String, dynamic>? ?? {}),
        mealPlan: (j['meal_plan'] as List? ?? [])
            .map((d) => DayMealPlan.fromJson(d as Map<String, dynamic>))
            .toList(),
        trainingPlan: (j['training_plan'] as List? ?? [])
            .map((w) => WeekTrainingPlan.fromJson(w as Map<String, dynamic>))
            .toList(),
        pantryUpdate: PantryUpdate.fromJson(j['pantry_update'] as Map<String, dynamic>? ?? {}),
        weeklyNote: j['weekly_note'] as String? ?? '',
        generatedAt: j['generated_at'] != null
            ? DateTime.parse(j['generated_at'] as String)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'grocery_list': groceryList.toJson(),
        'meal_plan': mealPlan.map((d) => d.toJson()).toList(),
        'training_plan': trainingPlan.map((w) => w.toJson()).toList(),
        'pantry_update': pantryUpdate.toJson(),
        'weekly_note': weeklyNote,
        'generated_at': generatedAt.toIso8601String(),
      };
}
