import Foundation

struct ExpenseEntry: Codable {
    let amount: String
    let date: String
    let type: String
    let referenceId: String
    let companyId: String
    
    enum CodingKeys: String, CodingKey { // declaring our keys
        case amount = "amount"
        case date = "date"
        case type = "type"
        case referenceId = "reference_id"
        case companyId = "company_id"
    }
}

extension ExpenseEntry {
}
