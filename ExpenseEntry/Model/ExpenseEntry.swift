import Foundation

struct ExpenseEntry: Codable {
    let amount: Decimal
    let date: Date
    let type: String
}
