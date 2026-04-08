//
//  LoginView.swift
//  FlowFit
//
//  Created by Javier Gil on 4/8/26.
//

import SwiftUI
 
struct LoginView: View {
 
    @Environment(AppState.self) var appState

    @State private var isSignUp = false

    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var selectedGoal: FitnessGoal = .maintain
    @State private var selectedExperience: ExperienceLevel = .beginner
 
    // UI state
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
 
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
 
                    // MARK: - Logo / Header
                    VStack(spacing: 8) {
                        Image(systemName: "figure.run.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.blue)
                        Text("FlowFit")
                            .font(.largeTitle).bold()
                        Text(isSignUp ? "Create your account" : "Welcome back")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
 
                    // MARK: - Form
                    VStack(spacing: 14) {
                        if isSignUp {
                            FloatingTextField(title: "Username", text: $username)
 
                            Picker("Goal", selection: $selectedGoal) {
                                ForEach(FitnessGoal.allCases) { goal in
                                    Text(goal.rawValue).tag(goal)
                                }
                            }
                            .pickerStyle(.segmented)
 
                            Picker("Experience", selection: $selectedExperience) {
                                ForEach(ExperienceLevel.allCases) { level in
                                    Text(level.rawValue).tag(level)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
 
                        FloatingTextField(title: "Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
 
                        FloatingTextField(title: "Password", text: $password, isSecure: true)
                    }
                    .padding(.horizontal, 24)
 
                    // MARK: - Error Message
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
 
                    // MARK: - Primary Button
                    Button {
                        Task { await handleSubmit() }
                    } label: {
                        ZStack {
                            Text(isSignUp ? "Create Account" : "Sign In")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .opacity(isLoading ? 0 : 1)
 
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            }
                        }
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 24)
 
                    // MARK: - Toggle Login / Sign Up
                    Button {
                        withAnimation {
                            isSignUp.toggle()
                            errorMessage = nil
                        }
                    } label: {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                    }
 
                    Spacer(minLength: 40)
                }
            }
        }
    }
 
    // MARK: - Submit Handler
    private func handleSubmit() async {
        errorMessage = nil
        isLoading = true
 
        do {
            let user: User
 
            if isSignUp {
                guard !username.trimmingCharacters(in: .whitespaces).isEmpty else {
                    errorMessage = "Please enter a username."
                    isLoading = false
                    return
                }
                user = try await AuthService.shared.signUp(
                    email: email,
                    password: password,
                    username: username,
                    goal: selectedGoal,
                    experience: selectedExperience
                )
            } else {
                user = try await AuthService.shared.signIn(
                    email: email,
                    password: password
                )
            }

            await appState.loadUserData(user: user)
 
        } catch {
            errorMessage = error.localizedDescription
        }
 
        isLoading = false
    }
}
 
// MARK: - Floating Text Field
struct FloatingTextField: View {
    let title: String
    @Binding var text: String
    var isSecure: Bool = false
 
    var body: some View {
        Group {
            if isSecure {
                SecureField(title, text: $text)
            } else {
                TextField(title, text: $text)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
 
#Preview {
    LoginView()
        .environment(AppState())
}
