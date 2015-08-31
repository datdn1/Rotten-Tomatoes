//
//  MovieCell.swift
//  RottenTomato
//
//  Created by datdn1 on 8/26/15.
//  Copyright (c) 2015 datdn1. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {

    @IBOutlet weak var titleMovie: UILabel!
    @IBOutlet weak var synosysMovie: UILabel!
    @IBOutlet weak var posterMovie: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
