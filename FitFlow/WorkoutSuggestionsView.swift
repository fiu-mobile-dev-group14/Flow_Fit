//
//  WorkoutSuggestionsView.swift
//  FitFlow
//
//  Created by Walter Cuadra on 4/1/26.
//

import SwiftUI

struct WorkoutSuggestionsView: View {
    @State private var selectedGoal = "General Fitness"

    let goals = ["Weight Loss", "Muscle Gain", "General Fitness"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("FitFlow")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Choose a goal and keep your flow going.")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                Picker("Fitness Goal", selection: $selectedGoal) {
                    ForEach(goals, id: \.self) { goal in
                        Text(goal)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                List {
                    Section("Suggested Workouts") {
                        ForEach(WorkoutSuggestionEngine.suggestions(for: selectedGoal), id: \.self) { suggestion in
                            HStack {
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(.green)

                                Text(suggestion)
                                    .fontWeight(.medium)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Your Flow")
        }
    }
}
