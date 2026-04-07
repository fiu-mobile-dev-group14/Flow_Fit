//
//  WorkoutStore.swift
//  FitFlow
//
//  Created by Walter Cuadra on 4/1/26.
//

import SwiftUI
import Combine

class WorkoutStore: ObservableObject {
    @Published var workoutEntries: [WorkoutEntry] = [
        WorkoutEntry(
            exerciseName: "Bench Press",
            sets: 3,
            reps: 10,
            weight: 135,
            duration: 0,
            notes: "Focused on form"
        ),
        WorkoutEntry(
            exerciseName: "Treadmill Walk",
            sets: 0,
            reps: 0,
            weight: 0,
            duration: 25,
            notes: "Steady incline walk"
        )
    ]

    func addWorkout(
        exerciseName: String,
        sets: Int,
        reps: Int,
        weight: Double,
        duration: Int,
        notes: String
    ) {
        let newEntry = WorkoutEntry(
            exerciseName: exerciseName,
            sets: sets,
            reps: reps,
            weight: weight,
            duration: duration,
            notes: notes
        )
        workoutEntries.append(newEntry)
    }

    func deleteWorkout(at offsets: IndexSet) {
        workoutEntries.remove(atOffsets: offsets)
    }

    var totalWorkouts: Int {
        workoutEntries.count
    }

    var totalMinutes: Int {
        workoutEntries.reduce(0) { $0 + $1.duration }
    }
}
