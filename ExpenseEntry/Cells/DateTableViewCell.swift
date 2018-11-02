import UIKit

struct DateCellDetails: CellDetails {
    let date: Date
    let expanded: Bool
    let delegate: DateTableViewCellDelegate
    
    var type: CellType {
        return .date
    }
}

protocol DateTableViewCellDelegate: class {
    func dateUpdated(date: Date)
}

class DateTableViewCell: UITableViewCell, ConfigurableCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    private var expanaded = false
    private weak var delegate: DateTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with details: CellDetails) {
        guard let dateDetails = details as? DateCellDetails else { return }
        
        setDateUI(date: dateDetails.date)
        datePicker.isHidden  = !dateDetails.expanded
        delegate = dateDetails.delegate
    }
    
    @objc
    func dateChanged(_ sender: UIDatePicker) {
        delegate?.dateUpdated(date: sender.date)
        setDateUI(date: sender.date)
    }
    
    private func setDateUI(date: Date) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM d, yyyy")
        dateLabel.text = dateFormatter.string(from: date)
        datePicker.date = date
    }
}
