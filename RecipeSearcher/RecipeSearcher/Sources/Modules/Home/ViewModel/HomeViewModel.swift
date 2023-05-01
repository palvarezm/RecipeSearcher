//
//  HomeViewModel.swift
//  RecipeSearcher
//
//  Created by Paul Alvarez on 25/04/23.
//

import Combine

class HomeViewModel {
    struct Input {
        let viewDidLoadPublisher: AnyPublisher<Void, Never>
        let searchTextPublisher: AnyPublisher<String?, Never>
        let didSelectRecipePublisher: AnyPublisher<RecipeCellModel, Never>
    }

    struct Output {
        let viewDidLoadPublisher: AnyPublisher<Void, Never>
        let searchTextPublisher: AnyPublisher<Void, Never>
        let setDataSourcePublisher: AnyPublisher<[RecipeCellModel], Never>
        let navigateToRecipeDetailPublisher: AnyPublisher<RecipeCellModel, Never>
    }

    private var apiClient: APIClient
    @Published private var recipes: [RecipeCellModel] = []
    @Published private var searchText: String?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializers
    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    // MARK: - Bindings
    func transform(input: Input) -> Output {
        let viewDidLoadPublisher: AnyPublisher<Void, Never> = input.viewDidLoadPublisher
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.fetchRecipes()
            })
            .flatMap {
                return Just(()).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let searchTextPublisher: AnyPublisher<Void,Never> = input.searchTextPublisher
            .handleEvents(receiveOutput: { [weak self] searchText in
                self?.searchText = searchText
            })
            .flatMap { _ in
                return Just(()).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let setDataSourcePublisher: AnyPublisher<[RecipeCellModel], Never> = Publishers.CombineLatest($recipes.compactMap { $0 }, $searchText)
            .flatMap { (recipes: [RecipeCellModel], searchText: String?) -> AnyPublisher<[RecipeCellModel], Never> in
                if let searchText = searchText, !searchText.isEmpty {
                    let filteredRecipes = recipes.filter {
                        $0.name.lowercased().contains(searchText.lowercased()) ||
                        $0.ingredients.lowercased().contains(searchText.lowercased())
                    }
                    return Just(filteredRecipes).eraseToAnyPublisher()
                } else {
                    return Just(recipes).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()

        let navigateToRecipeDetailPublisher: AnyPublisher<RecipeCellModel, Never> = input.didSelectRecipePublisher
            .flatMap { recipe in
                return Just(recipe).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        return .init(viewDidLoadPublisher: viewDidLoadPublisher,
                     searchTextPublisher: searchTextPublisher,
                     setDataSourcePublisher: setDataSourcePublisher,
                     navigateToRecipeDetailPublisher: navigateToRecipeDetailPublisher)
    }

    // MARK: - API Calls
    private func fetchRecipes() {
        apiClient.dispatch(APIRouter.GetRecipes())
            .sink { _ in }
            receiveValue: { [weak self] recipes in
                self?.recipes = recipes.map { RecipeCellModel(from: $0) }
            }.store(in: &cancellables)
    }
}
