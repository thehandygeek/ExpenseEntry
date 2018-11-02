import Foundation

protocol CellDetails {
    var type: CellType { get }
}

protocol ConfigurableCell {
    func configure(with details: CellDetails)
}
