//
//  RecommendationsService.swift
//  FlowFit
//
//  Created by Javier Gil on 4/5/26.
//

import Foundation
 
actor RecommendationsService {
 
    static let shared = RecommendationsService()
    private init() {}
 
    // Go to aistudio.google.com to get a Gemini API key.
    // Create a Swift file called Secrets and all you need is to add this after the default import
    
    /*
     enum Secrets {
         static let geminiAPIKey = "YOUR_API_KEY"
     }
     */
    
    private let apiKey = Secrets.geminiAPIKey
    private var apiURL: URL {
        URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=\(apiKey)")!
    }
 
    // Tracks which suggestion IDs the user has dismissed this session.
    private var dismissedIDs: Set<UUID> = []
 
    // MARK: - Public Entry Points
    func fetchSuggestions(for appState: AppState) async {
        guard let user = await appState.currentUser else { return }
 
        await MainActor.run { appState.isFetchingSuggestions = true }
 
        async let meals = fetchMealSuggestions(user: user, appState: appState)
        async let workouts = fetchWorkoutSuggestions(user: user, appState: appState)
 
        let (fetchedMeals, fetchedWorkouts) = await (meals, workouts)
 
        let filteredMeals = fetchedMeals.filter { !dismissedIDs.contains($0.id) }
        let filteredWorkouts = fetchedWorkouts.filter { !dismissedIDs.contains($0.id) }
        
        await MainActor.run {
            appState.mealSuggestions = filteredMeals
            appState.workoutSuggestions = filteredWorkouts
            appState.isFetchingSuggestions = false
            appState.lastSuggestionFetch = Date()
        }
 
        await SuggestionsCache.shared.save(meals: fetchedMeals, workouts: fetchedWorkouts)
    }
 
    func loadCachedSuggestions(for appState: AppState) async {
        let cached = await SuggestionsCache.shared.load()
 
        await MainActor.run {
            if !cached.meals.isEmpty { appState.mealSuggestions = cached.meals }
            if !cached.workouts.isEmpty { appState.workoutSuggestions = cached.workouts }
        }
 
        if await SuggestionsCache.shared.isStale() {
            await fetchSuggestions(for: appState)
        }
    }
 
    func dismiss(suggestionID: UUID, from appState: AppState) async {
        dismissedIDs.insert(suggestionID)
        await MainActor.run {
            appState.mealSuggestions.removeAll { $0.id == suggestionID }
            appState.workoutSuggestions.removeAll { $0.id == suggestionID }
        }
    }
 
    // MARK: - Meal Suggestions
    private func fetchMealSuggestions(user: User, appState: AppState) async -> [MealSuggestion] {
        let caloriesEaten = await appState.totalCaloriesToday
        let mealsLogged = await appState.todayMeals.map { $0.name }.joined(separator: ", ")
        let calorieTarget = await appState.currentUser?.calorieTarget ?? 2000
        let remainingCalories = calorieTarget - caloriesEaten
 
        let prompt = """
            You are a nutrition assistant inside a fitness app called FlowFit.
        
            USER PROFILE:
            - Fitness goal: \(user.goal.promptDescription)
            - Experience level: \(user.experienceLevel.rawValue)
            - Daily calorie target: \(calorieTarget) kcal
        
            TODAY SO FAR:
            - Calories consumed: \(caloriesEaten) kcal
            - Remaining calories: \(remainingCalories) kcal
            - Meals already logged today: \(mealsLogged.isEmpty ? "none yet" : mealsLogged)
        
            TASK:
            Suggest 3 meals that would fit well into the rest of this user's day.
            Consider their remaining calories and avoid repeating meals already logged.
            Each meal should be realistic, specific (not just "salad"), and practical to prepare.
        
            Return ONLY valid JSON, no markdown, no explanation:
            {
              "meals": [
                {
                  "name": "Specific meal name",
                  "estimatedCalories": 450,
                  "description": "One sentence describing ingredients and why it fits their goal.",
                  "goalType": "\(user.goal.rawValue)"
                }
              ]
            }
        """
 
        do {
            let data = try await callGemini(prompt: prompt)
            let response = try JSONDecoder().decode(MealsResponse.self, from: data)
            return response.meals.map {
                MealSuggestion(name: $0.name,
                               estimatedCalories: $0.estimatedCalories,
                               description: $0.description,
                               goalType: $0.goalType)
            }
        } catch {
            print("Meal suggestion error: \(error)")
            return fallbackMeals(for: user)
        }
    }
 
    // MARK: - Workout Suggestions
    private func fetchWorkoutSuggestions(user: User, appState: AppState) async -> [WorkoutSuggestion] {
        let workoutsToday = await appState.todayWorkouts.map { $0.exerciseName }.joined(separator: ", ")
        let streak = await appState.currentStreak
 
        let prompt = """
            You are a fitness coach inside a fitness app called FlowFit.
        
            USER PROFILE:
            - Fitness goal: \(user.goal.promptDescription)
            - Experience level: \(user.experienceLevel.rawValue)
            - Current streak: \(streak) days
        
            TODAY SO FAR:
            - Exercises already logged: \(workoutsToday.isEmpty ? "none yet" : workoutsToday)
        
            TASK:
            Suggest 3 workouts appropriate for this user.
            If they've already exercised today, suggest complementary or recovery options.
            Be specific — include approximate sets/reps or duration in the description.
            Match difficulty to their experience level.
        
            Return ONLY valid JSON, no markdown, no explanation:
            {
              "workouts": [
                {
                  "name": "Specific workout name",
                  "difficulty": "\(user.experienceLevel.rawValue)",
                  "focus": "upper / lower / full body / cardio / recovery",
                  "description": "One sentence with specific sets, reps, or duration."
                }
              ]
            }
        """
 
        do {
            let data = try await callGemini(prompt: prompt)
            let response = try JSONDecoder().decode(WorkoutsResponse.self, from: data)
            return response.workouts.map {
                WorkoutSuggestion(name: $0.name,
                                  difficulty: $0.difficulty,
                                  focus: $0.focus,
                                  description: $0.description)
            }
        } catch {
            print("Workout suggestion error: \(error)")
            return fallbackWorkouts(for: user)
        }
    }
 
    // MARK: - Core API Call
    private func callGemini(prompt: String) async throws -> Data {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
 
        // Gemini's request body format
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7,    // 0 = deterministic, 1 = creative.
                "maxOutputTokens": 4096
            ]
        ]
 
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
 
        let (data, response) = try await URLSession.shared.data(for: request)
 
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            // Raw response in console for debugging
            print("Gemini error response: \(String(data: data, encoding: .utf8) ?? "unreadable")")
            throw ServiceError.badResponse
        }
 
        let envelope = try JSONDecoder().decode(GeminiEnvelope.self, from: data)
        guard let text = envelope.candidates.first?.content.parts.first?.text else {
            throw ServiceError.noContent
        }

        let cleanedText = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = cleanedText.data(using: .utf8) else {
            throw ServiceError.noContent
        }

        return jsonData
    }
 
    // MARK: - Fallback Suggestions
    private func fallbackMeals(for user: User) -> [MealSuggestion] {
        switch user.goal {
        case .cut:
            return [
                MealSuggestion(name: "Grilled Chicken & Vegetables", estimatedCalories: 380,
                               description: "High protein, low calorie meal to support fat loss.", goalType: "cut"),
                MealSuggestion(name: "Greek Yogurt with Berries", estimatedCalories: 180,
                               description: "Low calorie snack rich in protein and antioxidants.", goalType: "cut"),
                MealSuggestion(name: "Tuna Salad Wrap", estimatedCalories: 320,
                               description: "Lean protein with fiber to keep you full longer.", goalType: "cut")
            ]
        case .bulk:
            return [
                MealSuggestion(name: "Chicken Rice Bowl", estimatedCalories: 720,
                               description: "High calorie, high protein post-workout meal.", goalType: "bulk"),
                MealSuggestion(name: "Peanut Butter Banana Shake", estimatedCalories: 550,
                               description: "Calorie-dense shake for hitting your surplus.", goalType: "bulk"),
                MealSuggestion(name: "Pasta with Ground Beef", estimatedCalories: 680,
                               description: "Carb and protein dense meal for muscle building.", goalType: "bulk")
            ]
        case .maintain:
            return [
                MealSuggestion(name: "Salmon with Sweet Potato", estimatedCalories: 520,
                               description: "Balanced macros with healthy fats for maintenance.", goalType: "maintain"),
                MealSuggestion(name: "Veggie Omelette", estimatedCalories: 340,
                               description: "Balanced breakfast with protein and micronutrients.", goalType: "maintain"),
                MealSuggestion(name: "Turkey and Avocado Sandwich", estimatedCalories: 450,
                               description: "Well-rounded lunch with healthy fats and lean protein.", goalType: "maintain")
            ]
        }
    }
 
    private func fallbackWorkouts(for user: User) -> [WorkoutSuggestion] {
        switch user.experienceLevel {
        case .beginner:
            return [
                WorkoutSuggestion(name: "Full Body Starter", difficulty: "Beginner",
                                  focus: "full body", description: "3 sets of 10 squats, push-ups, and rows."),
                WorkoutSuggestion(name: "20-Minute Walk", difficulty: "Beginner",
                                  focus: "cardio", description: "Brisk walk to build baseline cardio fitness."),
                WorkoutSuggestion(name: "Core Foundation", difficulty: "Beginner",
                                  focus: "core", description: "3 sets of planks (30s), crunches, and leg raises.")
            ]
        case .intermediate:
            return [
                WorkoutSuggestion(name: "Push Day", difficulty: "Intermediate",
                                  focus: "upper", description: "4 sets each: bench press, shoulder press, tricep dips."),
                WorkoutSuggestion(name: "Leg Day", difficulty: "Intermediate",
                                  focus: "lower", description: "4 sets each: squats, lunges, leg press, calf raises."),
                WorkoutSuggestion(name: "HIIT Cardio", difficulty: "Intermediate",
                                  focus: "cardio", description: "20 minutes alternating 40s effort / 20s rest.")
            ]
        case .advanced:
            return [
                WorkoutSuggestion(name: "Heavy Pull Day", difficulty: "Advanced",
                                  focus: "upper", description: "5x5 deadlifts, 4x8 weighted pull-ups, 4x10 rows."),
                WorkoutSuggestion(name: "Squat Pyramid", difficulty: "Advanced",
                                  focus: "lower", description: "Pyramid sets from 8 down to 3 reps, increasing weight each set."),
                WorkoutSuggestion(name: "Tempo Training", difficulty: "Advanced",
                                  focus: "full body", description: "Full body circuit with 3-second eccentric on each movement.")
            ]
        }
    }
 
    // MARK: - Internal Codable Types 
    private struct GeminiEnvelope: Codable {
        let candidates: [Candidate]
 
        struct Candidate: Codable {
            let content: Content
        }
 
        struct Content: Codable {
            let parts: [Part]
        }
 
        struct Part: Codable {
            let text: String
        }
    }
 
    private struct MealsResponse: Codable {
        let meals: [RawMeal]
        struct RawMeal: Codable {
            let name: String
            let estimatedCalories: Int
            let description: String
            let goalType: String
        }
    }
 
    private struct WorkoutsResponse: Codable {
        let workouts: [RawWorkout]
        struct RawWorkout: Codable {
            let name: String
            let difficulty: String
            let focus: String
            let description: String
        }
    }
 
    enum ServiceError: Error {
        case badResponse
        case noContent
    }
}
