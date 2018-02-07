import Foundation

struct ExpenseEntry: Codable {
    let amount: String
    let date: String
    let type: String
    let referenceId: String
    
    enum CodingKeys: String, CodingKey { // declaring our keys
        case amount = "amount"
        case date = "date"
        case type = "type"
        case referenceId = "reference_id"
    }
}

extension ExpenseEntry {
}
