//
//  CameraViewController.swift
//  Rendezvue
//
//  Created by Richard Dang on 2019-07-16.
//  Copyright © 2019 Rendezvue. All rights reserved.
//

import ARCL
import CoreLocation

import UIKit
import AVFoundation

class CameraViewController: UIViewController, Observer {
    var id = Int()
    
    
    var sceneLocationView = SceneLocationView()
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneLocationView.showAxesNode = true
        sceneLocationView.showFeaturePoints = true

        Location.sharedInstance.observerSubject.attachObserver(observer: self)
        Location.sharedInstance.getSharedMarkers(roomId: 1)
        
        // Location manager settings for higher accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        
        let button = UIButton(frame: CGRect(x: (view.frame.width - 100)/2, y: UIScreen.main.bounds.height * 0.85, width: 100, height: 50))
        button.backgroundColor = .blue
        button.setTitle("Add", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

        let backButton = UIButton(frame: CGRect(x: (view.frame.width - 70) * 1/20, y: UIScreen.main.bounds.height * 0.05, width: 70, height: 30))
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        
        let getMarkerButton = UIButton(frame: CGRect(x: (view.frame.width - 70) * 19/20, y: UIScreen.main.bounds.height * 0.05, width: 70, height: 30))
        getMarkerButton.setTitle("Get Pins", for: .normal)
        getMarkerButton.addTarget(self, action: #selector(getPinsAction), for: .touchUpInside)
        
        sceneLocationView.addSubview(getMarkerButton)
        sceneLocationView.addSubview(button)
        sceneLocationView.addSubview(backButton)
        
        let locationData = Location.sharedInstance.locations
        print(locationData)
        
        addSceneModels()
        
        view.addSubview(sceneLocationView)
    }
    
    @objc func getPinsAction(sender: UIButton!) {
        for (_, loc_struct) in Location.sharedInstance.locations {
            let longitude = CLLocationDegrees(exactly: loc_struct.longitude as NSNumber)
            let latitude = CLLocationDegrees(exactly: loc_struct.latitude as NSNumber)
            let altitude = CLLocationDegrees(exactly: loc_struct.altitude as NSNumber)
            let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            let location = CLLocation(coordinate: coordinate, altitude: altitude!)
            let image = UIImage(named:"pin")!
            
            let annotationNode = LocationAnnotationNode(location: location, image: image)
            annotationNode.scaleRelativeToDistance = true
            self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
            print("Pin added")
        }
        self.sceneLocationView.setNeedsDisplay()
    }
    
    
    @objc func backAction(sender: UIButton!) {
        let roomsRV = self.storyboard?.instantiateViewController(withIdentifier: "RoomsViewController") as! RoomsViewController
        // self.navigationController?.pushViewController(roomsRV, animated: true)
        present(roomsRV, animated: true, completion: nil)
        print("Hello")
    }
    
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
        
        let image = UIImage(named: "pin")!
        let annotationNode = LocationAnnotationNode(location: nil, image: image)
        annotationNode.scaleRelativeToDistance = false
        
        sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
        
        let current_longitude = sceneLocationView.sceneLocationManager.currentLocation?.coordinate.longitude ?? 0.0
        let current_latitude = sceneLocationView.sceneLocationManager.currentLocation?.coordinate.latitude ?? 0.0
        let current_altitude = sceneLocationView.sceneLocationManager.currentLocation?.altitude ?? 0.0
        
        Location.sharedInstance.postSharedMarker(roomId: 1, longitude: current_longitude, latitude: current_latitude, altitude: current_altitude)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        sceneLocationView.run()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = view.bounds
    }
    
    func addSceneModels() {
        // 1. Don't try to add the models to the scene until we have a current location
        guard sceneLocationView.sceneLocationManager.currentLocation != nil else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.addSceneModels()
            }
            return
        }
    }
    
    func update() {
        print(Location.sharedInstance.locations)
    }
}
