import UIKit

struct PickerCellDetails: CellDetails {
    let id: String
    let title: String
    let selectedValue: String
    let values: [String]
    let expanded: Bool
    let delegate: PickerTableViewCellDelegate
    
    var type: CellType {
        return .picker
    }
}

protocol PickerTableViewCellDelegate: class {
    func valueUpdated(id: String, value: String)
}

class PickerTableViewCell: UITableViewCell, ConfigurableCell {
    
    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var selectionLabel: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    
    private var id: String?
    private var values: [String] = []
    private weak var delegate: PickerTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        picker.isHidden = true
        picker.delegate = self
        picker.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with details: CellDetails) {
        guard let cellDetails = details as? PickerCellDetails else { return }
        
        id = cellDetails.id
        titlelabel.text = cellDetails.title
        selectionLabel.text = cellDetails.selectedValue
        values = cellDetails.values
        if let selectedIndex = values.firstIndex(of: cellDetails.selectedValue) {
            picker.selectRow(selectedIndex, inComponent: 0, animated: false)
        }
        picker.isHidden = !cellDetails.expanded
        delegate = cellDetails.delegate
    }
    
}

extension PickerTableViewCell: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return values[row]
    }
}

extension PickerTableViewCell: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedValue = values[row]
        if let delegate = delegate, let id = id {
            delegate.valueUpdated(id: id, value: selectedValue)
        }
        selectionLabel.text = selectedValue
    }
}
