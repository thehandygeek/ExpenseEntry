import UIKit

struct ExpenseTypeCellDetails: CellDetails {
    let type: ExpenseType
    let expanded: Bool
    let delegate: ExpenseTypeTableViewCellDelegate
}

protocol ExpenseTypeTableViewCellDelegate: class {
    func typeUpdated(type: ExpenseType)
}

class ExpenseTypeTableViewCell: UITableViewCell, ConfigurableCell {
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var typePicker: UIPickerView!
    
    private var expenseTypes: [ExpenseType] = [.meal, .travel, .auto, .supplies]
    private weak var delegate: ExpenseTypeTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        typePicker.isHidden = true
        typePicker.delegate = self
        typePicker.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with details: CellDetails) {
        guard let cellDetails = details as? ExpenseTypeCellDetails else { return }
        
        typeLabel.text = cellDetails.type.rawValue
        if let selectedType = expenseTypes.firstIndex(of: cellDetails.type) {
            typePicker.selectRow(selectedType, inComponent: 0, animated: false)
        }
        typePicker.isHidden = !cellDetails.expanded
        delegate = cellDetails.delegate
    }
    
}

extension ExpenseTypeTableViewCell: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return expenseTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return expenseTypes[row].rawValue
    }
}

extension ExpenseTypeTableViewCell: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedType = expenseTypes[row]
        delegate?.typeUpdated(type: selectedType)
        typeLabel.text = expenseTypes[row].rawValue
    }
}
