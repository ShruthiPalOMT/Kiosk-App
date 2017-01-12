//
//  ArgumentsTableViewCell.swift
//  WebAppDemo
//
//  Created by Yilei He on 19/12/16.
//  Copyright © 2016 Yilei He. All rights reserved.
//

import UIKit

class ArgumentsTableViewCell: UITableViewCell {

    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
