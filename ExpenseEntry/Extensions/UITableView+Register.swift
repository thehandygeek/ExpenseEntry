import UIKit

enum CellType: String {
    case date = "DateTableViewCell"
    case type = "ExpenseTypeTableViewCell"
    case amount = "ExpenseAmountTableViewCell"
    case capture = "CaptureTableViewCell"
}

extension UITableView {
    
    func register(cellTypes: [CellType]) {
        cellTypes.forEach { cellType in
            self.register(UINib(nibName: cellType.rawValue, bundle: nil), forCellReuseIdentifier: cellType.rawValue)
        }
    }
}
