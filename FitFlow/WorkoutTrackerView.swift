//
//  WorkoutTrackerView.swift
//  FitFlow
//
//  Created by Walter Cuadra on 4/1/26.
//

import SwiftUI

struct WorkoutTrackerView: View {
    @ObservedObject var store: WorkoutStore

    @State private var workoutName = ""
    @State private var selectedCategory = "Cardio"
    @State private var duration = ""
    @State private var calories = ""

    let categories = ["Cardio", "Strength", "Flexibility", "HIIT", "Sports"]

    var totalCalories: Int {
        store.workouts.reduce(0) { $0 + $1.caloriesBurned }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("FitFlow")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Build momentum every day.")
                        .foregroundColor(.gray)

                    Text("🔥 Total Calories: \(totalCalories)")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                Form {
                    Section("Add Workout") {
                        TextField("Workout name", text: $workoutName)

                        Picker("Category", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { category in
                                Text(category)
                            }
                        }

                        TextField("Duration (minutes)", text: $duration)
                            .keyboardType(.numberPad)

                        TextField("Calories burned", text: $calories)
                            .keyboardType(.numberPad)

                        Button("Save Workout") {
                            saveWorkout()
                        }
                    }

                    Section("Workout History") {
                        if store.workouts.isEmpty {
                            Text("No workouts yet. Start tracking 💪")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(store.workouts) { workout in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(workout.name)
                                        .font(.headline)

                                    Text("\(workout.category) • \(workout.duration) min • \(workout.caloriesBurned) cal")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)

                                    Text(workout.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 6)
                            }
                            .onDelete(perform: store.deleteWorkout)
                        }
                    }
                }
            }
            .navigationTitle("Track")
        }
    }

    func saveWorkout() {
        guard !workoutName.trimmingCharacters(in: .whitespaces).isEmpty,
              let durationInt = Int(duration),
              let caloriesInt = Int(calories) else {
            return
        }

        store.addWorkout(
            name: workoutName,
            category: selectedCategory,
            duration: durationInt,
            caloriesBurned: caloriesInt
        )

        workoutName = ""
        selectedCategory = "Cardio"
        duration = ""
        calories = ""
    }
}
