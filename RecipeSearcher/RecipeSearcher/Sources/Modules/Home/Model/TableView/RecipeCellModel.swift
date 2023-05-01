//
//  Recipe.swift
//  RecipeSearcher
//
//  Created by Paul Alvarez on 25/04/23.
//

struct RecipeCellModel: Equatable {
    let id: Int
    let imageURL: String
    let name: String
    let ingredients: String

    init(from response: RecipeResponse) {
        self.id = response.id
        self.imageURL = response.imageURL
        self.name = response.name
        self.ingredients = response.ingredients.map { "\($0.name) \($0.type.rawValue)" }.joined(separator: " ")
    }
}
