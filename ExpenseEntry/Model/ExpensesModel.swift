import Foundation
import SSZipArchive

class ExpensesModel {
    private let kExpensesKey = "SettingsModelDTO"

    public var expenses: [ExpenseEntry]
    
    init() {
        self.expenses = [ExpenseEntry]()
        let settings = UserDefaults.standard
        if let jsonExpenses = settings.data(forKey: kExpensesKey) {
            do {
                self.expenses = try JSONDecoder().decode([ExpenseEntry].self, from: jsonExpenses)
            } catch { }
        }
    }
    
    func save() throws {
        let jsonExpenses = try JSONEncoder().encode(expenses)
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
    
    func generateZip(path: URL) -> URL? {
        var result: URL? = nil
        do {
            let destinationName = self.expenses[0].toMonthString() + "-Expenses"
            let sourceDirectory = path.appendingPathComponent(destinationName)
            let imageDirectory = sourceDirectory.appendingPathComponent("Images")
            try? FileManager.default.removeItem(at: sourceDirectory)
            try FileManager.default.createDirectory(at: sourceDirectory, withIntermediateDirectories: false, attributes: nil)
            try FileManager.default.createDirectory(at: imageDirectory, withIntermediateDirectories: false, attributes: nil)
            var csvText = ""
            for expense in expenses {
                let imageSha = expense.recieptImage.sha1
                let shortIndex = imageSha.index(imageSha.startIndex, offsetBy: 8)
                let imageName = String(imageSha[..<shortIndex] + ".jpg")
                let imagePath = imageDirectory.appendingPathComponent(imageName)
                try expense.recieptImage.write(to: imagePath, options: .atomic)
                csvText.append(String(format: "%@,%@,%@,Images/%@\r\n", expense.toDateString(), expense.type, expense.amountExportString, imageName))
            }
            let csvPath = sourceDirectory.appendingPathComponent(destinationName + ".csv")
            try csvText.write(to: csvPath, atomically: true, encoding: String.Encoding.utf8)
            let zipPath = path.appendingPathComponent(destinationName + ".zip")
            try? FileManager.default.removeItem(at: zipPath)
            SSZipArchive.createZipFile(atPath: zipPath.path, withContentsOfDirectory: sourceDirectory.path)
            result = zipPath
            try? FileManager.default.removeItem(at: sourceDirectory)
        } catch {
            
        }

        return result
    }
}
