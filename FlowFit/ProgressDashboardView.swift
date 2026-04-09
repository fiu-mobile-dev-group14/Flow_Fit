//
//  ProgressView.swift
//  FlowFit
//
//  Created by Javier Gil on 4/8/26.
//

import SwiftUI
import Charts
 
struct ProgressDashboardView: View {
    @Environment(AppState.self) var appState
    @EnvironmentObject var workoutStore: WorkoutStore
 
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
 
                    // 1. Summary Stats
                    StatsSection()
 
                    // 2. Charts
                    WorkoutsThisWeekChart()
                    CaloriesThisWeekChart()
 
                    // 3. Full workout history
                    WorkoutHistorySection()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
 
// MARK: - Stats Section
struct StatsSection: View {
    @Environment(AppState.self) var appState
    @EnvironmentObject var workoutStore: WorkoutStore
 
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Stats")
                .font(.headline)
 
            HStack(spacing: 12) {
                ProgressStatCard(
                    title: "Current Streak",
                    value: "\(appState.currentStreak)",
                    unit: "days",
                    icon: "flame.fill",
                    color: .orange
                )
                ProgressStatCard(
                    title: "Total Workouts",
                    value: "\(workoutStore.totalWorkouts)",
                    unit: "logged",
                    icon: "dumbbell.fill",
                    color: .blue
                )
            }
 
            HStack(spacing: 12) {
                ProgressStatCard(
                    title: "Calories Today",
                    value: "\(appState.totalCaloriesToday)",
                    unit: "kcal",
                    icon: "fork.knife",
                    color: .green
                )
                ProgressStatCard(
                    title: "Active Time",
                    value: "\(workoutStore.totalMinutes)",
                    unit: "min total",
                    icon: "clock.fill",
                    color: .purple
                )
            }
        }
    }
}
 
struct ProgressStatCard: View {
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
                .font(.system(size: 28, weight: .bold, design: .rounded))
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
 
// MARK: - Workouts This Week Chart
struct WorkoutsThisWeekChart: View {
    @EnvironmentObject var workoutStore: WorkoutStore
 
    private var weekData: [DayData] {
        let calendar = Calendar.current
        let today = Date()
 
        return (0..<7).reversed().map { daysAgo -> DayData in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
 
            let count = workoutStore.workoutEntries.filter {
                $0.date >= startOfDay && $0.date < endOfDay
            }.count
 
            let label = date.formatted(.dateTime.weekday(.abbreviated))
 
            return DayData(day: label, count: count)
        }
    }
 
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Workouts This Week")
                .font(.headline)
 
            Chart(weekData) { item in
                BarMark(
                    x: .value("Day", item.day),
                    y: .value("Workouts", item.count)
                )
                .foregroundStyle(.blue.gradient)
                .cornerRadius(6)
            }
            .frame(height: 180)
            .padding(16)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
 
            if weekData.allSatisfy({ $0.count == 0 }) {
                Text("No workouts logged this week yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
            }
        }
    }
 
     struct DayData: Identifiable {
        let id = UUID()
        let day: String
        let count: Int
    }
}
 
// MARK: - Calories This Week Chart
struct CaloriesThisWeekChart: View {
    @Environment(AppState.self) var appState
 
    private var weekData: [DayData] {
        let calendar = Calendar.current
        let today = Date()
 
        return (0..<7).reversed().map { daysAgo -> DayData in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
 
            let calories = appState.allMeals.filter {
                $0.date >= startOfDay && $0.date < endOfDay
            }.reduce(0) { $0 + $1.calories }
 
            let label = date.formatted(.dateTime.weekday(.abbreviated))
            return DayData(day: label, calories: calories)
        }
    }
 
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Calories This Week")
                .font(.headline)
 
            Chart(weekData) { item in
                LineMark(
                    x: .value("Day", item.day),
                    y: .value("Calories", item.calories)
                )
                .foregroundStyle(.orange.gradient)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
 
                AreaMark(
                    x: .value("Day", item.day),
                    y: .value("Calories", item.calories)
                )
                .foregroundStyle(.orange.opacity(0.15))
 
                PointMark(
                    x: .value("Day", item.day),
                    y: .value("Calories", item.calories)
                )
                .foregroundStyle(.orange)
            }
            .frame(height: 180)
            .padding(16)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
 
            if weekData.allSatisfy({ $0.calories == 0 }) {
                Text("No meals logged this week yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
            }
        }
    }
 
    struct DayData: Identifiable {
        let id = UUID()
        let day: String
        let calories: Int
    }
}
 
// MARK: - Workout History Section
struct WorkoutHistorySection: View {
    @EnvironmentObject var workoutStore: WorkoutStore
 
    private var sortedWorkouts: [WorkoutEntry] {
        workoutStore.workoutEntries.sorted { $0.date > $1.date }
    }
 
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Workout History")
                .font(.headline)
 
            if sortedWorkouts.isEmpty {
                // Empty state
                VStack(spacing: 8) {
                    Image(systemName: "dumbbell.fill")
                        .font(.title)
                        .foregroundStyle(.secondary)
                    Text("No workouts logged yet. Get started!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
 
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(sortedWorkouts) { workout in
                        WorkoutHistoryRow(workout: workout)
                    }
                }
            }
        }
    }
}
 
struct WorkoutHistoryRow: View {
    let workout: WorkoutEntry
 
    private var formattedDate: String {
        workout.date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }
 
    private var detailString: String {
        if workout.duration > 0 {
            return "\(workout.duration) min"
        } else if workout.sets > 0 {
            if workout.weight > 0 {
                return "\(workout.sets) sets × \(workout.reps) reps @ \(Int(workout.weight)) lbs"
            } else {
                return "\(workout.sets) sets × \(workout.reps) reps"
            }
        }
        return ""
    }
 
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "dumbbell.fill")
                .foregroundStyle(.blue)
                .frame(width: 32)
 
            VStack(alignment: .leading, spacing: 3) {
                Text(workout.exerciseName)
                    .font(.subheadline).bold()
                if !detailString.isEmpty {
                    Text(detailString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let notes = workout.notes as String?, !notes.isEmpty {
                    Text(notes)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }
 
            Spacer()
 
            Text(formattedDate)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
 
#Preview {
    ProgressDashboardView()
        .environment(AppState())
        .environmentObject(WorkoutStore())
}
