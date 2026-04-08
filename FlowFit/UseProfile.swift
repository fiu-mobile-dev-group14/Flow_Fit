import SwiftUI

struct ContentView: View {
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
                Text("John Doe")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("20")
                    .foregroundColor(.gray)
                // Username
                Text("flowfit user ")
                    .foregroundColor(.gray)
                
                // Bio
                Text("Staying active and reaching goals with FlowFit.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                // Stats
                HStack(spacing: 30) {
                    VStack {
                        Text("2 hr 30 m")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("total time")
                        Image(systemName: "clock.fill")
                            .foregroundColor(.gray)
                    }
                    
                    VStack {
                        Text("1,000")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Calories")
                        Image(systemName: "flame.fill")
                            .foregroundColor(.gray)
                    }
                    
                    VStack {
                        Text("8")
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
                        print("Edit Profile tapped")
                    }) {
                        Text("Edit Profile")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        print("Settings tapped")
                    }) {
                        Text("Settings")
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
    }
}

#Preview {
    ContentView()
    
}

import SwiftUI

@main
struct FlowFitApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
