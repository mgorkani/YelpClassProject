//
//  RestaurantCell.swift
//  YelpApp
//
//  Created by Monika Gorkani on 9/22/14.
//  Copyright (c) 2014 Monika Gorkani. All rights reserved.
//

import UIKit

class RestaurantCell: UITableViewCell {
    
   @IBOutlet weak var starsView: UIImageView!

   @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
   @IBOutlet weak var reviewsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
   @IBOutlet weak var milesLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
