//
//  LapTimeTableViewCell.swift
//  SpeedRun
//
//  Created by Nikita Pekurin on 3/15/20.
//  Copyright © 2020 Nikita Pekurin. All rights reserved.
//

import UIKit

class LapTimeTableViewCell: UITableViewCell {

    @IBOutlet weak var lapTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
