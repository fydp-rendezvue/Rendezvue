//
//  RoomSettingsViewController.swift
//  Rendezvue
//
//  Created by Richard Dang on 2019-07-16.
//  Copyright © 2019 Rendezvue. All rights reserved.
//

import UIKit

class RoomSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: Properties
    @IBOutlet weak var userList: UITableView!
    let usernames = ["Richard", "Jack", "Thomas", "Matthew"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        userList.delegate = self
        userList.dataSource = self
    }
    
    //MARK: Actions
    @IBAction func addUserButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Users", message: nil, preferredStyle: .alert)
        
        self.present(alert, animated: true)
    }
    @IBAction func deleteRoomButton(_ sender: UIBarButtonItem) {
        
    }
    
    //MARK: UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as? UserTableViewCell else {
            fatalError("The dequeued cell is not an instance of UserTableViewCell.")
        }
        
        let username = usernames[indexPath.row]
        cell.usernameLabel.text = username
        
        return cell
    }

}
