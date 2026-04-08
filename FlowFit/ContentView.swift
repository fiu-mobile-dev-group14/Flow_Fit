//
//  ContentView.swift
//  FlowFit
//
//  Created by Vincent  on 4/1/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) var appState
    
    var body: some View {
        if appState.isLoggedIn {
            MainTabView()
        } else {
            LoginPlaceholderView()
        }
    }
}

// MARK: - Main Tab Bar
struct MainTabView: View {
    
    @Environment(AppState.self) var appState
    @EnvironmentObject var workoutStore: WorkoutStore
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }.tag(0)
 
            // NUTRITION
            NutritionView()
                .tabItem {
                    Label("Nutrition", systemImage: "fork.knife")
                }.tag(1)
 
            // WORKOUTS
            WorkoutsView(store: workoutStore)
                .tabItem { Label("Workouts", systemImage: "dumbbell.fill")
                }.tag(2)
 
            // PROGRESS
            ProgressPlaceholderView()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }.tag(3)
 
            // PROFILE
            ProfilePlaceholderView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }.tag(4)
        }
        .tint(.blue)
    }
}
 
// MARK: - Placeholder Views

struct NutritionPlaceholderView: View {
    var body: some View {
        VStack {
            Image(systemName: "fork.knife")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Nutrition — In Progress")
                .font(.title2)
                .padding(.top, 8)
        }
    }
}
 
struct WorkoutsPlaceholderView: View {
    var body: some View {
        VStack {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Workouts — In Progress")
                .font(.title2)
                .padding(.top, 8)
        }
    }
}
 
struct ProgressPlaceholderView: View {
    var body: some View {
        VStack {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Progress — In Progress")
                .font(.title2)
                .padding(.top, 8)
        }
    }
}
 
struct ProfilePlaceholderView: View {
    var body: some View {
        VStack {
            Image(systemName: "person.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Profile — In Progress")
                .font(.title2)
                .padding(.top, 8)
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
        .environmentObject(WorkoutStore())
}
