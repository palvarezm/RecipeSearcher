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
        let navigateToMapTappedPublisher: AnyPublisher<Void, Never>
    }

    struct Output {
        let viewDidLoadPublisher: AnyPublisher<Void, Never>
        let setDataSourcePublisher: AnyPublisher<RecipeDetailModel?, Never>
        #warning("Change Void to coordinate data (a,b)")
        let navigateToRecipeDetailPublisher: AnyPublisher<Void, Never>
    }

    private var apiClient: APIClient
    private var recipeId: Int
    @Published var recipeDetail: RecipeDetailModel?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializers
    init(from recipeId: Int, apiClient: APIClient = APIClientImpl()) {
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

        let navigateToRecipeDetailPublisher: AnyPublisher<Void, Never> = input.navigateToMapTappedPublisher
            .flatMap { _ in
                return Just(()).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        return .init(viewDidLoadPublisher: viewDidLoadPublisher,
                     setDataSourcePublisher: setDataSourcePublisher,
                     navigateToRecipeDetailPublisher: navigateToRecipeDetailPublisher)
    }

    // MARK: - API Calls
    private func fetchRecipeDetail() {
        apiClient.dispatch(APIRouter.GetRecipeDetail(queryParams: APIParameters.GetRecipeDetailParams(id: recipeId)))
            .sink { _ in }
            receiveValue: { [weak self] response in
                self?.recipeDetail = RecipeDetailModel(from: response)
            }.store(in: &cancellables)
    }}
