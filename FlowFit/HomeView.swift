//
//  HomeView.swift
//  FlowFit
//
//  Created by Javier Gil on 4/5/26.
//

import SwiftUI

struct HomeView: View {
 
    @Environment(AppState.self) var appState
    @EnvironmentObject var workoutStore: WorkoutStore
    @Binding var selectedTab: Int

    @State private var showingSuggestions = false
 
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
 
                    // 1. Greeting header
                    GreetingHeaderView()
 
                    // 2. Today's summary cards
                    TodaySummarySection()
 
                    // 3. Quick action buttons
                    QuickActionsSection(showingSuggestions: $showingSuggestions, selectedTab: $selectedTab)
 
                    // 4. AI Recommendations preview
                    RecommendationsPreviewSection(showingSuggestions: $showingSuggestions)
 
                    // 5. Streak badge
                    StreakSection()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .navigationTitle("FlowFit")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingSuggestions) {
                // Sheet has the suggestions slide up on the current view.
                // Can be changed to a separate view later depending on what we want.
                SuggestionsSheetView()
            }
        }
    }
}
 
// MARK: - Greeting Header
struct GreetingHeaderView: View {
    @Environment(AppState.self) var appState
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        default:      return "Good evening"
        }
    }
 
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(greeting), \(appState.currentUser?.username ?? "Athlete") 👋")
                .font(.title2).bold()
            Text("Goal: \(appState.currentUser?.goal.rawValue ?? "—")")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }
}
 
// MARK: - Today's Summary
struct TodaySummarySection: View {
    @Environment(AppState.self) var appState
    @EnvironmentObject var workoutStore: WorkoutStore
 
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Summary")
                .font(.headline)
 
            HStack(spacing: 12) {
                SummaryCard(
                    title: "Calories",
                    value: "\(appState.totalCaloriesToday)",
                    unit: "kcal",
                    icon: "flame.fill",
                    color: .orange
                )
                SummaryCard(
                    title: "Workouts",
                    value: "\(appState.totalWorkoutsToday)",
                    unit: "logged",
                    icon: "dumbbell.fill",
                    color: .blue
                )
            }
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
 
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)   
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
 
// MARK: - Quick Actions
struct QuickActionsSection: View {
    @Binding var showingSuggestions: Bool
    @Binding var selectedTab: Int
 
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
 
            HStack(spacing: 12) {
                QuickActionButton(title: "Log Meal", icon: "plus.circle.fill", color: .green) {
                    // TODO: navigate to Nutrition.
                    print("Navigate to log meal")
                }
                QuickActionButton(title: "Log Workout", icon: "plus.circle.fill", color: .blue) {
                    selectedTab = 2
                }
                QuickActionButton(title: "Get Ideas", icon: "sparkles", color: .purple) {
                    showingSuggestions = true
                }
            }
        }
    }
}
 
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
 
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
 
// MARK: - Recommendations Preview
struct RecommendationsPreviewSection: View {
    @Environment(AppState.self) var appState
    @Binding var showingSuggestions: Bool
 
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("AI Recommendations")
                    .font(.headline)
                Spacer()
                Button("See All") { showingSuggestions = true }
                    .font(.subheadline)
            }
 
            if appState.isFetchingSuggestions {
                HStack {
                    ProgressView()
                    Text("Getting personalized suggestions…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
 
            } else if appState.mealSuggestions.isEmpty && appState.workoutSuggestions.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.title)
                        .foregroundStyle(.purple)
                    Text("Tap \"Get Ideas\" to get AI-powered meal and workout suggestions tailored to your goal.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
 
            } else {
                VStack(spacing: 8) {
                    if let meal = appState.mealSuggestions.first {
                        SuggestionPreviewRow(icon: "fork.knife", color: .green, text: meal.name)
                    }
                    if let workout = appState.workoutSuggestions.first {
                        SuggestionPreviewRow(icon: "dumbbell.fill", color: .blue, text: workout.name)
                    }
                }
                .padding(12)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
}
 
struct SuggestionPreviewRow: View {
    let icon: String
    let color: Color
    let text: String
 
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}
 
// MARK: - Streak Section
struct StreakSection: View {
    @Environment(AppState.self) var appState
 
    var body: some View {
        HStack(spacing: 12) {
            Text("🔥")
                .font(.system(size: 32))
            VStack(alignment: .leading, spacing: 2) {
                Text("\(appState.currentStreak)-day streak")
                    .font(.headline)
                Text("Keep it going!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
 
// MARK: - Suggestions Sheet
struct SuggestionsSheetView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
 
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
 
                    if appState.isFetchingSuggestions {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.4)
                            Text("Getting your personalized plan…")
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
 
                    } else {
 
                        // Meal Suggestions
                        if !appState.mealSuggestions.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Label("Meal Ideas", systemImage: "fork.knife")
                                    .font(.headline)
                                ForEach(appState.mealSuggestions) { meal in
                                    SuggestionCard(
                                        title: meal.name,
                                        subtitle: "\(meal.estimatedCalories) kcal",
                                        detail: meal.description,
                                        color: .green
                                    )
                                }
                            }
                        }
 
                        // Workout Suggestions
                        if !appState.workoutSuggestions.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Label("Workout Ideas", systemImage: "dumbbell.fill")
                                    .font(.headline)
                                ForEach(appState.workoutSuggestions) { workout in
                                    SuggestionCard(
                                        title: workout.name,
                                        subtitle: "\(workout.difficulty) · \(workout.focus)",
                                        detail: workout.description,
                                        color: .blue
                                    )
                                }
                            }
                        }
 
                        // Refresh button
                        Button {
                            Task {
                                await RecommendationsService.shared.fetchSuggestions(for: appState)
                            }
                        } label: {
                            Label("Refresh Suggestions", systemImage: "arrow.clockwise")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .padding(.top, 8)
                    }
                }
                .padding(16)
            }
            .navigationTitle("Your Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                if appState.mealSuggestions.isEmpty {
                    await RecommendationsService.shared.fetchSuggestions(for: appState)
                }
            }
        }
    }
}
 
struct SuggestionCard: View {
    let title: String
    let subtitle: String
    let detail: String
    let color: Color
 
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline).bold()
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(color)
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
 

#Preview {
    HomeView(selectedTab: .constant(0))
        .environment(AppState())
        .environmentObject(WorkoutStore())
}
