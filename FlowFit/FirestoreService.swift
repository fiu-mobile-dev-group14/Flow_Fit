//
//  FirestoreService.swift
//  FlowFit
//
//  Created by Javier Gil on 4/8/26.
//

import Foundation
import FirebaseFirestore
 
class FirestoreService {
 
    static let shared = FirestoreService()
    private init() {}
 
    private let db = Firestore.firestore()
 
    // MARK: - User Profile
    func createUserProfile(_ user: User) async throws {
        try await db.collection("users").document(user.uid).setData([
            "uid": user.uid,
            "username": user.username,
            "email": user.email,
            "goal": user.goal.rawValue,
            "experienceLevel": user.experienceLevel.rawValue
        ])
    }
 
    func fetchUserProfile(uid: String) async throws -> User {
        let doc = try await db.collection("users").document(uid).getDocument()
 
        guard let data = doc.data() else {
            throw FirestoreError.documentNotFound
        }
 
        guard
            let username = data["username"] as? String,
            let email = data["email"] as? String,
            let goalRaw = data["goal"] as? String,
            let goal = FitnessGoal(rawValue: goalRaw),
            let expRaw = data["experienceLevel"] as? String,
            let experience = ExperienceLevel(rawValue: expRaw)
        else {
            throw FirestoreError.decodingFailed
        }
 
        return User(uid: uid, username: username, email: email,
                    goal: goal, experienceLevel: experience)
    }
 
    func updateUserProfile(uid: String, goal: FitnessGoal, experience: ExperienceLevel) async throws {
        try await db.collection("users").document(uid).updateData([
            "goal": goal.rawValue,
            "experienceLevel": experience.rawValue
        ])
    }
 
    // MARK: - Meal Entries
    func saveMealEntry(_ meal: MealEntry, uid: String) async throws {
        try await db.collection("users").document(uid)
            .collection("mealEntries").document(meal.id.uuidString)
            .setData([
                "id": meal.id.uuidString,
                "name": meal.name,
                "calories": meal.calories,
                "notes": meal.notes,
                "date": Timestamp(date: meal.date),
                "goal": meal.goal
            ])
    }
 
    func fetchTodayMeals(uid: String) async throws -> [MealEntry] {
        let startOfDay = Calendar.current.startOfDay(for: Date())
 
        let snapshot = try await db.collection("users").document(uid)
            .collection("mealEntries")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .order(by: "date", descending: false)
            .getDocuments()
 
        return snapshot.documents.compactMap { doc -> MealEntry? in
            let data = doc.data()
            guard
                let idString = data["id"] as? String,
                let id = UUID(uuidString: idString),
                let name = data["name"] as? String,
                let calories = data["calories"] as? Int,
                let timestamp = data["date"] as? Timestamp
            else { return nil }
 
            return MealEntry(
                id: id,
                name: name,
                calories: calories,
                notes: data["notes"] as? String ?? "",
                date: timestamp.dateValue(),
                goal: data["goal"] as? String ?? ""
            )
        }
    }
 
    func deleteMealEntry(mealID: UUID, uid: String) async throws {
        try await db.collection("users").document(uid)
            .collection("mealEntries").document(mealID.uuidString)
            .delete()
    }
 
    // MARK: - Workout Entries
    func saveWorkoutEntry(_ workout: WorkoutEntry, uid: String) async throws {
        try await db.collection("users").document(uid)
            .collection("workoutEntries").document(workout.id.uuidString)
            .setData([
                "id": workout.id.uuidString,
                "exerciseName": workout.exerciseName,
                "sets": workout.sets,
                "reps": workout.reps,
                "weight": workout.weight,
                "duration": workout.duration,
                "notes": workout.notes,
                "date": Timestamp(date: workout.date)
            ])
    }
 
    func fetchTodayWorkouts(uid: String) async throws -> [WorkoutEntry] {
        let startOfDay = Calendar.current.startOfDay(for: Date())
 
        let snapshot = try await db.collection("users").document(uid)
            .collection("workoutEntries")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .order(by: "date", descending: false)
            .getDocuments()
 
        return snapshot.documents.compactMap { doc -> WorkoutEntry? in
            let data = doc.data()
            guard
                let idString = data["id"] as? String,
                let id = UUID(uuidString: idString),
                let exerciseName = data["exerciseName"] as? String
            else { return nil }
 
            return WorkoutEntry(
                id: id,
                exerciseName: exerciseName,
                sets: data["sets"] as? Int ?? 0,
                reps: data["reps"] as? Int ?? 0,
                weight: data["weight"] as? Double ?? 0,
                duration: data["duration"] as? Int ?? 0,
                notes: data["notes"] as? String ?? "",
                date: (data["date"] as? Timestamp)?.dateValue() ?? Date()
            )
        }
    }
 
    // MARK: - Historical Data (for Progress View)
    func fetchAllWorkouts(uid: String) async throws -> [WorkoutEntry] {
        let snapshot = try await db.collection("users").document(uid)
            .collection("workoutEntries")
            .order(by: "date", descending: true)
            .getDocuments()
 
        return snapshot.documents.compactMap { doc -> WorkoutEntry? in
            let data = doc.data()
            guard
                let idString = data["id"] as? String,
                let id = UUID(uuidString: idString),
                let exerciseName = data["exerciseName"] as? String
            else { return nil }
 
            return WorkoutEntry(
                id: id,
                exerciseName: exerciseName,
                sets: data["sets"] as? Int ?? 0,
                reps: data["reps"] as? Int ?? 0,
                weight: data["weight"] as? Double ?? 0,
                duration: data["duration"] as? Int ?? 0,
                notes: data["notes"] as? String ?? "",
                date: (data["date"] as? Timestamp)?.dateValue() ?? Date()
            )
        }
    }
 
    func fetchAllMeals(uid: String) async throws -> [MealEntry] {
        let snapshot = try await db.collection("users").document(uid)
            .collection("mealEntries")
            .order(by: "date", descending: true)
            .getDocuments()
 
        return snapshot.documents.compactMap { doc -> MealEntry? in
            let data = doc.data()
            guard
                let idString = data["id"] as? String,
                let id = UUID(uuidString: idString),
                let name = data["name"] as? String,
                let calories = data["calories"] as? Int,
                let timestamp = data["date"] as? Timestamp
            else { return nil }
 
            return MealEntry(
                id: id,
                name: name,
                calories: calories,
                notes: data["notes"] as? String ?? "",
                date: timestamp.dateValue(),
                goal: data["goal"] as? String ?? ""
            )
        }
    }
 
    // MARK: - Errors 
    enum FirestoreError: Error, LocalizedError {
        case documentNotFound
        case decodingFailed
 
        var errorDescription: String? {
            switch self {
            case .documentNotFound: return "User profile not found."
            case .decodingFailed:   return "Could not read user data."
            }
        }
    }
}
