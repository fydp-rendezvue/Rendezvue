//
//  ViewController.swift
//  Rendezvue
//
//  Created by Richard Dang on 2019-07-16.
//  Copyright © 2019 Rendezvue. All rights reserved.
//

import UIKit

class RoomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK:Properties
    @IBOutlet weak var roomList: UITableView!
    let roomNames = ["Richard's Room", "Jack's Room", "Thomas' Room", "Matthew's Room"]

    override func viewDidLoad() {
        super.viewDidLoad()
        roomList.delegate = self
        roomList.dataSource = self
        
        Room.sharedInstance.getRooms()
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
                    print("Your room name: \(roomName)")
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
        return roomNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RoomTableViewCell", for: indexPath) as? RoomTableViewCell else {
            fatalError("The dequeued cell is not an instance of RoomTableViewCell.")
        }
        
        let roomName = roomNames[indexPath.row]
        
        cell.roomLabel.text = roomName
        
        return cell
    }
    
}

