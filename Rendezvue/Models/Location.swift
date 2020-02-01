//
//  Location.swift
//  Rendezvue
//
//  Created by Jack Lin on 2019-07-18.
//  Copyright © 2019 Rendezvue. All rights reserved.
//

import Foundation

struct LocationStruct {
    var locationId = -1
    var longitude : Double = -0.0
    var latitude : Double = -0.0
    var altitude : Double = -0.0
    var markerMetadata : String = ""
    
    init(locationId: Int, longitude: Double, latitude: Double, altitude: Double, markerMetadata: String) {
        self.locationId = locationId
        self.longitude = longitude
        self.latitude = latitude
        self.altitude = altitude
        self.markerMetadata = markerMetadata
    }
}

class Location {
    static let sharedInstance = Location()
    let observerSubject = ObserverSubject()
    
    var locations:[Int:LocationStruct] = [:]
    
    private init() {
        print("Initializing Location")
    }
    
    func getSharedMarkers(roomId:Int) {
        let urlString = "\(Constants.url)/users/\(User.sharedInstance.currentUserId)/rooms/\(roomId)/markers"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                    print("error", error ?? "Unknown error")
                    return
            }

            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }

            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString!)")
            let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
            let results = json["results"] as! [[String:Any]]
 
            results.forEach{
                guard let locationId = $0["locationId"] as? Int else { print("Invalid locationId Type"); return }
                guard let longitude = $0["longitude"] as? Double else { print("Invalid longitude Type"); return }
                guard let latitude = $0["latitude"] as? Double else { print("Invalid latitude Type"); return }
                guard let altitude = $0["altitude"] as? Double else { print("Invalid altitude Type"); return }
                guard let markerMetaData = $0["markerMetadata"] as? String else { print("Invalid markerMetadata Type"); return }
                
                // Duplicate usage of location id, one should be pruned
                let locationStruct = LocationStruct(locationId: locationId, longitude: longitude, latitude: latitude, altitude: altitude, markerMetadata: markerMetaData)
                
                self.locations[locationId] = locationStruct
            }
            
            self.observerSubject.notify()
        }
        task.resume()
    }
    
    // TODO: need to add the markerMetadata
    func postSharedMarker(roomId : Int, longitude : Double, latitude : Double, altitude : Double){
        let urlString = "\(Constants.url)/users/\(User.sharedInstance.currentUserId)/rooms/\(roomId)/marker"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Double] = [
            "longitude": longitude,
            "latitude": latitude,
            "altitude": altitude
        ]
        guard let httpBody = try? JSONSerialization.data(withJSONObject:  parameters, options: []) else { return }
        request.httpBody = httpBody

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                    print("error", error ?? "Unknown error")
                    return
            }

            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }

            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString!)")
            
            self.observerSubject.notify() //use this to update UI so user know marker is saved correctly
        }

        task.resume()
    }
}
