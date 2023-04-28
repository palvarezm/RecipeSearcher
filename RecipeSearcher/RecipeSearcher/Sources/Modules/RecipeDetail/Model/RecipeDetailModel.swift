//
//  RecipeDetailModel.swift
//  RecipeSearcher
//
//  Created by Paul Alvarez on 26/04/23.
//

typealias Coordinates = (Double,Double)
struct RecipeDetailModel {
    let id: Int
    let imageURL: String
    let name: String
    let ingredients: [String]
    let steps: [String]
    let mapCoordinates: Coordinates

    init(from response: RecipeDetailResponse) {
        self.id = response.id
        self.imageURL = response.imageURL
        self.name = response.name
        self.ingredients = response.ingredients.map { "\($0.name) (\($0.quantity)) [\($0.type.rawValue)]" }
        self.steps = response.steps
        self.mapCoordinates = (response.location.latitude, response.location.longitude)
    }
}
