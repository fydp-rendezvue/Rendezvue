//
//  Room.swift
//  Rendezvue
//
//  Created by Jack Lin on 2019-07-17.
//  Copyright © 2019 Rendezvue. All rights reserved.
//

import Foundation

struct RoomStruct {
    var roomId:Int = -1
    var roomName:String = ""
    
    init(roomId: Int, roomName: String) {
        self.roomId = roomId
        self.roomName = roomName
    }
}

class Room {
    //instantiated on first access
    static let sharedInstance = Room()
    let observerSubject = ObserverSubject()
    
    let currentUserId:Int = 1;
    var rooms:[Int:RoomStruct] = [:];
    
    private init() {
        print("Initializing Room")
    }
    
    func getRooms() {
        let requestUrl = "\(Constants.url)/users/\(currentUserId)/rooms"
        let session = URLSession.shared
        let url = URL(string: requestUrl)!
        
        //completionHandler in this case is a callback method
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
            //check if error when making api call
            if error != nil || data == nil {
//                self.handleClientError(error)
                print("Client Error!")
                return
            }
            
            //check status code
            // guard let checks if two conditions eval to false
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
//                self.handleServerError(response)
                print("Server Error!")
                return
            }
            
            //checking mime type
            guard let mime = response?.mimeType, mime == "application/json" else {
                print("Wrong MIME type")
                return
            }
            
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]] {
                    for roomInfo in jsonArray {
                        guard let roomId = roomInfo["roomId"] as? Int else { return }
                        guard let roomName = roomInfo["roomName"] as? String else { return }
                        
                        let roomStruct = RoomStruct(roomId: roomId, roomName: roomName)
                        self.rooms[roomId] = roomStruct
                    }
                    self.observerSubject.notify()
                }
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
        })
        
        //actually make the api call
        task.resume()
    }
    
    func postRoom(roomName : String){
        let urlString = "\(Constants.url)/users/\(currentUserId)/rooms"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: String] = [
            "roomName": roomName
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
            
            self.observerSubject.notify() //use this to update UI so user know marker is saved correctly
        }
        
        task.resume()
    }
}
