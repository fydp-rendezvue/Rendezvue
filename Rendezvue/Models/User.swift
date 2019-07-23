//
//  User.swift
//  Rendezvue
//
//  Created by Matthew Kim on 2019-07-18.
//  Copyright © 2019 Rendezvue. All rights reserved.
//

import Foundation

struct UserStruct {
    var userId:Int = -1
    var username:String = ""
    var firstName:String = ""
    var lastName:String = ""
    
    init(userId: Int, username: String, firstName: String, lastName: String) {
        self.userId = userId
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
    }
}

class User {
    //instantiated on first access
    static let sharedInstance = User()
    let observerSubject = ObserverSubject()
    
    let currentUserId = 1;
    var users:[Int:UserStruct] = [:];
    var usersInRoom:[Int:[UserStruct]] = [:];
    
    private init() {
        print("Initializing User")
    }
    
    func getUsersInRoom(roomId: Int) {
        let requestUrl = "\(Constants.url)/users/\(currentUserId)/rooms/\(roomId)/usersInRoom"
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
                    var users: [UserStruct] = []
                    for userInfo in jsonArray {
                        guard let userId = userInfo["userId"] as? Int else { return }
                        guard let username = userInfo["username"] as? String else { return }
                        guard let firstName = userInfo["firstName"] as? String else { return }
                        guard let lastName = userInfo["lastName"] as? String else { return }
                        
                        let userStruct = UserStruct(userId: userId, username: username, firstName: firstName, lastName: lastName)
                        users.append(userStruct)
                    }
                    self.usersInRoom[roomId] = users
                    
                    self.observerSubject.notify()
                }
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
        })
        
        //actually make the api call
        task.resume()
    }
    
    func getUsers() {
        let requestUrl = "\(Constants.url)/users"
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
                    for userInfo in jsonArray {
                        guard let userId = userInfo["userId"] as? Int else { return }
                        guard let username = userInfo["username"] as? String else { return }
                        guard let firstName = userInfo["firstName"] as? String else { return }
                        guard let lastName = userInfo["lastName"] as? String else { return }
                        
                        let userStruct = UserStruct(userId: userId, username: username, firstName: firstName, lastName: lastName)
                        self.users[userId] = userStruct
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
}
