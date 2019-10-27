//
//  PeopleTableViewCell.swift
//  People
//
//  Created by Тимур Кошевой on 25.10.2019.
//  Copyright © 2019 Тимур Кошевой. All rights reserved.
//

import UIKit

class HumanTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
