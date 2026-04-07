//
//  WorkoutSuggestionEngine.swift
//  FitFlow
//
//  Created by Walter Cuadra on 4/1/26.
//

import Foundation

struct WorkoutSuggestionEngine {
    static func suggestions(for experience: String) -> [SuggestedWorkout] {
        switch experience {
        case "Beginner":
            return [
                SuggestedWorkout(
                    name: "Beginner Full Body",
                    difficulty: "Beginner",
                    focus: "Full Body",
                    description: "A simple full-body routine with basic compound movements.",
                    imageName: "beginner_full_body"
                ),
                SuggestedWorkout(
                    name: "Light Cardio Session",
                    difficulty: "Beginner",
                    focus: "Cardio",
                    description: "A low-impact cardio workout to build endurance.",
                    imageName: "light_cardio_session"
                ),
                SuggestedWorkout(
                    name: "Upper / Lower Split",
                    difficulty: "Beginner",
                    focus: "Upper/Lower",
                    description: "An easy split routine to introduce training structure.",
                    imageName: "upper_lower_split"
                )
            ]

        case "Intermediate":
            return [
                SuggestedWorkout(
                    name: "Push Pull Legs",
                    difficulty: "Intermediate",
                    focus: "Split",
                    description: "A balanced training split for strength and muscle growth.",
                    imageName: "push_pull_legs"
                ),
                SuggestedWorkout(
                    name: "Strength Upper Body",
                    difficulty: "Intermediate",
                    focus: "Upper",
                    description: "A focused upper-body workout with pressing and pulling.",
                    imageName: "strength_upper_body"
                ),
                SuggestedWorkout(
                    name: "Conditioning Cardio",
                    difficulty: "Intermediate",
                    focus: "Cardio",
                    description: "Moderate-intensity intervals to improve conditioning.",
                    imageName: "conditioning_cardio"
                )
            ]

        case "Advanced":
            return [
                SuggestedWorkout(
                    name: "Advanced Hypertrophy Split",
                    difficulty: "Advanced",
                    focus: "Muscle Growth",
                    description: "Higher-volume training focused on hypertrophy.",
                    imageName: "advanced_hypertrophy_split"
                ),
                SuggestedWorkout(
                    name: "Power Strength Session",
                    difficulty: "Advanced",
                    focus: "Strength",
                    description: "Heavy compound lifts with lower rep ranges.",
                    imageName: "power_strength_session"
                ),
                SuggestedWorkout(
                    name: "Athletic Conditioning",
                    difficulty: "Advanced",
                    focus: "Cardio",
                    description: "High-intensity conditioning for advanced athletes.",
                    imageName: "athletic_conditioning"
                )
            ]

        default:
            return [
                SuggestedWorkout(
                    name: "Plank",
                    difficulty: "Beginner",
                    focus: "Core",
                    description: "A simple starter core exercise.",
                    imageName: "plank"
                )
            ]
        }
    }
}
