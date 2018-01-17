import Foundation

class ExpensesModel {
    private let kExpensesKey = "SettingsModelDTO"

    public var expenses: [ExpenseEntry]
    
    init() {
        self.expenses = [ExpenseEntry]()
        let settings = UserDefaults.standard
        if let jsonExpenses = settings.string(forKey: kExpensesKey), let data = jsonExpenses.data(using: .utf8) {
            do {
                self.expenses = try JSONDecoder().decode([ExpenseEntry].self, from: data)
            } catch { }
        }
    }
    
    func save() throws {
        let jsonExpenses = String(data: try JSONEncoder().encode(expenses), encoding: .utf8)
        let settings = UserDefaults.standard
        settings.set(jsonExpenses, forKey: kExpensesKey)
    }
    
    func generateCSVContent() -> String {
        var csvText: String = ""
        
        _ = expenses.map { csvText.append(String(format: "%@,%@,%@\r\n", $0.toDateString(), $0.type, $0.toAmountString())) }
        
//        for expense in expenses {
//            csvText.append(String(format: "%@,%@,%@\r\n", expense.toDateString(), expense.type!, expense.toAmountString()))
//        }
        return csvText
    }
}
