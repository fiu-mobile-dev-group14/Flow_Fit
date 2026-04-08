//
//  WorkoutDetailView.swift
//  FitFlow
//
//  Created by Walter Cuadra on 4/6/26.
//

import SwiftUI

struct WorkoutDetailView: View {
    let workout: SuggestedWorkout

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(workout.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                HStack {
                    Text(workout.difficulty)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.12))
                        .foregroundColor(.blue)
                        .cornerRadius(10)

                    Text(workout.focus)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.12))
                        .foregroundColor(.green)
                        .cornerRadius(10)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)

                    Text(workout.description)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Example Plan")
                        .font(.headline)

                    if workout.focus == "Cardio" {
                        Text("• 5 min warm-up\n• 20–30 min steady cardio\n• 5 min cool-down")
                    } else if workout.focus == "Full Body" {
                        Text("• Squats: 3 sets\n• Push-ups: 3 sets\n• Rows: 3 sets\n• Plank: 3 rounds")
                    } else if workout.focus == "Upper" {
                        Text("• Bench Press: 3 sets\n• Shoulder Press: 3 sets\n• Rows: 3 sets\n• Curls: 3 sets")
                    } else {
                        Text("• Choose 4–5 exercises\n• Complete 3 sets each\n• Rest 60–90 seconds between sets")
                    }
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Workout Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
