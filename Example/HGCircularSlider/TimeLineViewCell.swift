//
//  TimeLineViewCell.swift
//  HGCircularSlider_Example
//
//  Created by TeemoYang on 2024/3/20.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class TimeLineViewCell: UITableViewCell {
    
    var time: String? {
        didSet {
            label.text = time
        }
    }
    
    var deleteAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        label.textColor = UIColor.black
    }

    @IBAction func deleteAction(_ sender: UIButton) {
        deleteAction?()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var label: UILabel!
}
