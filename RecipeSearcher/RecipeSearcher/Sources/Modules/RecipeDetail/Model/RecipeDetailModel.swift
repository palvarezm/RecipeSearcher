//
//  RecipeDetailModel.swift
//  RecipeSearcher
//
//  Created by Paul Alvarez on 26/04/23.
//

struct RecipeDetailModel {
    let id: Int
    let imageURL: String
    let name: String
    let ingredients: [String]
    let steps: [String]
    let mapCoordinates: (Float,Float)? = nil

    init(from response: RecipeDetailResponse) {
        self.id = response.id
        self.imageURL = response.imageURL
        self.name = response.name
        self.ingredients = response.ingredients.map { "\($0.name) (\($0.quantity)) [\($0.type.rawValue)]" }
        self.steps = response.steps
        #warning("Uncomment and change optional on self.mapCoordinates")
        //self.mapCoordinates = response.coordinates
    }
}
