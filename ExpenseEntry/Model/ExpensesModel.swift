import Foundation
import SSZipArchive
import ExpenseLibrary

protocol ExpensesModelEvents: class {
    func expensesChanged(expenses: [ExpenseEntry])
}

class ExpensesModel {
    public var expenses: [ExpenseEntry]
    public weak var secondaryEventTarget: ExpensesModelEvents?
    
    private let networkHelper = NetworkHelper()
    private let eventTarget: ExpensesModelEvents
    let company: Company

    init(company: Company, eventTarget: ExpensesModelEvents) {
        self.company = company
        self.expenses = [ExpenseEntry]()
        self.eventTarget = eventTarget
        self.secondaryEventTarget = nil
        self.fetchExpenses()
    }
    
    func addExpense(type: ExpenseType, date: Date, amount: String, reciept: Data, completion: @escaping (Bool) -> Void) {
        let expense = ExpenseEntry(amount: Decimal(string: amount) ?? Decimal(floatLiteral: 0.0),
                                   date: date,
                                   type: type,
                                   company: company)
        networkHelper.addExpense(expense: expense) { expenseResult in
            switch expenseResult {
            case let .success(result):
                self.networkHelper.addReciept(expenseId: result, imageData: reciept) { recieptResult in
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
        networkHelper.getExpenses(company: company) { result in
            if case let .success(expenses) = result {
                self.expenses = expenses
                self.eventTarget.expensesChanged(expenses: self.expenses)
                if let target = self.secondaryEventTarget {
                    target.expensesChanged(expenses: self.expenses)
                }
            }
        }
    }
}
