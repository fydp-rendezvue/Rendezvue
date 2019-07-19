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

class CameraViewController: UIViewController {
    
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
        
        let button = UIButton(frame: CGRect(x: view.frame.midX, y: UIScreen.main.bounds.height * 0.85, width: 100, height: 50))
        button.backgroundColor = .blue
        button.setTitle("Add", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        sceneLocationView.addSubview(button)
        
        view.addSubview(sceneLocationView)
    }
    
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
        
        let image = UIImage(named: "pin")!
        let annotationNode = LocationAnnotationNode(location: nil, image: image)
        annotationNode.scaleRelativeToDistance = false
        
        sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
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
}
