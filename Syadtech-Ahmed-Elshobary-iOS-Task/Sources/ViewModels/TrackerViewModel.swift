//
//  TrackerViewModel.swift
//  Syadtech-Ahmed-Elshobary-iOS-Task
//
//  Created by ahmed elshobary on 12/09/2024.
//

import Foundation
import GoogleMaps
import CoreLocation
import CoreData

class TrackerViewModel: NSObject, CLLocationManagerDelegate {
    
    private var locationManager = CLLocationManager()
    private(set) var trackingPath = GMSMutablePath()
    private var polyline = GMSPolyline()
    var isTracking = false
    var savedPaths = [PathEntity]()
    private var context: NSManagedObjectContext
    var onLocationUpdate: ((CLLocationCoordinate2D) -> Void)?
    var onPathsUpdated: (() -> Void)?
    var hasZoomedToUserLocation = false

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func startTracking() {
        isTracking = true
        trackingPath = GMSMutablePath()
        polyline = GMSPolyline(path: trackingPath)
        locationManager.startUpdatingLocation()
    }

    func stopTracking() {
        isTracking = false
        locationManager.stopUpdatingLocation()
        savePathToCoreData()
    }

    // Handle location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinate = location.coordinate

        if isTracking {
            trackingPath.add(coordinate)
            polyline.path = trackingPath
        }

        // Notify the view controller about location updates
        onLocationUpdate?(coordinate)
    }

    // Save path to Core Data
    private func savePathToCoreData() {
        let pathEntity = PathEntity(context: context)
        if let encodedPath = encodePath(trackingPath) {
            pathEntity.coordinates = encodedPath as NSData
        }
        pathEntity.date = Date()

        do {
            try context.save()
            fetchSavedPaths()  // Refresh paths after saving
        } catch {
            print("Failed to save path: \(error)")
        }
    }

    // Fetch saved paths from Core Data
    func fetchSavedPaths() {
        let request: NSFetchRequest<PathEntity> = PathEntity.fetchRequest()
        do {
            savedPaths = try context.fetch(request)
            onPathsUpdated?()  // Notify the view controller about the update
        } catch {
            print("Error fetching paths: \(error)")
        }
    }

    // Encode path to Data
    private func encodePath(_ path: GMSMutablePath) -> Data? {
        var encodedPath = [String]()
        for i in 0..<path.count() {
            let coordinate = path.coordinate(at: i)
            encodedPath.append("\(coordinate.latitude),\(coordinate.longitude)")
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: encodedPath, options: [])
            return data
        } catch {
            print("Failed to encode path: \(error)")
            return nil
        }
    }

    // Decode path from Data
    func decodePath(_ encodedPath: NSData) -> GMSMutablePath? {
        let path = GMSMutablePath()

        do {
            if let coordinateStrings = try JSONSerialization.jsonObject(with: encodedPath as Data, options: []) as? [String] {
                for coordinateString in coordinateStrings {
                    let components = coordinateString.split(separator: ",")
                    if let lat = Double(components[0]), let lon = Double(components[1]) {
                        path.add(CLLocationCoordinate2D(latitude: lat, longitude: lon))
                    }
                }
            }
        } catch {
            print("Failed to decode path: \(error)")
            return nil
        }

        return path
    }
}
