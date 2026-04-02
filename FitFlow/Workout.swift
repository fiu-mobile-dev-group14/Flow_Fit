//
//  Workout.swift
//  FitFlow
//
//  Created by Walter Cuadra on 4/1/26.
//

import Foundation

struct Workout: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: String
    var duration: Int
    var caloriesBurned: Int
    var date: Date

    init(
        id: UUID = UUID(),
        name: String,
        category: String,
        duration: Int,
        caloriesBurned: Int,
        date: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.duration = duration
        self.caloriesBurned = caloriesBurned
        self.date = date
    }
}
