//
//  FlowFitApp.swift
//  FlowFit
//
//  Created by Vincent  on 4/1/26.
//

import SwiftUI
import FirebaseCore

@main
struct FlowFitApp: App {
    
    @State private var appState: AppState
    @StateObject private var workoutStore = WorkoutStore()
    
    init() {
        FirebaseApp.configure()
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
                LoginView()
                //Place holder for the login view to be default if no user is logged in
            }
        }
    }
}
