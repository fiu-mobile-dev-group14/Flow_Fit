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
        
    }
}

// MARK: - Main Tab Bar
struct MainTabView: View {
    var body: some View {
        TabView {
            // Dashboard
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
 
            // NUTRITION
            NutritionPlaceholderView()
                .tabItem {
                    Label("Nutrition", systemImage: "fork.knife")
                }
 
            // WORKOUTS
            WorkoutsPlaceholderView()
                .tabItem {
                    Label("Workouts", systemImage: "dumbbell.fill")
                }
 
            // PROGRESS
            ProgressPlaceholderView()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
 
            // PROFILE
            ProfilePlaceholderView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
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
}
