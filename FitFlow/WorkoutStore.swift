//
//  WorkoutStore.swift
//  FitFlow
//
//  Created by Walter Cuadra on 4/1/26.
//

import SwiftUI
import Combine

class WorkoutStore: ObservableObject {
    @Published var workouts: [Workout] = [
        Workout(name: "Morning Walk", category: "Cardio", duration: 30, caloriesBurned: 150),
        Workout(name: "Upper Body Strength", category: "Strength", duration: 45, caloriesBurned: 250)
    ]

    func addWorkout(name: String, category: String, duration: Int, caloriesBurned: Int) {
        let newWorkout = Workout(
            name: name,
            category: category,
            duration: duration,
            caloriesBurned: caloriesBurned
        )
        workouts.append(newWorkout)
    }

    func deleteWorkout(at offsets: IndexSet) {
        workouts.remove(atOffsets: offsets)
    }
}
