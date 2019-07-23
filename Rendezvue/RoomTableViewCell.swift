//
//  RoomTableViewCell.swift
//  Rendezvue
//
//  Created by Richard Dang on 2019-07-16.
//  Copyright © 2019 Rendezvue. All rights reserved.
//

import UIKit

class RoomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    
    var identifier: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
