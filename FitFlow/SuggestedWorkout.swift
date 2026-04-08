//
//  SuggestedWorkout.swift
//  FitFlow
//
//  Created by Walter Cuadra on 4/6/26.
//

import Foundation

struct SuggestedWorkout: Identifiable, Codable {
    let id: UUID
    var name: String
    var difficulty: String
    var focus: String
    var description: String
    var imageName: String

    init(
        id: UUID = UUID(),
        name: String,
        difficulty: String,
        focus: String,
        description: String,
        imageName: String
    ) {
        self.id = id
        self.name = name
        self.difficulty = difficulty
        self.focus = focus
        self.description = description
        self.imageName = imageName
    }
}
