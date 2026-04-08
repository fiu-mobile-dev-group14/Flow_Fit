//
//  AppState.swift
//  FlowFit
//
//  Created by Javier Gil on 4/5/26.
//

import Foundation
import Observation

@Observable
class AppState {
 
    // MARK: - Auth State
    var currentUser: User? = User(
        username: "Demo User",
        goal: .cut,
        experienceLevel: .beginner
    )
    // TODO: Demo user to be replaced with real Parse auth call.
    
    var isLoggedIn: Bool { currentUser != nil }
 
    // MARK: - Today's Logs
    var todayMeals: [MealEntry] = []
    var todayWorkouts: [WorkoutEntry] = []
 
    // MARK: - Summaries
    var totalCaloriesToday: Int {
        todayMeals.reduce(0) { $0 + $1.calories }
    }
 
    var totalWorkoutsToday: Int {
        todayWorkouts.count
    }
 
    // MARK: - AI Suggestions Cache
    var mealSuggestions: [MealSuggestion] = []
    var workoutSuggestions: [WorkoutSuggestion] = []
    var isFetchingSuggestions: Bool = false
    var lastSuggestionFetch: Date? = nil
 
    // MARK: - Streak / Progress
    var currentStreak: Int = 3
    // TODO: placeholder; Progress will compute this from history
 
    // MARK: - Init
    init() {
        Task {
            await RecommendationsService.shared.loadCachedSuggestions(for: self)
        }
    }
    
    // MARK: - Helper Methods
    func logMeal(_ meal: MealEntry) {
        todayMeals.append(meal)
    }
 
    func logWorkout(_ workout: WorkoutEntry) {
        todayWorkouts.append(workout)
    }
 
    func logout() {
        currentUser = nil
        todayMeals = []
        todayWorkouts = []
        mealSuggestions = []
        workoutSuggestions = []
        lastSuggestionFetch = nil
        // Clear cached suggestions so next user gets fresh ones
        Task { await SuggestionsCache.shared.clear() }
    }
}
