//
//  ExpenseEntry+Conversion.swift
//  ExpenseEntry
//
//  Created by Scott Champ on 2016-12-21.
//  Copyright © 2016 Touch Sciences. All rights reserved.
//

import Foundation

extension ExpenseEntry {
    func toDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self.date as! Date)
    }
    
    func toAmountString() -> String {
        return self.amount!.stringValue;
    }
}
