import UIKit

struct ExpenseAmountCellDetails: CellDetails {
    let amount: String
    let delegate: ExpenseAmountTableViewCellDelegate
}

protocol ExpenseAmountTableViewCellDelegate: class {
    func amountUpdated(amount: String)
}

class ExpenseAmountTableViewCell: UITableViewCell, ConfigurableCell {
    
    @IBOutlet weak var amountField: UITextField!
    
    private weak var delegate: ExpenseAmountTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        amountField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with details: CellDetails) {
        guard let cellDetails = details as? ExpenseAmountCellDetails else { return }
        
        amountField.text = cellDetails.amount
        delegate = cellDetails.delegate
    }
}

extension ExpenseAmountTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            delegate?.amountUpdated(amount: updatedText)
        }

    return true
    }
}
