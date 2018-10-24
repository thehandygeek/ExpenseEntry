import UIKit
import MobileCoreServices
import TPKeyboardAvoiding

class ExpenseEntryTableViewController: UIViewController {
    
    private let tableRows: [CellType] = [.date, .type, .amount, .capture]
 
    private var expensesModel: ExpensesModel!

    private var selectedDate = Date()
    private var enteredAmount = ""
    private var selectedType: ExpenseType = .meal
    private var recieptImage: UIImage?
    private var dateExpanded = false
    private var typeExpanded = false
    
    @IBOutlet weak var tableView: TPKeyboardAvoidingTableView!
    @IBOutlet weak var countLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        expensesModel = ExpensesModel(eventTarget: self)
        title = "Expense Entry \(ExpensesModel.companyDisplayValue)"

        tableView.register(cellTypes: [.amount, .date, .type, .capture])
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCamera" {
            if let cameraViewController = segue.destination as? CameraViewController {
                cameraViewController.delegate = self
            }
        }
        else if segue.identifier == "ShowReport" {
            if let reportController = segue.destination as? ExpenseReportTableViewController {
                reportController.set(expensesModel: expensesModel!)
            }
        }
    }
    
    @objc
    func applicationDidBecomeActive(_ notification: NSNotification) {
        selectedDate = Date()
    }
    
    private func updateCount() {
        countLabel.text = "Record count: \(expensesModel.expenses.count)"
    }
}

extension ExpenseEntryTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableCell = tableView.dequeueReusableCell(withIdentifier: tableRows[indexPath.row].rawValue, for: indexPath) as? UITableViewCell & ConfigurableCell else {
            return UITableViewCell()
        }
        
        tableCell.configure(with: cellDetailsFor(row: indexPath.row))
        
        return tableCell
    }
    
    @IBAction func reportAction(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowReport", sender: nil)
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        guard let image = recieptImage,
            let imageData = UIImageJPEGRepresentation(image, 0.6),
            enteredAmount != "" else {
                return
        }
        
        let successTitle = "Expense Added"
        let successMessage = "You successfully added your expense"
        let failureTitle = "Expense Not Added"
        let failureMessage = "Request to add expense failed"
        let spinner = displaySpinner()
        expensesModel.addExpense(type: selectedType, date: selectedDate, amount: enteredAmount, reciept: imageData) { success in
            self.removeSpinner(spinner: spinner)
            let title = success ? successTitle : failureTitle
            let message = success ? successMessage : failureMessage
            self.showAlert(title: title, message: message)
            if success {
                self.enteredAmount = ""
                self.recieptImage = nil
                self.tableView.reloadData()
            }
        }
    }
    
    private func cellDetailsFor(row: Int) -> CellDetails {
        switch tableRows[row] {
        case .amount:
            return ExpenseAmountCellDetails(amount: enteredAmount, delegate: self)
        case .date:
            return DateCellDetails(date: selectedDate, expanded: dateExpanded, delegate: self)
        case .type:
            return ExpenseTypeCellDetails(type: selectedType, expanded: typeExpanded, delegate: self)
        case .capture:
            return CaptureCellDetails(image: recieptImage, delegate: self)

        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        alertViewController.addAction(alertAction)
        self.present(alertViewController, animated: true, completion: nil)
    }
    
}

extension ExpenseEntryTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableRows[indexPath.row] == CellType.date {
            dateExpanded.toggle()
            if dateExpanded { typeExpanded = false }
            tableView.beginUpdates()
            tableView.reloadData()
            tableView.endUpdates()
        } else if tableRows[indexPath.row] == CellType.type {
            typeExpanded.toggle()
            if typeExpanded { dateExpanded = false }
            tableView.beginUpdates()
            tableView.reloadData()
            tableView.endUpdates()
        }
    }
}

extension ExpenseEntryTableViewController: DateTableViewCellDelegate {
    func dateUpdated(date: Date) {
        self.selectedDate = date
    }
}

extension ExpenseEntryTableViewController: ExpenseTypeTableViewCellDelegate {
    func typeUpdated(type: ExpenseType) {
        selectedType = type
    }
}

extension ExpenseEntryTableViewController: ExpenseAmountTableViewCellDelegate {
    func amountUpdated(amount: String) {
        enteredAmount = amount
    }
}

extension ExpenseEntryTableViewController: CaptureTableViewCellDelegate {
    func captureAction(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowCamera", sender: nil)
    }
    
    func selectAction(_ sender: UIButton) {
        let importMenu = UIDocumentMenuViewController(documentTypes: [String(kUTTypeJPEG)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
}

extension ExpenseEntryTableViewController: CameraViewContollerDelegate {
    func dismiss(viewController: CameraViewController, image: UIImage) {
        recieptImage = image
        navigationController?.popViewController(animated: true)
        
        tableView.reloadData()
    }
}

extension ExpenseEntryTableViewController: ExpensesModelEvents {
    func expensesChanged(expenses: [ExpenseEntry]) {
        updateCount()
    }
}

extension ExpenseEntryTableViewController: UIDocumentMenuDelegate,UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let myURL = url as URL
        let fileManager = FileManager.default
        guard let imageData = fileManager.contents(atPath: myURL.path),
            let image = UIImage.init(data: imageData , scale: 1.0) else { return }
        recieptImage = image
        
        tableView.reloadData()
    }
    
    
    public func documentMenu(_ documentMenu:UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
    
}
