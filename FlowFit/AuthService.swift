//
//  AuthService.swift
//  FlowFit
//
//  Created by Javier Gil on 4/8/26.
//

import Foundation
import FirebaseAuth
 
class AuthService {
 
    static let shared = AuthService()
    private init() {}
 
    // MARK: - Sign Up
    func signUp(email: String, password: String, username: String,
                goal: FitnessGoal, experience: ExperienceLevel) async throws -> User {
 
        let result = try await Auth.auth().createUser(withEmail: email, password: password)

        let newUser = User(
            uid: result.user.uid,
            username: username,
            email: email,
            goal: goal,
            experienceLevel: experience
        )
        try await FirestoreService.shared.createUserProfile(newUser)
 
        return newUser
    }
 
    // MARK: - Sign In
    func signIn(email: String, password: String) async throws -> User {
 
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
 
        let user = try await FirestoreService.shared.fetchUserProfile(uid: result.user.uid)
 
        return user
    }
 
    // MARK: - Sign Out
    func signOut() throws {
        try Auth.auth().signOut()
    }
 
    // MARK: - Restore Session
    func restoreSession() async -> User? {
        guard let firebaseUser = Auth.auth().currentUser else { return nil }
 
        return try? await FirestoreService.shared.fetchUserProfile(uid: firebaseUser.uid)
    }
}
