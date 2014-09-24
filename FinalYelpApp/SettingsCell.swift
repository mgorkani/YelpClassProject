//
//  SettingsCell.swift
//  FinalYelpApp
//
//  Created by Monika Gorkani on 9/23/14.
//  Copyright (c) 2014 Monika Gorkani. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    var type:String = ""
    var section:Int = 0
    var delegate:FilterChangedProtocol?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var settingsSwitch: UISwitch!
    @IBOutlet weak var settingsName: UILabel!
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func changedSettings(sender: AnyObject) {
        self.delegate?.updateFilterParams(section, filterDisplayName: settingsName.text!, selected: settingsSwitch.on)
    }
}
