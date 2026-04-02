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
            WorkoutTrackerView(store: workoutStore)
                .tabItem {
                    Image(systemName: "figure.walk")
                    Text("Track")
                }

            WorkoutSuggestionsView()
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("Flow")
                }
        }
        .tint(.blue)
    }
}
