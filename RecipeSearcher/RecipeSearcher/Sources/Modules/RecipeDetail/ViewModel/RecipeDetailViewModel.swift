//
//  RecipeDetailViewModel.swift
//  RecipeSearcher
//
//  Created by Paul Alvarez on 26/04/23.
//

import Combine

class RecipeDetailViewModel {
    struct Input {
        let viewDidLoadPublisher: AnyPublisher<Void, Never>
        let navigateToMapTappedPublisher: AnyPublisher<Coordinates, Never>
    }

    struct Output {
        let viewDidLoadPublisher: AnyPublisher<Void, Never>
        let setDataSourcePublisher: AnyPublisher<RecipeDetailModel?, Never>
        let navigateToMapPublisher: AnyPublisher<Coordinates, Never>
    }

    private var apiClient: APIClient
    private var recipeId: Int
    @Published var recipeDetail: RecipeDetailModel?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializers
    init(from recipeId: Int, apiClient: APIClient = APIClient()) {
        self.recipeId = recipeId
        self.apiClient = apiClient
    }

    // MARK: - Bindings
    func transform(input: Input) -> Output {
        let viewDidLoadPublisher: AnyPublisher<Void, Never> = input.viewDidLoadPublisher
            .handleEvents(receiveOutput: { [weak self] value in
                self?.fetchRecipeDetail()
            })
            .flatMap {
                return Just(()).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let setDataSourcePublisher: AnyPublisher<RecipeDetailModel?, Never> = $recipeDetail
            .flatMap { recipeDetail in
                return Just(recipeDetail).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let navigateToMapPublisher: AnyPublisher<Coordinates, Never> = input.navigateToMapTappedPublisher
            .flatMap { coordinates in
                return Just(coordinates).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        return .init(viewDidLoadPublisher: viewDidLoadPublisher,
                     setDataSourcePublisher: setDataSourcePublisher,
                     navigateToMapPublisher: navigateToMapPublisher)
    }

    // MARK: - API Calls
    private func fetchRecipeDetail() {
        apiClient.dispatch(APIRouter.GetRecipeDetail(queryParams: APIParameters.GetRecipeDetailParams(id: recipeId)))
            .sink { _ in }
            receiveValue: { [weak self] response in
                self?.recipeDetail = RecipeDetailModel(from: response)
            }.store(in: &cancellables)
    }}
