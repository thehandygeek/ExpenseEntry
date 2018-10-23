import Foundation

protocol CellDetails {}

protocol ConfigurableCell {
    func configure(with details: CellDetails)
}
