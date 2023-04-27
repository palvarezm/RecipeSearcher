//
//  RecipeDetailResponse.swift
//  RecipeSearcher
//
//  Created by Paul Alvarez on 26/04/23.
//

struct RecipeDetailResponse: Codable {
    let id: Int
    let name: String
    let ingredients: [Ingredient]
    let steps: [String]
    let timers: [Int]
    let imageURL: String
//    let originalURL: String?

    struct Ingredient: Codable {
        let quantity: String
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
