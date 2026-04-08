//
//  WorkoutEntry.swift
//  FitFlow
//
//  Created by Walter Cuadra on 4/6/26.
//

import Foundation

struct WorkoutEntry: Identifiable, Codable {
    let id: UUID
    var exerciseName: String
    var sets: Int
    var reps: Int
    var weight: Double
    var duration: Int
    var notes: String
    var date: Date

    init(
        id: UUID = UUID(),
        exerciseName: String,
        sets: Int = 0,
        reps: Int = 0,
        weight: Double = 0,
        duration: Int = 0,
        notes: String = "",
        date: Date = Date()
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.duration = duration
        self.notes = notes
        self.date = date
    }
}
