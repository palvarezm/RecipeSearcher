//
//  RecipeDetailViewController.swift
//  RecipeSearcher
//
//  Created by Paul Alvarez on 26/04/23.
//

import UIKit
import Combine

class RecipeDetailViewController: UIViewController {
    // MARK: - Properties
    private lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.text = "xaxaxax"
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var ingredientsLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stepsLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var viewModel: RecipeDetailViewModel

    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let navigateToMapTappedSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Constants
    private enum Constants {
        static let viewBackgroundColor = UIColor.white
        // Margins
        static let searchBarTopMargin = 24.0
        static let searchBarHorizontalMargin = 16.0
    }

    // MARK: - Initializers
    init(viewModel: RecipeDetailViewModel) {
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
        let input = RecipeDetailViewModel.Input(
            viewDidLoadPublisher: viewDidLoadSubject.eraseToAnyPublisher(),
            navigateToMapTappedPublisher: navigateToMapTappedSubject.eraseToAnyPublisher())
        let output = viewModel.transform(input: input)

        output.viewDidLoadPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.nameLabel.text = self?.viewModel.recipeDetail?.name
            }
            .store(in: &cancellables)

        output.navigateToRecipeDetailPublisher
            .receive(on: DispatchQueue.main)
            .sink { recipe in
                #warning("Implement navigation")
                debugPrint("Navigate to Map with \(recipe)")
            }
            .store(in: &cancellables)
    }

    // MARK: - Setup
    private func setup() {
        setupNameLabel()
        setupImageView()
        setupIngredientsLabel()
        setupStepsLabel()
    }

    private func setupNameLabel() {
        view.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupImageView() {
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }

    private func setupIngredientsLabel() {
        view.addSubview(ingredientsLabel)
        NSLayoutConstraint.activate([
            ingredientsLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            ingredientsLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor),
            ingredientsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupStepsLabel() {
        view.addSubview(stepsLabel)
        NSLayoutConstraint.activate([
            stepsLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            stepsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stepsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stepsLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        ])
    }
}
