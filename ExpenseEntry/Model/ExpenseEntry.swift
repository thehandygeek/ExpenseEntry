import Foundation

enum CompanyId: String {
    case touchSciences = "TCH"
    case hollandSunset = "SUN"
    case splashTravelling = "SPL"
    case etp = "ETP"
}

enum ExpenseType: String {
    case meal = "Meal"
    case travel = "Travel"
    case supplies = "Supplies"
    case auto = "Auto"
}

struct ExpenseEntry: Decodable {
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
    
    var typeValue: ExpenseType {
        get {
            return ExpenseType(rawValue: type) ?? .meal
        }
    }
    
    var companyIdValue: CompanyId {
        get {
            return CompanyId(rawValue: companyId) ?? .touchSciences
        }
    }
}
