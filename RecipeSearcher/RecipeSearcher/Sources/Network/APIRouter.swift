//
//  APIRouter.swift
//  RecipeSearcher
//
//  Created by Paul Alvarez on 25/04/23.
//

struct APIRouter {
    struct GetRecipes: Request {
        typealias ReturnType = RecipesResponse
        var method: HTTPMethod = .get
        var path: String = RecipeRequest.recipes.path
    }

    struct GetRecipeDetail: Request {
        typealias ReturnType = RecipeDetailResponse
        var method: HTTPMethod = .get
        var path: String = RecipeRequest.recipe.path
        var queryParams: [String: Any]?

        init(queryParams: APIParameters.GetRecipeDetailParams) {
            self.queryParams = queryParams.asDictionary
        }
    }
}
