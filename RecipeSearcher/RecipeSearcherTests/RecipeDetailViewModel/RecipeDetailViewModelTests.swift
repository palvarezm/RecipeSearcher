//
//  RecipeDetailViewModelTests.swift
//  RecipeSearcherTests
//
//  Created by Paul Alvarez on 1/05/23.
//

import XCTest
import Combine
@testable import RecipeSearcher

final class RecipeDetailViewModelTests: XCTestCase {
    private var sut: RecipeDetailViewModel!

    private let viewDidLoadEvent = PassthroughSubject<Void, Never>()
    private let navigateToMapTappedEvent = PassthroughSubject<Coordinates, Never>()
    private var cancellables = Set<AnyCancellable>()

    private var output: RecipeDetailViewModel.Output!
    private var mockAPIClient: APIClient!

    override func setUp() {
        super.setUp()
        mockAPIClient = getMockAPIFromJSON(urlString: APIConstants.baseURL + RecipeRequest.recipe.path + "?id=0",
                                           fileName: "recipeDetailResponse")
        sut = .init(from: 0, apiClient: mockAPIClient)
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
            .sink { recipe in
                XCTAssertEqual(recipe?.id, 0)
                XCTAssertEqual(recipe?.name, "At vero eos")
                XCTAssertEqual(recipe?.imageURL, "https://www.imageurl.com")
                XCTAssertEqual(recipe?.ingredients.isEmpty, false)
                XCTAssertEqual(recipe?.ingredients.isEmpty, false)
                XCTAssertEqual(recipe?.steps.first, "deleniti atque corrupti")
                XCTAssertEqual(recipe?.steps.isEmpty, false)
                XCTAssertEqual(recipe?.mapCoordinates.0, 12.3456)
                XCTAssertEqual(recipe?.mapCoordinates.1, 78.9012)
                expectation.fulfill()
            }.store(in: &cancellables)

        // When
        viewDidLoadEvent.send()
        wait(for: [expectation], timeout: 1)
    }

    func testNavigateToMapWhenGoToMapIsTriggered() throws {
        // Given
        let viewDidLoadExpectation = XCTestExpectation(description: "Waiting for response...")
        let navigateToMapTappedExpectation = XCTestExpectation()
        output.viewDidLoadPublisher.sink { _ in }.store(in: &cancellables)
        output.setDataSourcePublisher
            .dropFirst()
            .sink { recipe in
                viewDidLoadExpectation.fulfill()
            }.store(in: &cancellables)

        //Then
        output.navigateToMapPublisher.sink { [weak self] coordinates in
            XCTAssertEqual(self?.sut.recipeDetail?.mapCoordinates.0, coordinates.0)
            XCTAssertEqual(self?.sut.recipeDetail?.mapCoordinates.1, coordinates.1)
            navigateToMapTappedExpectation.fulfill()
        }.store(in: &cancellables)

        // When
        viewDidLoadEvent.send()
        wait(for: [viewDidLoadExpectation], timeout: 1)
        navigateToMapTappedEvent.send(sut.recipeDetail?.mapCoordinates ?? (0,0) )
        wait(for: [navigateToMapTappedExpectation], timeout: 1)
    }
}

// MARK: - RecipeDetailViewModelTests Helpers
extension RecipeDetailViewModelTests {
    private func buildOutput() -> RecipeDetailViewModel.Output {
        let input = RecipeDetailViewModel.Input(
            viewDidLoadPublisher: viewDidLoadEvent.eraseToAnyPublisher(),
            navigateToMapTappedPublisher: navigateToMapTappedEvent.eraseToAnyPublisher())
        
        let output = sut.transform(input: input)
        return output
    }
}
