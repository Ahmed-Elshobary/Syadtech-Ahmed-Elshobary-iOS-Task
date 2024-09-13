//
//  ViewController.swift
//  Syadtech-Ahmed-Elshobary-iOS-Task
//
//  Created by ahmed elshobary on 12/09/2024.
//

import UIKit
import GoogleMaps
import CoreData

class TrackerViewController: UIViewController {
    
    //MARK: - Outlets
    
    var mapView: GMSMapView!
    var tableView: UITableView!
    var startButton: UIButton!
    var viewModel: TrackerViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupMapView()
        setupTableView()

        // Initialize the view model with Core Data context and pass mapView
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        viewModel = TrackerViewModel(context: context, mapView: mapView)

        // Bind view model updates to UI
        viewModel.onLocationUpdate = { [weak self] coordinate in
            self?.zoomToLocation(coordinate)
        }

        viewModel.onPathsUpdated = { [weak self] in
            self?.tableView.reloadData()
        }

        viewModel.fetchSavedPaths()
    }

    func setupUI() {
        self.view.backgroundColor = UIColor.white
        startButton = UIButton()
        startButton.setTitle("Start", for: .normal)
        startButton.backgroundColor = UIColor.systemBlue
        startButton.layer.cornerRadius = 10
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.addTarget(self, action: #selector(startTracking), for: .touchUpInside)
        view.addSubview(startButton)

        let stopButton = UIButton()
        stopButton.setTitle("Stop", for: .normal)
        stopButton.backgroundColor = UIColor.systemBlue
        stopButton.layer.cornerRadius = 10
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.addTarget(self, action: #selector(stopTracking), for: .touchUpInside)
        view.addSubview(stopButton)

        NSLayoutConstraint.activate([
            startButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.widthAnchor.constraint(equalToConstant: 100),
            startButton.heightAnchor.constraint(equalToConstant: 50),

            stopButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stopButton.leadingAnchor.constraint(equalTo: startButton.trailingAnchor, constant: 20),
            stopButton.widthAnchor.constraint(equalToConstant: 100),
            stopButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func setupMapView() {
        mapView = GMSMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)

        mapView.isMyLocationEnabled = true    // Show the blue dot for user's location
        mapView.settings.myLocationButton = true // Show the location button in the bottom right
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25)
        ])
    }

    func setupTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc func startTracking() {
        viewModel.startTracking()
        startButton.setTitle("Tracking", for: .normal)
        startButton.backgroundColor = UIColor.red
    }

    @objc func stopTracking() {
        viewModel.stopTracking()
        startButton.setTitle("Start", for: .normal)
        startButton.backgroundColor = UIColor.systemBlue
    }

    func zoomToLocation(_ coordinate: CLLocationCoordinate2D) {
        if !viewModel.hasZoomedToUserLocation {
            let cameraUpdate = GMSCameraUpdate.setTarget(coordinate, zoom: 15)
            mapView.animate(with: cameraUpdate)
            viewModel.hasZoomedToUserLocation = true
        }
    }
}

// TableView DataSource and Delegate

extension TrackerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.savedPaths.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let savedPath = viewModel.savedPaths[indexPath.row]
        if let date = savedPath.date {
            cell.textLabel?.text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPath = viewModel.savedPaths[indexPath.row]
        if let encodedPath = selectedPath.coordinates as? NSData {
            if let path = viewModel.decodePath(encodedPath) {
                showPopupWithPath(path)
            }
        }
    }
}

// Open VC to view map and the path

extension TrackerViewController {
    func showPopupWithPath(_ path: GMSMutablePath) {
        let mapPopupVC = UIViewController()
        mapPopupVC.modalPresentationStyle = .overCurrentContext
        mapPopupVC.view.backgroundColor = UIColor.white.withAlphaComponent(0.9)

        let mapViewPopup = GMSMapView()
        mapViewPopup.translatesAutoresizingMaskIntoConstraints = false
        mapPopupVC.view.addSubview(mapViewPopup)

        NSLayoutConstraint.activate([
            mapViewPopup.topAnchor.constraint(equalTo: mapPopupVC.view.topAnchor, constant: 40),
            mapViewPopup.leadingAnchor.constraint(equalTo: mapPopupVC.view.leadingAnchor, constant: 20),
            mapViewPopup.trailingAnchor.constraint(equalTo: mapPopupVC.view.trailingAnchor, constant: -20),
            mapViewPopup.heightAnchor.constraint(equalToConstant: 300)
        ])

        mapPopupVC.view.layoutIfNeeded()

        DispatchQueue.main.async {
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 5
            polyline.strokeColor = UIColor.systemBlue
            polyline.map = mapViewPopup

            // Set the camera to show the entire path
            var bounds = GMSCoordinateBounds()
            for i in 0..<path.count() {
                bounds = bounds.includingCoordinate(path.coordinate(at: i))
            }
            let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
            mapViewPopup.animate(with: update)
        }

        let dismissButton = UIButton(type: .system)
        dismissButton.setTitle("Close", for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        mapPopupVC.view.addSubview(dismissButton)

        NSLayoutConstraint.activate([
            dismissButton.centerXAnchor.constraint(equalTo: mapPopupVC.view.centerXAnchor),
            dismissButton.topAnchor.constraint(equalTo: mapViewPopup.bottomAnchor, constant: 20),
            dismissButton.widthAnchor.constraint(equalToConstant: 100),
            dismissButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        self.present(mapPopupVC, animated: true)
    }

    @objc func dismissPopup() {
        self.dismiss(animated: true, completion: nil)
    }
}
