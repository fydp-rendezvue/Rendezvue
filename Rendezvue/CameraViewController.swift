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
    var roomId = Int()
    var markerGenerated = false

    var sceneLocationView = SceneLocationView()
    var locationManager = CLLocationManager()

    var directionLabel: UILabel!

    var closestLongitude: Double!
    var closestLatitude: Double!

    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneLocationView.showAxesNode = true
        sceneLocationView.showFeaturePoints = true

        Location.sharedInstance.observerSubject.attachObserver(observer: self)
        Location.sharedInstance.getSharedMarkers(roomId: roomId)

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

        directionLabel = UILabel(frame: CGRect(x: (view.frame.width - 100) * 9/10, y: UIScreen.main.bounds.height * 0.85, width:100.0, height:50.0))
        directionLabel.textAlignment = .center

        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)

        sceneLocationView.addSubview(getMarkerButton)
        sceneLocationView.addSubview(button)
        sceneLocationView.addSubview(backButton)
        sceneLocationView.addSubview(directionLabel)

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
            closestLongitude = longitude
            closestLatitude = latitude
        }

        let currentLongitude = sceneLocationView.sceneLocationManager.currentLocation?.coordinate.longitude ?? 0.0
        let currentLatitude = sceneLocationView.sceneLocationManager.currentLocation?.coordinate.latitude ?? 0.0

        if closestLongitude != nil && closestLatitude != nil {
            getDirection(long1: currentLongitude, long2: closestLongitude, lat1: currentLatitude, lat2: closestLatitude)
            markerGenerated = true
        }

        self.sceneLocationView.setNeedsDisplay()
    }


    @objc func backAction(sender: UIButton!) {
        let roomsRV = self.storyboard?.instantiateViewController(withIdentifier: "RoomsViewController") as! RoomsViewController
        // self.navigationController?.pushViewController(roomsRV, animated: true)
        present(roomsRV, animated: true, completion: nil)
    }

    @objc func buttonAction(sender: UIButton!) {

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
        //print(Location.sharedInstance.locations)
    }

    func getDirection(long1: Double, long2: Double, lat1: Double, lat2: Double){
        let dx = long2 - long1
        let dy = lat2 - lat1
        let cur_rad = atan2(dy, dx)
        let cur_theta = cur_rad * 180/Double.pi
        if cur_theta <= 135 || cur_theta > 45 {
            directionLabel.text = "GO NORTH"
        } else if cur_theta <= 225 || cur_theta > 135 {
            directionLabel.text = "GO WEST"
        } else if cur_theta <= 315 || cur_theta > 225 {
            directionLabel.text = "GO SOUTH"
        } else {
            directionLabel.text = "GO EAST"
        }
    }

    @objc func timerAction(){
        let currentLongitude = sceneLocationView.sceneLocationManager.currentLocation?.coordinate.longitude ?? 0.0
        let currentLatitude = sceneLocationView.sceneLocationManager.currentLocation?.coordinate.latitude ?? 0.0
        if (markerGenerated == true){
            getDirection(long1: closestLongitude, long2: currentLongitude, lat1: closestLatitude, lat2: currentLatitude)
            self.sceneLocationView.setNeedsDisplay()
        }
    }
}

