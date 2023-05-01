//
//  RecipeSearcherTests.swift
//  RecipeSearcherTests
//
//  Created by Paul Alvarez on 21/04/23.
//

import XCTest
import Combine
@testable import RecipeSearcher

class HomeViewModelTests: XCTestCase {
    private var sut: HomeViewModel!
    private let viewDidLoadEvent = PassthroughSubject<Void, Never>()
    private let searchTextEvent = PassthroughSubject<String?, Never>()
    private let didSelectRecipeEvent = PassthroughSubject<RecipeCellModel, Never>()
    private var cancellables = Set<AnyCancellable>()

    private var output: HomeViewModel.Output!
    private var mockAPIClient: APIClient!

    override func setUp() {
        super.setUp()
        mockAPIClient = getMockAPIFromJSON(urlString: APIConstants.baseURL + RecipeRequest.recipes.path,
                                           fileName: "recipesResponse")
        sut = .init(apiClient: mockAPIClient)
        output = buildOutput()
    }

    override func tearDown() {
        super.tearDown()
        mockAPIClient = nil
        sut = nil
        output = nil
    }

    func testSetDataSourceWhenViewDidLoadEventIsTriggered() throws {
        // Given
        let expectation = XCTestExpectation(description: "Waiting for response...")

        // Then
        output.viewDidLoadPublisher.sink { _ in }.store(in: &cancellables)
        output.setDataSourcePublisher
            .dropFirst()
            .sink { recipes in
                XCTAssertEqual(recipes.count, 2)
                XCTAssertEqual(recipes.first?.name, "delectus aut autem")
                XCTAssertEqual(recipes.first?.imageURL, "https://www.imageurl.com")
                XCTAssertEqual(recipes.first?.ingredients.isEmpty, false)
                expectation.fulfill()
            }.store(in: &cancellables)

        // When
        viewDidLoadEvent.send()
        wait(for: [expectation], timeout: 1)
    }

    func testSetDataSourceWhenSearchTextEventIsTriggered() {
        // Given
        var viewDidLoaded = false
        let viewDidLoadExpectation = XCTestExpectation(description: "Waiting for response...")
        let searchTextExpectation = XCTestExpectation(description: "Waiting for filtering searchText...")

        // Then
        [output.viewDidLoadPublisher, output.searchTextPublisher].forEach { $0.sink { _ in }.store(in: &cancellables) }
        output.setDataSourcePublisher
            .dropFirst()
            .sink { recipes in
                if viewDidLoaded {
                    XCTAssertEqual(recipes.count, 1)
                    XCTAssertEqual(recipes.first?.name, "et porro tempora")
                    XCTAssertEqual(recipes.first?.imageURL, "https://www.imageurl2.com")
                    XCTAssertEqual(recipes.first?.ingredients.isEmpty, false)
                    searchTextExpectation.fulfill()
                } else {
                    viewDidLoadExpectation.fulfill()
                    viewDidLoaded = true
                }
            }.store(in: &cancellables)

        // When
        viewDidLoadEvent.send()
        wait(for: [viewDidLoadExpectation], timeout: 1)
        searchTextEvent.send("et porro")
        wait(for: [searchTextExpectation], timeout: 1)
    }

    func testShowRecipeDetailWhenRecipeIsSelected() {
        // Given
        let viewDidLoadExpectation = XCTestExpectation(description: "Waiting for response...")
        let expectation = XCTestExpectation(description: "Show Recipe Detail")
        var recipe: RecipeCellModel?

        [output.viewDidLoadPublisher].forEach { $0.sink { _ in }.store(in: &cancellables) }
        output.setDataSourcePublisher
            .dropFirst()
            .sink { recipes in
                recipe = recipes[1]
                viewDidLoadExpectation.fulfill()
            }.store(in: &cancellables)

        // Then
        output.navigateToRecipeDetailPublisher
            .sink { selectedRecipe in
                XCTAssertEqual(recipe, selectedRecipe)
                expectation.fulfill()
            }.store(in: &cancellables)

        // When
        viewDidLoadEvent.send()
        wait(for: [viewDidLoadExpectation], timeout: 1)
        didSelectRecipeEvent.send(recipe!)
        wait(for: [expectation], timeout: 1)
    }
}

// MARK: - HomeViewModelTests Helpers
extension HomeViewModelTests {
    private func buildOutput() -> HomeViewModel.Output {
        let input = HomeViewModel.Input(
            viewDidLoadPublisher: viewDidLoadEvent.eraseToAnyPublisher(),
            searchTextPublisher: searchTextEvent.eraseToAnyPublisher(),
            didSelectRecipePublisher: didSelectRecipeEvent.eraseToAnyPublisher())
        
        let output = sut.transform(input: input)
        return output
    }
}
