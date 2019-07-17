//
//  ViewController.swift
//  Rendezvue
//
//  Created by Richard Dang on 2019-07-16.
//  Copyright © 2019 Rendezvue. All rights reserved.
//

import UIKit

class RoomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var titleBar: UINavigationBar!
    @IBOutlet weak var roomList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roomList.delegate = self
        roomList.dataSource = self
    }

    @IBAction func createButton() {
        
    }
    
    let roomNames = ["Richard's Room", "Jack's Room", "Thomas' Room", "Matthew's Room"]
    
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

