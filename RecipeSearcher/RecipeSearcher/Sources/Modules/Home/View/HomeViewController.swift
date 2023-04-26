//
//  ViewController.swift
//  RecipeSearcher
//
//  Created by Paul Alvarez on 21/04/23.
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    // MARK: - Properties
    private lazy var searchBar: UISearchBar = {
        let view = UISearchBar()
        view.placeholder = "Search"
        view.searchBarStyle = .minimal
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var viewModel: HomeViewModel
    @Published private var recipes: [RecipeCellModel] = []

    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let searchTextSubject = PassthroughSubject<String?, Never>()
    private let didSelectRecipeSubject = PassthroughSubject<RecipeCellModel, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Constants
    private enum Constants {
        static let viewBackgroundColor = UIColor.white
        // Margins
        static let searchBarTopMargin = 36.0
        static let searchBarHorizontalMargin = 16.0
    }

    // MARK: - Initializers
    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        bindings()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.viewBackgroundColor
        setup()
        viewDidLoadSubject.send()
    }

    // MARK: - Bindings
    private func bindings() {
        $recipes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        let input = HomeViewModel.Input(
            viewDidLoadPublisher: viewDidLoadSubject.eraseToAnyPublisher(),
            searchTextPublisher: searchTextSubject.eraseToAnyPublisher(),
            didSelectRecipePublisher: didSelectRecipeSubject.eraseToAnyPublisher())
        let output = viewModel.transform(input: input)

        [output.viewDidLoadPublisher, output.searchTextPublisher].forEach {
            $0.sink { _ in }.store(in: &cancellables)
        }

        output.navigateToRecipeDetailPublisher
            .receive(on: DispatchQueue.main)
            .sink { recipe in
                #warning("Implement navigation")
                debugPrint("Navigate to Detail with \(recipe)")
            }
            .store(in: &cancellables)

        output.setDataSourcePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] recipes in
                self?.recipes = recipes
            }
            .store(in: &cancellables)
    }

    // MARK: - Setup
    private func setup() {
        setupSearchBar()
        setupTableView()
    }

    private func setupSearchBar() {
        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.topAnchor,
                                           constant: Constants.searchBarTopMargin),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                               constant: Constants.searchBarHorizontalMargin),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                constant: -Constants.searchBarHorizontalMargin),
        ])
    }

    private func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        tableView.register(RecipeCell.self, forCellReuseIdentifier: RecipeCell.identifier)
    }
}

// MARK: - UISearchBarDelegate
extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTextSubject.send(searchText)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeCell.identifier, for: indexPath) as? RecipeCell else { return UITableViewCell() }

        let recipe = recipes[indexPath.item]
        cell.configure(for: recipe)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipe = recipes[indexPath.item]
        didSelectRecipeSubject.send(recipe)
    }
}
