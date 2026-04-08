//
//  FlowFitApp.swift
//  FlowFit
//
//  Created by Vincent  on 4/1/26.
//

import SwiftUI

@main
struct FlowFitApp: App {
    
    @State private var appState: AppState
    @StateObject private var workoutStore = WorkoutStore()
    
    init() {
        // FirebaseApp.configure()
        appState = AppState()
    }
    
    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                ContentView()
                    .environment(appState)
                    .environmentObject(workoutStore)
            } else {
                /*
                 LoginView()
                    .environment(appState)
                 */
                LoginPlaceholderView()
                //Place holder for the login view to be default if no user is logged in
            }
        }
    }
}

struct LoginPlaceholderView: View {
    @Environment(AppState.self) var appState
    var body: some View {
        VStack(spacing: 20) {
            Text("FlowFit")
                .font(.largeTitle).bold()
            Text("Login screen — coming soon")
                .foregroundStyle(.secondary)
            // Temp login button so you can test the dashboard without a real login flow
            Button("Sign In (Demo)") {
                appState.currentUser = User(username: "Demo User", goal: .cut, experienceLevel: .beginner)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
