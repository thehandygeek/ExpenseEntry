import Foundation

struct ExpenseEntry: Codable {
    let amount: Decimal
    let date: Date
    let type: String
    let recieptImage: Data
}

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
    
    var amountExportString: String {
        let exportFormatter = NumberFormatter()
        exportFormatter.minimumFractionDigits = 2
        exportFormatter.maximumFractionDigits = 2
        exportFormatter.numberStyle = .decimal

        guard let amountString = exportFormatter.string(from: amount as NSDecimalNumber) else {
            return ""
        }
        return amountString
    }
}
