//
//  Request.swift
//  RecipeSearcher
//
//  Created by Paul Alvarez on 25/04/23.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
}

protocol Request {
    var method: HTTPMethod { get }
    var path: String { get }
    associatedtype ReturnType: Codable
}

extension Request {
    var method: HTTPMethod { return .get }
    var path: String { return "" }

    func asURLRequest(baseURL: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: baseURL) else { return nil }

        urlComponents.path = urlComponents.path.appending(path)

        guard let finalURL = urlComponents.url else { return nil }

        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        return request
    }
}

enum RecipeRequest {
    case recipes

    var path: String {
        switch self {
        case .recipes: return "recipes"
        }
    }
}
