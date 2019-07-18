//
//  Model.swift
//  Rendezvue
//
//  Created by Jack Lin on 2019-07-17.
//  Copyright © 2019 Rendezvue. All rights reserved.
//

import Foundation

class Room {
    //instantiated on first access
    static let sharedInstance = Room()
    
    let currentUserId:Int = 1;
    var rooms = [(Int, String)]();
    
    func getRooms() {
        let requestUrl = "https://f6a53878.ngrok.io/users/\(currentUserId)/rooms"
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
            // guard let checks if two conditions eavl to false
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
//                self.handleServerError(response)
                print("Sever Error!")
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
                        self.rooms.append((roomId, roomName))
                    }
                }
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
        })
        
        //actually make the api call
        task.resume()
    }
    
    private init() {
        print("Initializing Room")
    }
}
