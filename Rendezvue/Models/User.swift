//
//  Model.swift
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
    var password:String = ""
    
    init(userId: Int, username: String, firstName: String, lastName: String, password: String) {
        self.userId = userId
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.password = password
    }
}

class User {
    //instantiated on first access
    static let sharedInstance = User()

    var users:[Int:UserStruct] = [:];
    
    func getUsers() {
        let requestUrl = "https://44066b6c.ngrok.io/users/"
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
                        guard let password = userInfo["password"] as? String else { return }
                        
                        let userStruct = UserStruct(userId: userId, username: username, firstName: firstName, lastName: lastName, password: password)
                        self.users[userId] = userStruct
                    }
                    self.notify()
                }
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
        })
        
        //actually make the api call
        task.resume()
    }
    
    private init() {
        print("Initializing User")
    }

    //observer setup
    private var observerArray = [Observer]()
    private var _number = Int()
    var number : Int {
        set {
            _number = newValue
            notify()
        }
        
        get {
            return _number
        }
    }
    
    func attachObserver(observer : Observer) {
        observerArray.append(observer)
    }
    
    private func notify() {
        for observer in observerArray {
            observer.update()
        }
    }
}
