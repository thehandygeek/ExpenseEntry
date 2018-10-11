import Foundation
import SSZipArchive

protocol ExpensesModelEvents: class {
    func expensesChanged(expenses: [ExpenseEntry])
}

enum CompanyId: String {
    case touchSciences = "TCH"
    case hollandSunset = "SUN"
    case splashTravelling = "SPL"
}

class ExpensesModel {
    public var expenses: [ExpenseEntry]
    public weak var secondaryEventTarget: ExpensesModelEvents?
    public static let companyId: CompanyId = .touchSciences
    
    private let networkHelper = NetworkHelper()
    private let eventTarget: ExpensesModelEvents
    
    init(eventTarget: ExpensesModelEvents) {
        self.expenses = [ExpenseEntry]()
        self.eventTarget = eventTarget
        self.secondaryEventTarget = nil
        self.fetchExpenses()
    }
    
    func addExpense(type: String, date: Date, amount: String, companyId: String, reciept: Data, completion: @escaping (Bool) -> Void) {
        networkHelper.addExpense(type: type, date: date, amount: amount, companyId: companyId) { expenseResult in
            switch expenseResult {
            case let .success(result):
                self.networkHelper.addReciept(expenseId: result!, imageData: reciept) { recieptResult in
                    completion(recieptResult)
                    self.fetchExpenses()
                }
            case .failure:
                completion(false)
            }
        }
    }
    
    func deleteExpense(referenceId: String, completion: @escaping (Bool) -> Void) {
        networkHelper.deleteExpense(expenseId: referenceId) { success in
            if success {
                self.fetchExpenses()
            }
            completion(success)
        }
    }
    
    private func fetchExpenses() {
        networkHelper.getExpenses(companyId: ExpensesModel.companyId.rawValue) { result in
            if case let .success(expenses) = result {
                self.expenses = expenses!
                self.eventTarget.expensesChanged(expenses: self.expenses)
                if let target = self.secondaryEventTarget {
                    target.expensesChanged(expenses: self.expenses)
                }
            }
        }
    }
}
