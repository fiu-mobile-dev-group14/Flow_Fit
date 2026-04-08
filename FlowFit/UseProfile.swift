import SwiftUI

struct UseProfile: View {
    
    @Environment(AppState.self) var appState
    @EnvironmentObject var workoutStore: WorkoutStore
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Profile Image
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.black)
                    .padding(.top, 30)
                
                // Name
                Text(appState.currentUser?.username ?? "FlowFit User")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(appState.currentUser?.experienceLevel.rawValue ?? "")
                    .foregroundColor(.gray)
                // Username
                Text(appState.currentUser?.email ?? "")
                    .foregroundColor(.gray)
                
                // Bio
                Text("Goal: \(appState.currentUser?.goal.rawValue ?? "—")")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                // Stats
                HStack(spacing: 30) {
                    VStack {
                        Text("\(workoutStore.totalMinutes) min")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("total time")
                        Image(systemName: "clock.fill")
                            .foregroundColor(.gray)
                    }
                    
                    VStack {
                        Text("\(appState.totalCaloriesToday)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Calories")
                        Image(systemName: "flame.fill")
                            .foregroundColor(.gray)
                    }
                    
                    VStack {
                        Text("\(workoutStore.totalWorkouts)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Goals")
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                Divider()
                    .padding(.horizontal)
                
                // Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        showingEditProfile = true
                    }) {
                        Text("Edit Profile")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        appState.logout()
                    }) {
                        Text("Logout")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("FlowFit Profile")
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileSheet()
                .environment(appState)
        }
        .navigationTitle("FlowFit Profile")
    }
}

#Preview {
    UseProfile()
        .environment(AppState())
        .environmentObject(WorkoutStore())
    
}
