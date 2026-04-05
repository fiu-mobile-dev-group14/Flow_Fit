//
//  RecommendationsService.swift
//  FlowFit
//
//  Created by Javier Gil on 4/5/26.
//

import Foundation

actor RecommendationsService {
 
    static let shared = RecommendationsService()
    
    private init() {}
 
    // Replace with actual Anthropic API key.
    // Visit console.anthropic.com → API Keys to get one (free tier available).
    private let apiKey = "YOUR_ANTHROPIC_API_KEY_HERE"
    private let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!
 
    // MARK: - Main Entry Point
    func fetchSuggestions(for appState: AppState) async {
        guard let user = await appState.currentUser else { return }
 
        await MainActor.run { appState.isFetchingSuggestions = true }
 
        do {
            let (meals, workouts) = try await fetchFromClaude(user: user)
            await MainActor.run {
                appState.mealSuggestions = meals
                appState.workoutSuggestions = workouts
                appState.isFetchingSuggestions = false
            }
        } catch {
            print("RecommendationsService error: \(error)")
            await MainActor.run { appState.isFetchingSuggestions = false }
        }
    }
 
    // MARK: - Claude API Call
    private func fetchFromClaude(user: User) async throws -> ([MealSuggestion], [WorkoutSuggestion]) {
 
        let prompt = """
            You are a fitness and nutrition assistant. A user has the following profile:
            - Goal: \(user.goal.promptDescription)
            - Experience level: \(user.experienceLevel.rawValue)
        
            Return ONLY a valid JSON object with no extra text, markdown, or explanation.
            Use this exact structure:
            {
              "meals": [
                {
                  "name": "Meal name",
                  "estimatedCalories": 500,
                  "description": "One sentence description.",
                  "goalType": "\(user.goal.rawValue)"
                }
              ],
              "workouts": [
                {
                  "name": "Workout name",
                  "difficulty": "\(user.experienceLevel.rawValue)",
                  "focus": "full body",
                  "description": "One sentence description."
                }
              ]
            }
        
            Provide 3 meals and 3 workouts. Nothing else — only the JSON.
        """
 
        // HTTP request
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
 
        // Model
        let body: [String: Any] = [
            "model": "claude-haiku-4-5-20251001",
            "max_tokens": 1024,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
 
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
 
        let (data, response) = try await URLSession.shared.data(for: request)
 
        // Validate HTTP status
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ServiceError.badResponse
        }
 
        return try parseClaudeResponse(data: data, user: user)
    }
 
    // MARK: - Response Parsing
    private func parseClaudeResponse(data: Data, user: User) throws -> ([MealSuggestion], [WorkoutSuggestion]) {
 
        let envelope = try JSONDecoder().decode(ClaudeEnvelope.self, from: data)

        guard let textContent = envelope.content.first?.text,
              let jsonData = textContent.data(using: .utf8) else {
            throw ServiceError.noContent
        }

        let suggestions = try JSONDecoder().decode(SuggestionsResponse.self, from: jsonData)

        let meals = suggestions.meals.map { raw in
            MealSuggestion(name: raw.name,
                           estimatedCalories: raw.estimatedCalories,
                           description: raw.description,
                           goalType: raw.goalType)
        }
 
        let workouts = suggestions.workouts.map { raw in
            WorkoutSuggestion(name: raw.name,
                              difficulty: raw.difficulty,
                              focus: raw.focus,
                              description: raw.description)
        }
 
        return (meals, workouts)
    }
 
    // MARK: - Codable Models
    private struct ClaudeEnvelope: Codable {
        let content: [ContentBlock]
        struct ContentBlock: Codable {
            let type: String
            let text: String?
        }
    }
 
    private struct SuggestionsResponse: Codable {
        let meals: [RawMeal]
        let workouts: [RawWorkout]
    }
 
    private struct RawMeal: Codable {
        let name: String
        let estimatedCalories: Int
        let description: String
        let goalType: String
    }
 
    private struct RawWorkout: Codable {
        let name: String
        let difficulty: String
        let focus: String
        let description: String
    }
 
    // MARK: - Errors 
    enum ServiceError: Error, LocalizedError {
        case badResponse
        case noContent
        case parseFailure
 
        var errorDescription: String? {
            switch self {
            case .badResponse:   return "The server returned an unexpected response."
            case .noContent:     return "No content was returned from the AI."
            case .parseFailure:  return "Could not parse the AI response."
            }
        }
    }
}
