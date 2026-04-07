//
//  ContentView.swift
//  FitFlow
//
//  Created by Walter Cuadra on 4/1/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var workoutStore = WorkoutStore()

    var body: some View {
        TabView {
            NavigationStack {
                Text("Home Screen")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .navigationTitle("Home")
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }

            NavigationStack {
                Text("Nutrition Screen")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .navigationTitle("Nutrition")
            }
            .tabItem {
                Image(systemName: "leaf")
                Text("Nutrition")
            }

            WorkoutsView(store: workoutStore)
                .tabItem {
                    Image(systemName: "dumbbell")
                    Text("Workouts")
                }

            NavigationStack {
                Text("Progress Screen")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .navigationTitle("Progress")
            }
            .tabItem {
                Image(systemName: "chart.bar")
                Text("Progress")
            }

            NavigationStack {
                Text("Profile Screen")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .navigationTitle("Profile")
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
        }
        .tint(.blue)
    }
}
