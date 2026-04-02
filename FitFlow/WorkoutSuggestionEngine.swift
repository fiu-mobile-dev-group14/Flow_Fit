//
//  WorkoutSuggestionEngine.swift
//  FitFlow
//
//  Created by Walter Cuadra on 4/1/26.
//

struct WorkoutSuggestionEngine {
    static func suggestions(for goal: String) -> [String] {
        switch goal {
        case "Weight Loss":
            return [
                "30-minute brisk walk",
                "20-minute HIIT workout",
                "Cycling for 40 minutes",
                "Jump rope for 15 minutes"
            ]
        case "Muscle Gain":
            return [
                "Upper body strength training",
                "Lower body leg workout",
                "Push day: chest, shoulders, triceps",
                "Pull day: back and biceps"
            ]
        case "General Fitness":
            return [
                "Full body workout",
                "Light jog for 25 minutes",
                "Bodyweight circuit",
                "Yoga or stretching session"
            ]
        default:
            return [
                "Take a short walk",
                "Do a light stretching routine"
            ]
        }
    }
}
