//
//  RecipeCell.swift
//  RecipeSearcher
//
//  Created by Paul Alvarez on 26/04/23.
//

import UIKit
import Combine
import SDWebImage

class RecipeCell: UITableViewCell {
    // MARK: - Properties
    private lazy var recipeImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "fruitbowl")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    static let identifier = String(describing: RecipeCell.self)
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Constants
    private enum Constants {
        // Margin
        static let recipeImageViewTopMargin = 16.0
        static let recipeImageViewBottomMargin = 16.0
        static let recipeImageViewLeadingMargin = 8.0
        static let nameLabelLeadingMargin = 16.0
        static let nameLabelTrailingMargin = 8.0
        // Image
        static let recipeImageSize = 42.0
    }
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setup() {
        selectionStyle = .none
        setupRecipeImageView()
        setupNameLabel()
    }

    private func setupRecipeImageView() {
        addSubview(recipeImageView)
        NSLayoutConstraint.activate([
            recipeImageView.heightAnchor.constraint(equalToConstant: Constants.recipeImageSize),
            recipeImageView.widthAnchor.constraint(equalToConstant: Constants.recipeImageSize),
            recipeImageView.topAnchor.constraint(equalTo: topAnchor,
                                                 constant: Constants.recipeImageViewTopMargin),
            recipeImageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor,
                                                    constant: -Constants.recipeImageViewBottomMargin),
            recipeImageView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                     constant: Constants.recipeImageViewLeadingMargin)
        ])
    }

    private func setupNameLabel() {
        addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor,
                                               constant: Constants.nameLabelLeadingMargin),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor,
                                                constant: -Constants.nameLabelLeadingMargin),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // MARK: - Configuration
    public func configure(for cellModel: RecipeCellModel) {
        self.nameLabel.text = cellModel.name
        if let imageURL = URL(string: cellModel.imageURL) {
            self.recipeImageView.sd_setImage(with: imageURL,
                                             placeholderImage: UIImage(named: "fruitbowl"))
        }
    }
}
