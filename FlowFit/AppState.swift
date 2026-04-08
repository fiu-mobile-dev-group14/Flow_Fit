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
    var currentUser: User? = nil
    var isLoggedIn: Bool { currentUser != nil }
 
    // MARK: - Today's Logs
    var todayMeals: [MealEntry] = []
    var todayWorkouts: [WorkoutEntry] = []
 
    // MARK: - Computed Summaries
    var totalCaloriesToday: Int {
        todayMeals.reduce(0) { $0 + $1.calories }
    }
 
    var totalWorkoutsToday: Int {
        todayWorkouts.count
    }
 
    // MARK: - AI Suggestions
    var mealSuggestions: [MealSuggestion] = []
    var workoutSuggestions: [WorkoutSuggestion] = []
    var isFetchingSuggestions: Bool = false
    var lastSuggestionFetch: Date? = nil
 
    // MARK: - Progress
    var currentStreak: Int = 0
    var allWorkouts: [WorkoutEntry] = []
    var allMeals: [MealEntry] = []
 
    // MARK: - Init
    init() {
        Task {
            if let user = await AuthService.shared.restoreSession() {
                await loadUserData(user: user)
            }
            await RecommendationsService.shared.loadCachedSuggestions(for: self)
        }
    }
 
    // MARK: - Load User Data
    func loadUserData(user: User) async {
        await MainActor.run { self.currentUser = user }
 
        guard let uid = currentUser?.uid else { return }
 
        do {
            async let meals = FirestoreService.shared.fetchTodayMeals(uid: uid)
            async let workouts = FirestoreService.shared.fetchTodayWorkouts(uid: uid)
            async let allW = FirestoreService.shared.fetchAllWorkouts(uid: uid)
            async let allM = FirestoreService.shared.fetchAllMeals(uid: uid)
 
            let (todayM, todayW, historyW, historyM) = try await (meals, workouts, allW, allM)
 
            await MainActor.run {
                self.todayMeals = todayM
                self.todayWorkouts = todayW
                self.allWorkouts = historyW
                self.allMeals = historyM
                self.currentStreak = self.calculateStreak(from: historyW)
            }
        } catch {
            print("AppState loadUserData error: \(error)")
        }
    }
 
    // MARK: - Log Meal
    func logMeal(_ meal: MealEntry) {
        todayMeals.append(meal)
        allMeals.insert(meal, at: 0)
 
        guard let uid = currentUser?.uid else { return }
        Task {
            try? await FirestoreService.shared.saveMealEntry(meal, uid: uid)
        }
    }
 
    // MARK: - Log Workout
    func logWorkout(_ workout: WorkoutEntry) {
        todayWorkouts.append(workout)
        allWorkouts.insert(workout, at: 0)
 
        guard let uid = currentUser?.uid else { return }
        Task {
            try? await FirestoreService.shared.saveWorkoutEntry(workout, uid: uid)
        }
    }
 
    // MARK: - Logout
    func logout() {
        try? AuthService.shared.signOut()
        currentUser = nil
        todayMeals = []
        todayWorkouts = []
        allMeals = []
        allWorkouts = []
        mealSuggestions = []
        workoutSuggestions = []
        lastSuggestionFetch = nil
        currentStreak = 0
        Task { await SuggestionsCache.shared.clear() }
    }
 
    // MARK: - Streak Calculation
    private func calculateStreak(from workouts: [WorkoutEntry]) -> Int {
        guard !workouts.isEmpty else { return 0 }
 
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date()
 
        let workoutDays = Set(workouts.map {
            calendar.startOfDay(for: $0.date)
        })
 
        while workoutDays.contains(calendar.startOfDay(for: checkDate)) {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }
 
        return streak
    }
}
