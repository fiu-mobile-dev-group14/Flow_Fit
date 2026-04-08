//
//  EditProfileSheet.swift
//  FlowFit
//
//  Created by Javier Gil on 4/8/26.
//

import SwiftUI

struct EditProfileSheet: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss

    @State private var selectedGoal: FitnessGoal = .maintain
    @State private var selectedExperience: ExperienceLevel = .beginner

    var body: some View {
        NavigationStack {
            Form {
                Section("Fitness Goal") {
                    Picker("Goal", selection: $selectedGoal) {
                        ForEach(FitnessGoal.allCases) { goal in
                            Text(goal.rawValue).tag(goal)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Experience Level") {
                    Picker("Experience", selection: $selectedExperience) {
                        ForEach(ExperienceLevel.allCases) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        appState.currentUser?.goal = selectedGoal
                        appState.currentUser?.experienceLevel = selectedExperience
                        if let uid = appState.currentUser?.uid {
                            Task {
                                try? await FirestoreService.shared.updateUserProfile(
                                    uid: uid,
                                    goal: selectedGoal,
                                    experience: selectedExperience
                                )
                            }
                        }
                        dismiss()
                    }
                    .bold()
                }
            }
            .onAppear {
                selectedGoal = appState.currentUser?.goal ?? .maintain
                selectedExperience = appState.currentUser?.experienceLevel ?? .beginner
            }
        }
    }
}
