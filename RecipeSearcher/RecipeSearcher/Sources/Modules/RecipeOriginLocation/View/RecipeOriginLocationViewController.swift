//
//  RecipeOriginLocationViewController.swift
//  RecipeSearcher
//
//  Created by Paul Alvarez on 27/04/23.
//

import Foundation
import UIKit
import MapKit

class RecipeOriginLocationViewController: UIViewController {
    // MARK: - Properties
    private lazy var mapView: MKMapView = {
        let view = MKMapView()
        view.overrideUserInterfaceStyle = .dark
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Setup
    private func setup() {
        setupMapView()
    }

    private func setupMapView() {
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension RecipeOriginLocationViewController: MKMapViewDelegate {
    
}
