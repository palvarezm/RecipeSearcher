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

    private lazy var ingredientsTitleLabel: UILabel = {
        let view = UILabel()
        view.text = "recipe_detail_ingredients_title".localized
        view.font = UIFont.boldSystemFont(ofSize: Constants.ingredientsTitleLabelFontSize)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var ingredientsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stepsTitleLabel: UILabel = {
        let view = UILabel()
        view.text = "recipe_detail_steps_title".localized
        view.font = UIFont.boldSystemFont(ofSize: Constants.stepsTitleLabelFontSize)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stepsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var checkOriginLocationButton: UIButton = {
        let view = UIButton()
        view.configuration = .bordered()
        view.configuration?.cornerStyle = .capsule
        view.configuration?.buttonSize = .large
        view.configuration?.title = "recipe_detail_check_origin_button_title".localized
        view.configuration?.baseForegroundColor = Constants.checkOriginLocationButtonTitleColor
        view.configuration?.baseBackgroundColor = .primary
        view.configuration?.image = .init(systemName: "map")
        view.configuration?.imagePadding = Constants.checkOriginLocationButtonImagePadding
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var viewModel: RecipeDetailViewModel
    @Published private var recipeDetail: RecipeDetailModel?

    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let navigateToMapTappedSubject = PassthroughSubject<Coordinates, Never>()
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
        static let ingredientsStackViewTopMargin = 8.0
        static let ingredientsStackViewHorizontalMargin = 16.0
        static let stepsLabelTopMargin = 16.0
        static let stepsLabelHorizontalMargin = 16.0
        static let stepsStackViewTopMargin = 8.0
        static let stepsStackViewHorizontalMargin = 16.0
        static let checkOriginLocationButtonTopMargin = 24.0
        static let checkOriginLocationButtonHorizontalMargin = 48.0
        static let checkOriginLocationButtonBottomMargin = 16.0
        static let checkOriginLocationButtonImagePadding = 8.0
        // Label
        static let nameLabelFontSize = 28.0
        static let ingredientsTitleLabelFontSize = 22.0
        static let ingredientLabelFontSize = 16.0
        static let stepsTitleLabelFontSize = 22.0
        static let stepLabelFontSize = 16.0
        // Image
        static let imageViewMaxHeight = 450.0
        // Button
        static let checkOriginLocationButtonTitleColor = UIColor.white
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - Bindings
    private func bindings() {
        $recipeDetail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.nameLabel.text = self?.recipeDetail?.name
                self?.listIngredients()
                self?.listSteps()

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

        output.navigateToMapPublisher
            .receive(on: DispatchQueue.main)
            .sink { coordinates in
                self.navigationController?.pushViewController(RecipeOriginLocationViewController(coordinates: coordinates),
                                                              animated: true)
            }
            .store(in: &cancellables)
    }

    // MARK: - Setup
    private func setup() {
        setupScrollView()
        setupContentView()
        setupNameLabel()
        setupImageView()
        setupIngredientsTitleLabel()
        setupIngredientsStackView()
        setupStepsTitleLabel()
        setupStepsStackView()
        setupCheckOriginLocationButton()
        setupCheckOriginButtonAction()
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

    private func setupIngredientsTitleLabel() {
        contentView.addSubview(ingredientsTitleLabel)
        NSLayoutConstraint.activate([
            ingredientsTitleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor,
                                                       constant: Constants.ingredientsLabelTopMargin),
            ingredientsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                           constant: Constants.ingredientsLabelHorizontalMargin),
            ingredientsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                            constant: -Constants.ingredientsLabelHorizontalMargin)
        ])
    }

    private func setupIngredientsStackView() {
        contentView.addSubview(ingredientsStackView)
        NSLayoutConstraint.activate([
            ingredientsStackView.topAnchor.constraint(equalTo: ingredientsTitleLabel.bottomAnchor,
                                                      constant: Constants.ingredientsStackViewTopMargin),
            ingredientsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                          constant: Constants.ingredientsStackViewHorizontalMargin),
            ingredientsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                          constant: -Constants.ingredientsStackViewHorizontalMargin)
        ])
    }

    private func setupStepsTitleLabel() {
        contentView.addSubview(stepsTitleLabel)
        NSLayoutConstraint.activate([
            stepsTitleLabel.topAnchor.constraint(equalTo: ingredientsStackView.bottomAnchor,
                                                 constant: Constants.stepsLabelTopMargin),
            stepsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                     constant: Constants.stepsLabelHorizontalMargin),
            stepsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                      constant: -Constants.stepsLabelHorizontalMargin)
        ])
    }

    private func setupStepsStackView() {
        contentView.addSubview(stepsStackView)
        NSLayoutConstraint.activate([
            stepsStackView.topAnchor.constraint(equalTo: stepsTitleLabel.bottomAnchor,
                                                constant: Constants.stepsStackViewTopMargin),
            stepsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                    constant: Constants.stepsStackViewHorizontalMargin),
            stepsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                     constant: -Constants.stepsStackViewHorizontalMargin)
        ])
    }

    private func setupCheckOriginLocationButton() {
        contentView.addSubview(checkOriginLocationButton)
        NSLayoutConstraint.activate([
            checkOriginLocationButton.topAnchor.constraint(equalTo: stepsStackView.bottomAnchor,
                                                           constant: Constants.checkOriginLocationButtonTopMargin),
            checkOriginLocationButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                           constant: Constants.checkOriginLocationButtonHorizontalMargin),
            checkOriginLocationButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                                constant: -Constants.checkOriginLocationButtonHorizontalMargin),
            checkOriginLocationButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor,
                                                              constant: -Constants.checkOriginLocationButtonBottomMargin)
        ])
    }

    // MARK: - Configuration
    private func listIngredients() {
        recipeDetail?.ingredients.forEach { ingredientsStackView.addArrangedSubview(buildIngredientLabel(text: $0)) }
    }

    private func buildIngredientLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = "• \(text)"
        label.font = UIFont.systemFont(ofSize: Constants.ingredientLabelFontSize)
        label.numberOfLines = 0
        return label
    }

    private func listSteps() {
        guard let steps = recipeDetail?.steps else { return }

        steps.indices.forEach{ stepsStackView.addArrangedSubview(
            buildStepLabel(index: $0+1, text: steps[$0])) }
    }

    private func buildStepLabel(index: Int, text: String) -> UILabel {
        let label = UILabel()
        label.text = "\(index). \(text)"
        label.font = UIFont.systemFont(ofSize: Constants.stepLabelFontSize)
        label.numberOfLines = 0
        return label
    }

    // MARK: - Actions
    private func setupCheckOriginButtonAction() {
        checkOriginLocationButton.addTarget(self, action: #selector(checkOriginButtonTapped), for: .touchUpInside)
    }

    @objc
    private func checkOriginButtonTapped() {
        guard let coordinates = recipeDetail?.mapCoordinates else { return }

        navigateToMapTappedSubject.send(coordinates)
    }
}
