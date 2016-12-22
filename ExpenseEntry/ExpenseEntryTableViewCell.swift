//
//  ExpenseEntryTableViewCell.swift
//  ExpenseEntry
//
//  Created by Scott Champ on 2016-12-21.
//  Copyright © 2016 Touch Sciences. All rights reserved.
//

import UIKit

class ExpenseEntryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
