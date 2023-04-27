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

    private var coordinates: Coordinates

    // MARK: - Initializers
    init(coordinates: Coordinates) {
        self.coordinates = coordinates
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Setup
    private func setup() {
        setupMapView()
        showOriginLocation()
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

    private func showOriginLocation() {
        let location = CLLocationCoordinate2D(latitude: coordinates.0, longitude: coordinates.1)
        mapView.setCenter(location, animated: false)
    }
}

extension RecipeOriginLocationViewController: MKMapViewDelegate {
    
}
