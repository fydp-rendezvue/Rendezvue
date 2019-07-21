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
        
        sceneLocationView.addSubview(button)
        
        view.addSubview(sceneLocationView)
        
        Location.sharedInstance.observerSubject.attachObserver(observer: self)
        Location.sharedInstance.getSharedMarkers(roomId: 1)
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
        }
    }
    
    func update() {
        print("Something")
    }
}
