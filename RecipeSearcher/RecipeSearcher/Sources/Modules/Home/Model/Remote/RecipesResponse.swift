//
//  RecipesResponse.swift
//  RecipeSearcher
//
//  Created by Paul Alvarez on 25/04/23.
//

typealias RecipesResponse = [RecipeResponse]

struct RecipeResponse: Codable {
    let id: Int
    let name: String
    let imageURL: String
    let ingredients: [Ingredient]

    struct Ingredient: Codable {
        let name: String
        let type: TypeEnum

        enum TypeEnum: String, Codable {
            case baking = "Baking"
            case condiments = "Condiments"
            case dairy = "Dairy"
            case drinks = "Drinks"
            case meat = "Meat"
            case misc = "Misc"
            case produce = "Produce"
        }
    }
}
