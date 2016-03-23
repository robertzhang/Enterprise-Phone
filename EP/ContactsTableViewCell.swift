//
//  ContactsTableViewCell.swift
//  EP
//
//  Created by Robert Zhang on 15/10/10.
//  Copyright © 2015年 robertzhangsh@gmail.com. All rights reserved.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {

    @IBOutlet weak var contactImg: UIImageView!
    @IBOutlet weak var contactTitle: UILabel!
    @IBOutlet weak var contactSubTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
