//
//  Models.swift
//  FlowFit
//
//  Created by Javier Gil on 4/5/26.
//

import Foundation

// MARK: - User
struct User {
    var username: String
    var goal: FitnessGoal                   // Determines meal and workout suggestions
    var experienceLevel: ExperienceLevel    // Determines workout suggestions
}

enum FitnessGoal: String, CaseIterable, Identifiable {
    case cut = "Lose Weight"
    case maintain = "Maintain"
    case bulk = "Gain Muscle"
    
    var id: String { rawValue }
    
    var promptDescription: String {
        switch self {
        case .cut: return "lose body fat while preserving muscle, calorie deficit"
        case .maintain: return "maintain current weight and improve fitness"
        case .bulk:     return "gain muscle mass, calorie surplus, progressive overload"
        }
    }
}

enum ExperienceLevel: String, CaseIterable, Identifiable {
    case beginner     = "Beginner"
    case intermediate = "Intermediate"
    case advanced     = "Advanced"
 
    var id: String { rawValue }
}

// MARK: - Meal Entry
struct MealEntry: Identifiable, Codable {
    let id: UUID
    var date: Date
    var name: String
    var calories: Int
    var notes: String?
    var goal: String        // Snapshot of goal at the time of user logging in
    
    init(id: UUID = UUID(), name: String, calories: Int, notes: String = "", date: Date = Date(), goal: String = "") {
        self.id = id
        self.name = name
        self.calories = calories
        self.notes = notes
        self.date = date
        self.goal = goal
    }
}

// MARK: - Workout Entry
struct WorkoutEntry: Identifiable, Codable {
    let id: UUID
    var exerciseName: String
    var sets: Int
    var reps: Int
    var weight: Double         // Weight added to machine or of dumbbels in lbs; 0 if bodyweight or cardio
    var duration: Int          // Time in minutes; 0 if not cardio
    var notes: String
    var date: Date
    
}

// MARK: - AI Suggestion Models
struct MealSuggestion: Identifiable, Codable {
    let id: UUID
    var name: String
    var estimatedCalories: Int
    var description: String
    var goalType: String        // "cut", "maintain", "bulk"
 
    init(id: UUID = UUID(), name: String, estimatedCalories: Int, description: String, goalType: String) {
        self.id = id
        self.name = name
        self.estimatedCalories = estimatedCalories
        self.description = description
        self.goalType = goalType
    }
}
 
struct WorkoutSuggestion: Identifiable, Codable {
    let id: UUID
    var name: String
    var difficulty: String
    var focus: String           // "full body", "upper", "lower", "cardio"
    var description: String
 
    init(id: UUID = UUID(), name: String, difficulty: String, focus: String, description: String) {
        self.id = id
        self.name = name
        self.difficulty = difficulty
        self.focus = focus
        self.description = description
    }
}
    
