//
//  RecipeDetailViewController.swift
//  RecipeSearcher
//
//  Created by Paul Alvarez on 26/04/23.
//

import UIKit
import Combine
import SDWebImage

class RecipeDetailViewController: UIViewController {
    // MARK: - Properties
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.font = UIFont.boldSystemFont(ofSize: Constants.nameLabelFontSize)
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var ingredientsLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stepsLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var viewModel: RecipeDetailViewModel
    @Published private var recipeDetail: RecipeDetailModel?

    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let navigateToMapTappedSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Constants
    private enum Constants {
        static let viewBackgroundColor = UIColor.white
        // Margins
        static let nameLabelTopMargin = 8.0
        static let nameLabelHorizontalMargin = 18.0
        static let imageViewBottomMargin = 16.0
        static let ingredientsLabelTopMargin = 16.0
        static let ingredientsLabelHorizontalMargin = 16.0
        static let stepsLabelTopMargin = 16.0
        static let stepsLabelHorizontalMargin = 16.0
        static let stepsLabelBottomMargin = 16.0
        // Label
        static let nameLabelFontSize = 22.0
        // Image
        static let imageViewMaxHeight = 450.0
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
        $recipeDetail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.nameLabel.text = self?.recipeDetail?.name
                let ingredients = self?.recipeDetail?.ingredients.map { "- \($0)" }
                self?.ingredientsLabel.text = ingredients?.joined(separator: "\n")
                let steps = self?.recipeDetail?.steps.map { "- \($0)" }
                self?.stepsLabel.text = steps?.joined(separator: "\n")
                if let stringImageURL = self?.recipeDetail?.imageURL,
                    let imageURL = URL(string: stringImageURL) {
                    self?.imageView.sd_setImage(with: imageURL,
                                                placeholderImage: .init(named: "fruitbowl"))
                }
            }
            .store(in: &cancellables)

        let input = RecipeDetailViewModel.Input(
            viewDidLoadPublisher: viewDidLoadSubject.eraseToAnyPublisher(),
            navigateToMapTappedPublisher: navigateToMapTappedSubject.eraseToAnyPublisher())
        let output = viewModel.transform(input: input)

        output.viewDidLoadPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in }
            .store(in: &cancellables)

        output.setDataSourcePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] recipeDetail in
                self?.recipeDetail = recipeDetail
            }.store(in: &cancellables)

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
        setupScrollView()
        setupContentView()
        setupNameLabel()
        setupImageView()
        setupIngredientsLabel()
        setupStepsLabel()
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupContentView() {
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }

    private func setupNameLabel() {
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor,
                                           constant: Constants.nameLabelTopMargin),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                               constant: Constants.nameLabelHorizontalMargin),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                constant: -Constants.nameLabelHorizontalMargin)
        ])
    }

    private func setupImageView() {
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.imageViewMaxHeight),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            imageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,
                                           constant: Constants.imageViewBottomMargin),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    private func setupIngredientsLabel() {
        contentView.addSubview(ingredientsLabel)
        NSLayoutConstraint.activate([
            ingredientsLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor,
                                                  constant: Constants.ingredientsLabelTopMargin),
            ingredientsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                      constant: Constants.ingredientsLabelHorizontalMargin),
            ingredientsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                       constant: -Constants.ingredientsLabelHorizontalMargin)
        ])
    }

    private func setupStepsLabel() {
        contentView.addSubview(stepsLabel)
        NSLayoutConstraint.activate([
            stepsLabel.topAnchor.constraint(equalTo: ingredientsLabel.bottomAnchor,
                                            constant: Constants.stepsLabelTopMargin),
            stepsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                constant: Constants.stepsLabelHorizontalMargin),
            stepsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                 constant: -Constants.stepsLabelHorizontalMargin),
            stepsLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor,
                                               constant: -Constants.stepsLabelBottomMargin)
        ])
    }
}
