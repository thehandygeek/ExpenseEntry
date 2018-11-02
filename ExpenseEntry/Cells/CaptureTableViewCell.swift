import UIKit

struct CaptureCellDetails: CellDetails {
    let image: UIImage?
    let delegate: CaptureTableViewCellDelegate
    
    var type: CellType {
        return .capture
    }
}

protocol CaptureTableViewCellDelegate: class {
    func captureAction(_ sender: UIButton)
    func selectAction(_ sender: UIButton)
}

class CaptureTableViewCell: UITableViewCell, ConfigurableCell {
    @IBOutlet weak var captureImageView: UIImageView!
    
    private weak var delegate: CaptureTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func captureAction(_ sender: UIButton) {
        delegate?.captureAction(sender)
    }
    
    @IBAction func selectAction(_ sender: UIButton) {
        delegate?.selectAction(sender)
    }
    
    func configure(with details: CellDetails) {
        guard let cellDetails = details as? CaptureCellDetails else { return }
        
        captureImageView.image = cellDetails.image
        delegate = cellDetails.delegate
    }
}
