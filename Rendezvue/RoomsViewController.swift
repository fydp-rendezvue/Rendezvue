//
//  ViewController.swift
//  Rendezvue
//
//  Created by Richard Dang on 2019-07-16.
//  Copyright © 2019 Rendezvue. All rights reserved.
//

import UIKit

class RoomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Observer {
    //MARK:Properties
    @IBOutlet weak var roomList: UITableView!
    var roomStructs = [RoomStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roomList.delegate = self
        roomList.dataSource = self
        
        Room.sharedInstance.observerSubject.attachObserver(observer: self)
        Room.sharedInstance.getRooms()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "settingsSegue") {
            let vc = segue.destination as! RoomSettingsViewController
            
            let tableViewCell = (sender as! UIButton).superview?.superview as! RoomTableViewCell
            vc.roomId = tableViewCell.identifier
        }
    }
    
    
    //MARK: Actions
    @IBAction func createRoomButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "What's the name of your room?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Room Name"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if let roomName = alert.textFields?.first?.text {
                //TODO: Post room name to backend
                if(roomName.count > 0){
                    Room.sharedInstance.postRoom(roomName: roomName)
                    Room.sharedInstance.getRooms()
                }
            }
        }))
        
        self.present(alert, animated: true)
    }
    
    //MARK: UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomStructs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RoomTableViewCell", for: indexPath) as? RoomTableViewCell else {
            fatalError("The dequeued cell is not an instance of RoomTableViewCell.")
        }
        
        let roomName = roomStructs[indexPath.row].roomName
        let roomId = roomStructs[indexPath.row].roomId
        
        cell.roomLabel.text = roomName
        cell.identifier = roomId
        
        return cell
    }
    
    func getRoomNames() {
        let rooms = Room.sharedInstance.rooms
        roomStructs = [RoomStruct]()
        for room in rooms {
            roomStructs.append(room.value)
        }
    }
    
    func update() {
        getRoomNames()
        DispatchQueue.main.async {
            self.roomList.reloadData()
        }
    }
}

