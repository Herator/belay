import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../models/generated_plan.dart';

class ClaudeService {
  Future<GeneratedPlan> generatePlan(UserProfile profile) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${profile.apiKey}',
    );

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': _buildPrompt(profile)}
          ]
        }
      ],
      'generationConfig': {
        'maxOutputTokens': 8192,
        'temperature': 0.7,
      },
    });

    http.Response response;
    for (var attempt = 1; attempt <= 3; attempt++) {
      response = await http
          .post(url, headers: {'content-type': 'application/json'}, body: body)
          .timeout(const Duration(minutes: 3));

      if (response.statusCode == 429) {
        if (attempt == 3) throw Exception('Rate limit reached. Please wait a minute and try again.');
        await Future.delayed(Duration(seconds: 15 * attempt));
        continue;
      }

      if (response.statusCode != 200) {
        final err = jsonDecode(response.body);
        throw Exception(err['error']?['message'] ?? 'API error ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
      final planJson = jsonDecode(_extractJson(text)) as Map<String, dynamic>;

      return GeneratedPlan.fromJson({
        ...planJson,
        'generated_at': DateTime.now().toIso8601String(),
      });
    }

    throw Exception('Failed to generate plan after 3 attempts.');
  }

  String _extractJson(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start == -1 || end <= start) throw Exception('No JSON in response');
    return text.substring(start, end + 1);
  }

  String _buildPrompt(UserProfile profile) {
    final activities = profile.fixedActivities.isEmpty
        ? 'None'
        : profile.fixedActivities
            .map((a) => '${a.name} on ${a.day} at ${a.time}')
            .join(', ');

    return '''You are the core intelligence engine for "Belay", a hyper-personalized lifestyle app. Act as a world-class nutritionist, professional strength coach specializing in climbing and team sports, and logistics expert.

USER PROFILE:
- Name: ${profile.name}
- Food Likes: ${profile.foodLikes.isEmpty ? 'Not specified' : profile.foodLikes.join(', ')}
- Food Dislikes: ${profile.foodDislikes.isEmpty ? 'None' : profile.foodDislikes.join(', ')}
- Neutral Foods: ${profile.foodNeutral.isEmpty ? 'None' : profile.foodNeutral.join(', ')}
- Fixed Activities: $activities
- Gym Sessions Per Week: ${profile.gymSessionsPerWeek}
- Breakfast: ${profile.sameBreakfastEveryDay ? 'Same every day' : 'Varied daily'}
- Max Weekday Meal Prep: ${profile.maxWeekdayMealTime} minutes
- Shopping Day: ${profile.shoppingDay}

RULES:
1. Use standard grocery package sizes (e.g. 400g meat, 1L milk). Zero waste: every opened package fully used within 4 days.
2. After climbing: no heavy upper body or finger-intensive training next day.
3. After football/leg sport: no heavy leg sessions next day.
4. 4-week progressive structure: Week 1 Foundation, Week 2 Build, Week 3 Peak, Week 4 Deload.
5. Meals must respect max prep time on weekdays. Never include disliked foods.

Return ONLY a valid JSON object with no other text:
{
  "grocery_list": {
    "proteins": ["400g chicken breast"],
    "carbs": ["1kg oats"],
    "vegetables": ["200g spinach"],
    "dairy": ["1L milk"],
    "pantry_items": ["olive oil"],
    "other": []
  },
  "meal_plan": [
    {
      "day": "Monday",
      "breakfast": {"name": "Overnight Oats", "prep_time": 5, "ingredients": ["100g oats", "200ml milk"], "usage_alert": null, "calories": 420},
      "lunch": {"name": "Chicken Rice Bowl", "prep_time": 20, "ingredients": ["200g chicken", "150g rice"], "usage_alert": null, "calories": 650},
      "dinner": {"name": "Pasta Bolognese", "prep_time": 25, "ingredients": ["200g pasta", "200g mince"], "usage_alert": null, "calories": 750}
    }
  ],
  "training_plan": [
    {
      "week": 1,
      "theme": "Foundation Building",
      "days": [
        {"day": "Monday", "type": "fixed", "activity": "Climbing", "time": "18:00", "focus": null, "exercises": null, "notes": "Focus on technique"},
        {"day": "Tuesday", "type": "gym", "activity": null, "time": null, "focus": "Lower Body", "exercises": [{"name": "Back Squat", "sets": 4, "reps": "6-8", "rest": "3 min", "notes": null}], "notes": null},
        {"day": "Wednesday", "type": "rest", "activity": null, "time": null, "focus": null, "exercises": null, "notes": "Active recovery"}
      ]
    }
  ],
  "pantry_update": {
    "leftover": ["Olive oil (partial)"],
    "depleted": ["Chicken breast (fully used)"]
  },
  "weekly_note": "Encouraging message about the week"
}

Include ALL 7 days in meal_plan (Monday through Sunday). Include ALL 4 weeks in training_plan. Each week must have all 7 days.''';
  }
}
