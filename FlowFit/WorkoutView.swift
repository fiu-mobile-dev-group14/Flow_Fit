//
//  WorkoutView.swift
//  FitFlow
//
//  Created by Walter Cuadra on 4/6/26.
//

import SwiftUI

struct WorkoutsView: View {
    @Environment(AppState.self) var appState
    @ObservedObject var store: WorkoutStore

    @State private var exerciseName = ""
    @State private var sets = ""
    @State private var reps = ""
    @State private var weight = ""
    @State private var duration = ""
    @State private var notes = ""
    @State private var selectedExperience = "Beginner"
    @State private var showValidationMessage = false

    let experiences = ["Beginner", "Intermediate", "Advanced"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerSection
                    statsSection
                    logWorkoutSection
                    suggestedWorkoutsSection
                    todaysEntriesSection
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("FlowFit Workouts")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Log your workouts, track activity, and explore suggested routines.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            statCard(
                title: "Total Workouts",
                value: "\(store.totalWorkouts)",
                icon: "figure.strengthtraining.traditional"
            )

            statCard(
                title: "Cardio Minutes",
                value: "\(store.totalMinutes)",
                icon: "clock"
            )
        }
    }

    private func statCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    private var logWorkoutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Log Workout")

            VStack(spacing: 12) {
                Group {
                    TextField("Exercise name", text: $exerciseName)
                        .styledInput()

                    HStack(spacing: 12) {
                        TextField("Sets", text: $sets)
                            .keyboardType(.numberPad)
                            .styledInput()

                        TextField("Reps", text: $reps)
                            .keyboardType(.numberPad)
                            .styledInput()
                    }

                    HStack(spacing: 12) {
                        TextField("Weight", text: $weight)
                            .keyboardType(.decimalPad)
                            .styledInput()

                        TextField("Duration (min)", text: $duration)
                            .keyboardType(.numberPad)
                            .styledInput()
                    }

                    TextField("Notes", text: $notes)
                        .styledInput()
                }

                if showValidationMessage {
                    Text("Please enter an exercise name before saving.")
                        .font(.caption)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(action: saveWorkout) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Save Workout")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(18)
    }

    private var suggestedWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("AI Suggested Workouts")

            if appState.isFetchingSuggestions {
                HStack {
                    ProgressView()
                    Text("Getting personalized suggestions…")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(14)

            } else if appState.workoutSuggestions.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.title)
                        .foregroundColor(.blue)
                    Text("Go to Home and tap \"Get Ideas\" to get AI workout suggestions.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(14)

            } else {
                ForEach(appState.workoutSuggestions) { suggestion in
                    let workout = SuggestedWorkout(
                        name: suggestion.name,
                        difficulty: suggestion.difficulty,
                        focus: suggestion.focus,
                        description: suggestion.description
                    )
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(suggestion.name)
                                    .font(.headline)
                                Spacer()
                                Text(suggestion.difficulty)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.12))
                                    .foregroundColor(.blue)
                                    .cornerRadius(10)
                            }
                            Text(suggestion.focus)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(suggestion.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(14)
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    Task {
                        await RecommendationsService.shared.fetchSuggestions(for: appState)
                    }
                } label: {
                    Label("Refresh Suggestions", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(14)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var todaysEntriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Today’s Workout Entries")

            if store.workoutEntries.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)

                    Text("No workouts logged yet")
                        .font(.headline)

                    Text("Add your first workout above to start tracking your progress.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(18)
            } else {
                ForEach(store.workoutEntries) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(entry.exerciseName)
                                .font(.headline)

                            Spacer()

                            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                        HStack(spacing: 12) {
                            detailPill(text: "Sets \(entry.sets)")
                            detailPill(text: "Reps \(entry.reps)")
                            detailPill(text: String(format: "Wt %.1f", entry.weight))
                            detailPill(text: "\(entry.duration) min")
                        }

                        if !entry.notes.isEmpty {
                            Text(entry.notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .swipeActions {
                        Button(role: .destructive) {
                            delete(entry)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }

    private func detailPill(text: String) -> some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.systemGray5))
            .cornerRadius(10)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func saveWorkout() {
        let trimmedName = exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            showValidationMessage = true
            return
        }

        showValidationMessage = false

        let setsValue = Int(sets) ?? 0
        let repsValue = Int(reps) ?? 0
        let weightValue = Double(weight) ?? 0
        let durationValue = Int(duration) ?? 0

        store.addWorkout(
            exerciseName: trimmedName,
            sets: setsValue,
            reps: repsValue,
            weight: weightValue,
            duration: durationValue,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        exerciseName = ""
        sets = ""
        reps = ""
        weight = ""
        duration = ""
        notes = ""
    }

    private func delete(_ entry: WorkoutEntry) {
        if let index = store.workoutEntries.firstIndex(where: { $0.id == entry.id }) {
            store.workoutEntries.remove(at: index)
        }
    }
}

private extension View {
    func styledInput() -> some View {
        self
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}
