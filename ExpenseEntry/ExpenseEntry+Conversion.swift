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
        return formatter.string(from: self.date)
    }
    
    func toMonthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM-yyyy"
        return formatter.string(from: self.date)
    }
    
    func toAmountString() -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        
        currencyFormatter.numberStyle = .currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = NSLocale.current
        guard let amountString = currencyFormatter.string(from: amount as NSDecimalNumber) else {
            return ""
        }
        return amountString
    }
}
