//
//  CurrencyTableViewCell.swift
//  Cashew
//
//  Created by Robo Atenaga on 3/7/18.
//  Copyright © 2018 Robo Atenaga. All rights reserved.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {

    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblISO: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
