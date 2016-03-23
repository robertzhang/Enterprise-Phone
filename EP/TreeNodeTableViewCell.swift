//
//  TreeNodeTableViewCell.swift
//  EP
//
//  Created by Robert Zhang on 15/10/22.
//  Copyright © 2015年 robertzhangsh@gmail.com. All rights reserved.
//

import UIKit

class TreeNodeTableViewCell: UITableViewCell {

    @IBOutlet weak var background: UIView! //用于控制cell偏移量
    @IBOutlet weak var nodeIMG: UIImageView!
    @IBOutlet weak var nodeName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
