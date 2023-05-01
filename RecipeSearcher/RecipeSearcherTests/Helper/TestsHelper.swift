//
//  TestsHelper.swift
//  RecipeSearcherTests
//
//  Created by Paul Alvarez on 29/04/23.
//

import XCTest
@testable import RecipeSearcher

extension XCTestCase {
    func loadJSONDataFromFile(named fileName: String) throws -> Data {
        let testBundle = Bundle(for: type(of: self))
        guard let url = testBundle.url(forResource: fileName, withExtension: "json") else {
            throw NSError(domain: "File \(fileName).json not found", code: 1, userInfo: nil)
        }

        return try Data(contentsOf: url)
    }

    func getMockAPIFromJSON(urlString: String, fileName: String) -> APIClient {
        let url = URL(string: urlString)
        do {
            let jsonData = try loadJSONDataFromFile(named: fileName)
            URLProtocolMock.testURLs = [url: jsonData]
        } catch {
            XCTFail("Error loading JSON data: \(error.localizedDescription)")
        }
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]

        let session =  URLSession(configuration: config)

        let dispatcher = NetworkDispatcher(urlSession: session)
        return APIClient(networkDispatcher: dispatcher)
    }
}
