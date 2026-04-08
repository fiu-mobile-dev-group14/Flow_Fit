//
//  SuggestionsCache.swift
//  FlowFit
//
//  Created by Javier Gil on 4/7/26.
//

import Foundation
 
actor SuggestionsCache {
 
    static let shared = SuggestionsCache()
    private init() {}
 
    private let staleDuration: TimeInterval = 60 * 60 * 24  // 24 hours in seconds
 
    // MARK: - File URLs
    private var mealsFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("cached_meals.json")
    }
 
    private var workoutsFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("cached_workouts.json")
    }
 
    private var metadataFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("suggestions_metadata.json")
    }
 
    // MARK: - Save
    func save(meals: [MealSuggestion], workouts: [WorkoutSuggestion]) async {
        do {
            let mealsData = try JSONEncoder().encode(meals)
            let workoutsData = try JSONEncoder().encode(workouts)
 
            try mealsData.write(to: mealsFileURL)
            try workoutsData.write(to: workoutsFileURL)
 
            let metadata = CacheMetadata(lastFetch: Date())
            let metadataData = try JSONEncoder().encode(metadata)
            try metadataData.write(to: metadataFileURL)
 
        } catch {
            print("SuggestionsCache save error: \(error)")
        }
    }
 
    // MARK: - Load
    func load() async -> (meals: [MealSuggestion], workouts: [WorkoutSuggestion]) {
        do {
            let mealsData = try Data(contentsOf: mealsFileURL)
            let workoutsData = try Data(contentsOf: workoutsFileURL)
 
            let meals = try JSONDecoder().decode([MealSuggestion].self, from: mealsData)
            let workouts = try JSONDecoder().decode([WorkoutSuggestion].self, from: workoutsData)
 
            return (meals, workouts)
        } catch {
            return ([], [])
        }
    }
 
    // MARK: - Staleness Check
    func isStale() async -> Bool {
        guard let metadataData = try? Data(contentsOf: metadataFileURL),
              let metadata = try? JSONDecoder().decode(CacheMetadata.self, from: metadataData) else {
            return true
        }
 
        return Date().timeIntervalSince(metadata.lastFetch) > staleDuration
    }
 
    // MARK: - Clear
    func clear() async {
        try? FileManager.default.removeItem(at: mealsFileURL)
        try? FileManager.default.removeItem(at: workoutsFileURL)
        try? FileManager.default.removeItem(at: metadataFileURL)
    }
 
    // MARK: - Internal Types
 
    private struct CacheMetadata: Codable {
        let lastFetch: Date
    }
}
